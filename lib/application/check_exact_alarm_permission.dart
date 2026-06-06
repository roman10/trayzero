import '../core/notification_scheduler.dart';
import '../core/result.dart';

/// Reads whether the platform currently allows exact alarms.
///
/// On Android this maps to the exact-alarm special access needed for precise
/// reminder timing; on other platforms it is always true.
final class CheckExactAlarmPermission {
  CheckExactAlarmPermission({required NotificationScheduler scheduler})
    : _scheduler = scheduler;

  final NotificationScheduler _scheduler;

  Future<Result<bool, String>> call() async {
    try {
      return Ok(await _scheduler.canScheduleExactAlarms());
    } on Object catch (e) {
      return Err(e.toString());
    }
  }
}
