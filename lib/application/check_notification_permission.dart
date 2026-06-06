import '../core/notification_scheduler.dart';
import '../core/result.dart';

/// Reads the current OS-level local-notification permission *without*
/// prompting. Used to drive the Settings status tile and to warn the user
/// when they set a reminder but notifications are off, so a scheduled
/// reminder doesn't silently fail.
final class CheckNotificationPermission {
  CheckNotificationPermission({required NotificationScheduler scheduler})
      : _scheduler = scheduler;

  final NotificationScheduler _scheduler;

  Future<Result<NotificationPermission, String>> call() async {
    try {
      return Ok(await _scheduler.permissionStatus());
    } on Object catch (e) {
      return Err(e.toString());
    }
  }
}
