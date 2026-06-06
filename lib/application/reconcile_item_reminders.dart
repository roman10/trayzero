import '../core/defer_time.dart';
import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';
import '../domain/entities/entities.dart';

/// Reconciles one item's Due:/Soon:/Ready: reminders against its current
/// dates: schedule when the anchor is set, cancel the matching id when it is
/// not. The three salts mirror [SaveItem]'s original inline block (1 = Due,
/// 2 = Ready/defer, 3 = Soon/lead).
///
/// Extracted from [SaveItem] so the launch re-arm ([RearmItemReminders]) can
/// apply the *identical* logic to a stored item without re-persisting it —
/// `SaveItem` is otherwise the only thing that schedules item reminders, so a
/// restored backup / Google Tasks import and any OEM-wiped alarm would stay
/// silent.
///
/// [item] must already be normalised by `enforceStatusDateInvariant`
/// (`SaveItem` does this before persisting; the re-arm does it read-only) so
/// a next action's stale `dueAt` is gone and the cancel branch tears down any
/// "Due:" reminder we'd never honour. [now] anchors the lead-window check.
Future<void> reconcileItemReminders(
  Item item, {
  required NotificationScheduler scheduler,
  required DateTime now,
  required int leadTimeMinutes,
  required int deferSurfaceMinutes,
}) async {
  final dueId = notificationIdFor(item.id, 1);
  final deferId = notificationIdFor(item.id, 2);
  final soonId = notificationIdFor(item.id, 3);
  if (item.dueAt != null) {
    final title = 'Due: ${item.title}';
    final body = item.notes ?? '';
    await scheduler.schedule(
      id: dueId,
      at: item.dueAt!,
      title: title,
      body: body,
      payload: NotificationPayload(
        kind: NotificationKind.due,
        itemId: item.id,
        title: title,
        body: body,
      ).encode(),
    );
  } else {
    await scheduler.cancel(dueId);
  }
  // Pre-due "Soon:" tickler. Only when a lead time is configured and the
  // lead moment is still in the future — if the lead window has already
  // passed (lead larger than time-until-due, or due itself past) we skip
  // it; the due reminder above is handled independently.
  final leadMoment = item.dueAt?.subtract(Duration(minutes: leadTimeMinutes));
  if (item.dueAt != null &&
      leadTimeMinutes > 0 &&
      leadMoment != null &&
      leadMoment.isAfter(now)) {
    final title = 'Soon: ${item.title}';
    final body = item.notes ?? '';
    await scheduler.schedule(
      id: soonId,
      at: leadMoment,
      title: title,
      body: body,
      // Android: auto-dismiss Soon at dueAt so the tray doesn't hold a
      // stale "upcoming" banner once Due itself fires. iOS ignores this
      // (no equivalent OS property) — the foreground sweep covers iOS.
      timeoutAfter: Duration(minutes: leadTimeMinutes),
      payload: NotificationPayload(
        kind: NotificationKind.soon,
        itemId: item.id,
        title: title,
        body: body,
      ).encode(),
    );
  } else {
    await scheduler.cancel(soonId);
  }
  if (item.deferUntil != null) {
    final title = 'Ready: ${item.title}';
    const body = 'Your deferred item is now available.';
    final readyAt = deferReminderAt(item.deferUntil!, deferSurfaceMinutes);
    // Same "retire when Due fires" trick: when a deferred item also carries
    // a dueAt that lands after Ready surfaces, auto-dismiss Ready at dueAt.
    // Without a dueAt (or with dueAt <= readyAt, which shouldn't happen but
    // we don't trust it) Ready stays until the user touches it.
    final readyTimeout = (item.dueAt != null && item.dueAt!.isAfter(readyAt))
        ? item.dueAt!.difference(readyAt)
        : null;
    await scheduler.schedule(
      id: deferId,
      at: readyAt,
      title: title,
      body: body,
      timeoutAfter: readyTimeout,
      payload: NotificationPayload(
        kind: NotificationKind.ready,
        itemId: item.id,
        title: title,
        body: body,
      ).encode(),
    );
  } else {
    await scheduler.cancel(deferId);
  }
}
