import 'package:cleartray/application/schedule_weekly_review_reminder.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationScheduler scheduler;

  setUp(() {
    scheduler = FakeNotificationScheduler();
  });

  group('ScheduleWeeklyReviewReminder', () {
    test('books the next Friday at 16:00 from mid-week', () async {
      final clock = FakeClock(DateTime(2026, 5, 13, 14)); // Wednesday
      await ScheduleWeeklyReviewReminder(scheduler: scheduler, clock: clock)
          .call();
      expect(scheduler.scheduled.single.id, weeklyReviewReminderId);
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 15, 16));
      expect(scheduler.scheduled.single.title, contains('Weekly review'));
      // Must repeat weekly — a one-shot fired once and went silent forever.
      expect(scheduler.scheduled.single.repeat, ScheduleRepeat.weekly);
    });

    test('keeps the same Friday when called Friday before 16:00', () async {
      final clock = FakeClock(DateTime(2026, 5, 15, 9)); // Friday morning
      await ScheduleWeeklyReviewReminder(scheduler: scheduler, clock: clock)
          .call();
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 15, 16));
    });

    test('jumps a week when called Friday after 16:00', () async {
      final clock = FakeClock(DateTime(2026, 5, 15, 17)); // Friday evening
      await ScheduleWeeklyReviewReminder(scheduler: scheduler, clock: clock)
          .call();
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 22, 16));
    });
  });

  group('CancelWeeklyReviewReminder', () {
    test('cancels exactly the weekly review reminder id', () async {
      await CancelWeeklyReviewReminder(scheduler: scheduler).call();
      expect(scheduler.cancelled, [weeklyReviewReminderId]);
      expect(scheduler.scheduled, isEmpty);
    });
  });
}
