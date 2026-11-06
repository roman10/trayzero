import 'package:cleartray/application/rearm_standing_reminders.dart';
import 'package:cleartray/application/schedule_backup_reminder.dart';
import 'package:cleartray/application/schedule_weekly_review_reminder.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationScheduler scheduler;
  late FakeClock clock;

  RearmStandingReminders rearm({
    required bool weeklyReviewEnabled,
    required bool backupEnabled,
  }) =>
      RearmStandingReminders(
        scheduler: scheduler,
        clock: clock,
        scheduleWeeklyReview:
            ScheduleWeeklyReviewReminder(scheduler: scheduler, clock: clock),
        scheduleBackup:
            ScheduleBackupReminder(scheduler: scheduler, clock: clock),
        weeklyReviewEnabled: weeklyReviewEnabled,
        backupEnabled: backupEnabled,
      );

  setUp(() {
    scheduler = FakeNotificationScheduler();
    clock = FakeClock(DateTime(2026, 5, 13, 14)); // Wednesday
  });

  test('arms both standing reminders, weekly-repeating, when both enabled',
      () async {
    await rearm(weeklyReviewEnabled: true, backupEnabled: true).call();
    expect(
      scheduler.scheduled.map((s) => s.id).toSet(),
      {weeklyReviewReminderId, backupReminderId},
    );
    expect(
      scheduler.scheduled.every((s) => s.repeat == ScheduleRepeat.weekly),
      isTrue,
    );
  });

  test('arms only the weekly review nudge when backup is off', () async {
    await rearm(weeklyReviewEnabled: true, backupEnabled: false).call();
    expect(scheduler.scheduled.map((s) => s.id), [weeklyReviewReminderId]);
  });

  test('arms only the backup nudge when the review nudge is off', () async {
    await rearm(weeklyReviewEnabled: false, backupEnabled: true).call();
    expect(scheduler.scheduled.map((s) => s.id), [backupReminderId]);
  });

  test('schedules nothing when both are disabled', () async {
    await rearm(weeklyReviewEnabled: false, backupEnabled: false).call();
    expect(scheduler.scheduled, isEmpty);
  });
}
