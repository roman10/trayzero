import '../core/notification_scheduler.dart';
import '../core/result.dart';

/// Requests access to exact alarms when the platform supports that concept.
///
/// On Android 12+ this opens the system "Alarms & reminders" screen if needed.
final class RequestExactAlarmPermission {
  RequestExactAlarmPermission({required NotificationScheduler scheduler})
    : _scheduler = scheduler;

  final NotificationScheduler _scheduler;

  Future<Result<bool, String>> call() async {
    try {
      return Ok(await _scheduler.requestExactAlarmsPermission());
    } on Object catch (e) {
      return Err(e.toString());
    }
  }
}
