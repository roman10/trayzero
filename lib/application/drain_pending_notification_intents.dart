import 'package:flutter/foundation.dart';

import '../core/notification_scheduler.dart';
import '../infrastructure/pending_notification_intents.dart';
import 'handle_notification_response.dart';

/// Drains the headless-tap journal, replaying every queued action
/// through [HandleNotificationResponse].
///
/// The background isolate that catches Done / Move-to-Next-Actions taps
/// has no DI or DB, so it merely appends the raw event to disk. This
/// use case is the foreground side of that bargain: at startup it
/// reads the file and feeds every entry to the real handler, so the
/// mutation goes through the same code path as an in-app tap (full
/// recurrence rollover, reminder teardown, undo affordance) — just
/// shifted in time to the next launch.
///
/// Best-effort by design: a per-event failure (deleted item, malformed
/// payload) must not abort the rest of the drain or the app launch.
final class DrainPendingNotificationIntents {
  DrainPendingNotificationIntents({
    required PendingNotificationIntents store,
    required HandleNotificationResponse handler,
  })  : _store = store,
        _handler = handler;

  final PendingNotificationIntents _store;
  final HandleNotificationResponse _handler;

  Future<void> call() async {
    List<NotificationActionEvent> events;
    try {
      events = await _store.drain();
    } catch (e, st) {
      debugPrint('[notif] pending-intent drain FAILED: $e\n$st');
      return;
    }
    for (final e in events) {
      try {
        await _handler.call(e);
      } catch (err, st) {
        debugPrint('[notif] pending-intent replay FAILED: $err\n$st');
      }
    }
  }
}
