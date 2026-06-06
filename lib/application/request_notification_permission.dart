import '../core/notification_scheduler.dart';
import '../core/result.dart';

/// Requests the OS-level local-notification permission. Returns a [Result]
/// carrying the resulting [NotificationPermission] so callers can branch
/// between granted / still-denied / permanently-denied without throwing.
final class RequestNotificationPermission {
  RequestNotificationPermission({required NotificationScheduler scheduler})
      : _scheduler = scheduler;

  final NotificationScheduler _scheduler;

  Future<Result<NotificationPermission, String>> call() async {
    try {
      return Ok(await _scheduler.requestPermission());
    } on Object catch (e) {
      return Err(e.toString());
    }
  }
}
