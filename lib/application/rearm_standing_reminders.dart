import 'schedule_backup_reminder.dart';
import 'schedule_weekly_review_reminder.dart';

/// On app launch, (re)schedule the standing reminders whose Settings toggle
/// is enabled.
///
/// [ScheduleWeeklyReviewReminder] / [ScheduleBackupReminder] are otherwise
/// fired only by the Settings switch, so a fresh install with the default-ON
/// weekly-review nudge never armed it, and an OEM force-stop that wiped
/// pending alarms left them dead until the user re-toggled. Re-arming here
/// heals both. Idempotent: fixed notification ids (990001 / 990002) and a
/// deterministic next-occurrence time, so a re-run just replaces the
/// existing alarm.
final class RearmStandingReminders {
  RearmStandingReminders({
    required ScheduleWeeklyReviewReminder scheduleWeeklyReview,
    required ScheduleBackupReminder scheduleBackup,
    required bool weeklyReviewEnabled,
    required bool backupEnabled,
  })  : _scheduleWeeklyReview = scheduleWeeklyReview,
        _scheduleBackup = scheduleBackup,
        _weeklyReviewEnabled = weeklyReviewEnabled,
        _backupEnabled = backupEnabled;

  final ScheduleWeeklyReviewReminder _scheduleWeeklyReview;
  final ScheduleBackupReminder _scheduleBackup;
  final bool _weeklyReviewEnabled;
  final bool _backupEnabled;

  Future<void> call() async {
    if (_weeklyReviewEnabled) await _scheduleWeeklyReview.call();
    if (_backupEnabled) await _scheduleBackup.call();
  }
}
