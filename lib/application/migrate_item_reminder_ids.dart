import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import 'pending_snoozed_reminders.dart';

/// Moves Item reminders still pending under an id other than the current
/// [notificationIdFor] — requests armed by a build with the older id
/// scheme — onto their current ids, so cancel-by-id (save, complete,
/// delete) reaches them again and re-arming does not duplicate them.
///
/// Requests are recognised by payload (Item id + kind), never by id, so
/// standing reminders (no Item id) are never touched. For each stray
/// request:
/// - a future Snooze of a live Item is re-posted at its Snooze time under
///   the current id *before* the stray is cancelled;
/// - anything else is cancelled, and the live Item is reconciled through
///   [reconcile] (preserving its Snoozes) so its reminders are re-armed
///   under the current ids — including a user-saved reminder on an Item
///   the bulk re-arm skips, such as an imported calendar event.
///
/// Runs on every launch before the re-arm. Crash-safe and idempotent: each
/// stray is cancelled only after its replacement exists, so a rerun finds
/// whatever is left and finishes; once nothing is stray it is a no-op.
Future<void> migrateItemReminderIds({
  required List<PendingNotification> pending,
  required ItemRepository items,
  required NotificationScheduler scheduler,
  required DateTime now,
  required Future<void> Function(Item item, Set<int> preserveIds) reconcile,
}) async {
  final strays = <String, List<(PendingNotification, NotificationPayload)>>{};
  for (final request in pending) {
    final payload = NotificationPayload.tryDecode(request.payload);
    final itemId = payload?.itemId;
    final salt = _saltFor(payload?.kind);
    if (itemId == null || salt == null) continue;
    if (request.id == notificationIdFor(itemId, salt)) continue;
    (strays[itemId] ??= []).add((request, payload!));
  }
  for (final MapEntry(key: itemId, value: requests) in strays.entries) {
    final item = await items.getById(itemId);
    final live =
        item != null &&
        item.completedAt == null &&
        item.status != ItemStatus.done &&
        item.status != ItemStatus.trashed;
    final moved = <int>{};
    var rearm = false;
    for (final (request, payload) in requests) {
      final snoozedUntil = payload.snoozedUntil;
      if (live && snoozedUntil != null && snoozedUntil.isAfter(now)) {
        final id = notificationIdFor(itemId, _saltFor(payload.kind)!);
        await scheduler.schedule(
          id: id,
          at: snoozedUntil,
          title: payload.title,
          body: payload.body,
          payload: request.payload,
        );
        moved.add(id);
      } else {
        rearm = true;
      }
      await scheduler.cancel(request.id);
    }
    if (live && rearm) {
      await reconcile(item, {
        ...moved,
        ...pendingSnoozedReminderIds(pending, now: now, itemId: itemId),
      });
    }
  }
}

/// The reminder salt of an Item notification kind (see
/// [notificationIdFor]); null for standing kinds.
int? _saltFor(NotificationKind? kind) => switch (kind) {
  NotificationKind.due => 1,
  NotificationKind.ready => 2,
  NotificationKind.soon => 3,
  _ => null,
};
