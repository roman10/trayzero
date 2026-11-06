import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';
import 'schedule_backup_reminder.dart';
import 'schedule_weekly_review_reminder.dart';

/// Group once before walking restored Items, so each Item only inspects its
/// own pending requests. Expiry/identity validation remains per Item because
/// the clock can advance while a large restore is being re-armed.
Map<String?, List<PendingNotification>> pendingSnoozesByOwner(
  List<PendingNotification> pending,
) {
  final byOwner = <String?, List<PendingNotification>>{};
  for (final request in pending) {
    final payload = NotificationPayload.tryDecode(request.payload);
    if (payload == null || payload.snoozedUntil == null) continue;
    (byOwner[payload.itemId] ??= []).add(request);
  }
  return byOwner;
}

/// Only trust a future Snooze whose OS id agrees with its kind and owner.
/// Normal reminders, malformed payloads and old metadata follow normal re-arm.
Set<int> pendingSnoozedReminderIds(
  List<PendingNotification> pending, {
  required DateTime now,
  String? itemId,
}) {
  final ids = <int>{};
  for (final request in pending) {
    final payload = NotificationPayload.tryDecode(request.payload);
    if (payload == null ||
        payload.itemId != itemId ||
        !(payload.snoozedUntil?.isAfter(now) ?? false)) {
      continue;
    }
    final expectedId = switch (payload.kind) {
      NotificationKind.due when itemId != null => notificationIdFor(itemId, 1),
      NotificationKind.ready when itemId != null => notificationIdFor(
        itemId,
        2,
      ),
      NotificationKind.weeklyReview when itemId == null =>
        weeklyReviewReminderId,
      NotificationKind.backup when itemId == null => backupReminderId,
      _ => null,
    };
    if (request.id == expectedId) ids.add(request.id);
  }
  return ids;
}
