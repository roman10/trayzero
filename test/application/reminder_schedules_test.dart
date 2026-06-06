import 'package:cleartray/application/schedule_backup_reminder.dart';
import 'package:cleartray/application/schedule_weekly_review_reminder.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationScheduler scheduler;

  setUp(() {
    scheduler = FakeNotificationScheduler();
  });

  group('ScheduleWeeklyReviewReminder', () {
    test('books next Friday 16:00 when today is mid-week', () async {
      // Wednesday 2026-05-13 14:00 → next Friday is 2026-05-15 16:00.
      final clock = FakeClock(DateTime(2026, 5, 13, 14));
      await ScheduleWeeklyReviewReminder(scheduler: scheduler, clock: clock)
          .call();
      expect(scheduler.scheduled.single.id, weeklyReviewReminderId);
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 15, 16));
      expect(scheduler.scheduled.single.repeat, ScheduleRepeat.weekly);
      final p =
          NotificationPayload.tryDecode(scheduler.scheduled.single.payload)!;
      expect(p.kind, NotificationKind.weeklyReview);
      expect(p.itemId, isNull);
      expect(p.title, scheduler.scheduled.single.title);
    });

    test('jumps a week when called Friday after 4 PM', () async {
      final clock = FakeClock(DateTime(2026, 5, 15, 17));
      await ScheduleWeeklyReviewReminder(scheduler: scheduler, clock: clock)
          .call();
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 22, 16));
    });
  });

  group('ScheduleBackupReminder', () {
    test('books next Sunday 09:00', () async {
      final clock = FakeClock(DateTime(2026, 5, 14, 9)); // Thursday
      await ScheduleBackupReminder(scheduler: scheduler, clock: clock).call();
      expect(scheduler.scheduled.single.id, backupReminderId);
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 17, 9));
      expect(scheduler.scheduled.single.repeat, ScheduleRepeat.weekly);
      final p =
          NotificationPayload.tryDecode(scheduler.scheduled.single.payload)!;
      expect(p.kind, NotificationKind.backup);
      expect(p.itemId, isNull);
      expect(p.title, scheduler.scheduled.single.title);
    });
  });

  test('CancelWeeklyReviewReminder cancels its specific id', () async {
    await CancelWeeklyReviewReminder(scheduler: scheduler).call();
    expect(scheduler.cancelled, [weeklyReviewReminderId]);
  });

  test('CancelBackupReminder cancels its specific id', () async {
    await CancelBackupReminder(scheduler: scheduler).call();
    expect(scheduler.cancelled, [backupReminderId]);
  });
}
