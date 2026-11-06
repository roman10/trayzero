import '../core/clock.dart';
import '../core/notification_scheduler.dart';
import 'pending_snoozed_reminders.dart';
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
/// existing alarm. A pending, unexpired Snooze takes priority until it fires;
/// disabled preferences still cancel their requests.
final class RearmStandingReminders {
  RearmStandingReminders({
    required NotificationScheduler scheduler,
    required Clock clock,
    required ScheduleWeeklyReviewReminder scheduleWeeklyReview,
    required ScheduleBackupReminder scheduleBackup,
    required bool weeklyReviewEnabled,
    required bool backupEnabled,
  }) : _scheduler = scheduler,
       _clock = clock,
       _scheduleWeeklyReview = scheduleWeeklyReview,
       _scheduleBackup = scheduleBackup,
       _weeklyReviewEnabled = weeklyReviewEnabled,
       _backupEnabled = backupEnabled;

  final NotificationScheduler _scheduler;
  final Clock _clock;
  final ScheduleWeeklyReviewReminder _scheduleWeeklyReview;
  final ScheduleBackupReminder _scheduleBackup;
  final bool _weeklyReviewEnabled;
  final bool _backupEnabled;

  Future<void> call() async {
    final pending = await _scheduler.getPendingNotifications();
    final snoozed = pendingSnoozedReminderIds(pending, now: _clock.now());
    if (!_weeklyReviewEnabled) {
      await _scheduler.cancel(weeklyReviewReminderId);
    } else if (!snoozed.contains(weeklyReviewReminderId)) {
      await _scheduleWeeklyReview.call();
    }
    if (!_backupEnabled) {
      await _scheduler.cancel(backupReminderId);
    } else if (!snoozed.contains(backupReminderId)) {
      await _scheduleBackup.call();
    }
  }
}
