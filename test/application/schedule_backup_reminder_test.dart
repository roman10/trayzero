import 'package:cleartray/application/schedule_backup_reminder.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationScheduler scheduler;

  setUp(() {
    scheduler = FakeNotificationScheduler();
  });

  group('ScheduleBackupReminder', () {
    test('books the next Sunday at 09:00 from a weekday', () async {
      final clock = FakeClock(DateTime(2026, 5, 14, 9)); // Thursday
      await ScheduleBackupReminder(scheduler: scheduler, clock: clock).call();
      expect(scheduler.scheduled.single.id, backupReminderId);
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 17, 9));
      expect(scheduler.scheduled.single.title, contains('Back up'));
      // Must repeat weekly — a one-shot fired once and went silent forever.
      expect(scheduler.scheduled.single.repeat, ScheduleRepeat.weekly);
    });

    test('jumps to the following Sunday when called Sunday after 09:00',
        () async {
      final clock = FakeClock(DateTime(2026, 5, 17, 10)); // Sunday
      await ScheduleBackupReminder(scheduler: scheduler, clock: clock).call();
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 24, 9));
    });

    test('keeps the same Sunday when called Sunday before 09:00', () async {
      final clock = FakeClock(DateTime(2026, 5, 17, 7)); // Sunday early
      await ScheduleBackupReminder(scheduler: scheduler, clock: clock).call();
      expect(scheduler.scheduled.single.at, DateTime(2026, 5, 17, 9));
    });
  });

  group('CancelBackupReminder', () {
    test('cancels exactly the backup reminder id', () async {
      await CancelBackupReminder(scheduler: scheduler).call();
      expect(scheduler.cancelled, [backupReminderId]);
      expect(scheduler.scheduled, isEmpty);
    });
  });
}
