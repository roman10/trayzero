import 'package:cleartray/domain/entities/enums.dart';
import 'package:cleartray/domain/recurrence/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('daily / yearly (no qualifier)', () {
    test('daily advances by interval days, preserving time', () {
      const r = RecurrenceRule(frequency: Recurrence.daily, interval: 3);
      expect(r.nextAfter(DateTime(2026, 5, 14, 9, 30)),
          DateTime(2026, 5, 17, 9, 30));
    });

    test('yearly clamps Feb 29 to Feb 28 in non-leap years', () {
      const r = RecurrenceRule(frequency: Recurrence.yearly);
      expect(r.nextAfter(DateTime(2028, 2, 29, 8)), DateTime(2029, 2, 28, 8));
    });
  });

  group('weekly', () {
    test('with no weekdays falls back to +7*interval days', () {
      const r = RecurrenceRule(frequency: Recurrence.weekly, interval: 2);
      expect(r.nextAfter(DateTime(2026, 5, 14)),
          DateTime(2026, 5, 14).add(const Duration(days: 14)));
    });

    test('picks the next selected weekday later in the same week', () {
      // Mon/Wed/Fri, anchored on Wed 2026-05-13 → next is Fri 2026-05-15.
      const r = RecurrenceRule(
        frequency: Recurrence.weekly,
        byWeekdays: {
          DateTime.monday,
          DateTime.wednesday,
          DateTime.friday
        },
      );
      final wed = DateTime(2026, 5, 13, 8);
      expect(wed.weekday, DateTime.wednesday);
      expect(r.nextAfter(wed), DateTime(2026, 5, 15, 8));
    });

    test('wraps to the first selected weekday next week', () {
      // From Fri, with Mon/Wed/Fri selected, interval 1 → next Monday.
      const r = RecurrenceRule(
        frequency: Recurrence.weekly,
        byWeekdays: {
          DateTime.monday,
          DateTime.wednesday,
          DateTime.friday
        },
      );
      final fri = DateTime(2026, 5, 15);
      expect(fri.weekday, DateTime.friday);
      expect(r.nextAfter(fri), DateTime(2026, 5, 18)); // Mon
    });

    test('interval > 1 skips whole weeks when wrapping', () {
      const r = RecurrenceRule(
        frequency: Recurrence.weekly,
        interval: 2,
        byWeekdays: {DateTime.monday},
      );
      // From Mon 05-11, only Mondays selected → 2 weeks later.
      final mon = DateTime(2026, 5, 11);
      expect(mon.weekday, DateTime.monday);
      expect(r.nextAfter(mon), DateTime(2026, 5, 25));
    });
  });

  group('monthly', () {
    test('day-of-month mode clamps short months (Jan 31 -> Feb 28)', () {
      const r = RecurrenceRule(frequency: Recurrence.monthly);
      expect(r.nextAfter(DateTime(2026, 1, 31, 9)),
          DateTime(2026, 2, 28, 9));
    });

    test('nth-weekday: 2nd Tuesday of next month', () {
      const r = RecurrenceRule(
        frequency: Recurrence.monthly,
        monthlyWeek: 2,
        monthlyWeekday: DateTime.tuesday,
      );
      // From any May 2026 date → 2nd Tuesday of June 2026 is the 9th.
      final next = r.nextAfter(DateTime(2026, 5, 20, 7, 15));
      expect(next, DateTime(2026, 6, 9, 7, 15));
      expect(next.weekday, DateTime.tuesday);
    });

    test('nth-weekday: last Friday of next month', () {
      const r = RecurrenceRule(
        frequency: Recurrence.monthly,
        monthlyWeek: -1,
        monthlyWeekday: DateTime.friday,
      );
      // Last Friday of June 2026 is the 26th.
      final next = r.nextAfter(DateTime(2026, 5, 1));
      expect(next, DateTime(2026, 6, 26));
      expect(next.weekday, DateTime.friday);
    });

    test('nth-weekday falls back to last when the Nth does not exist', () {
      // 5th Monday of June 2026 does not exist (only 5 Mondays in some
      // months); expect the last Monday (June 29, 2026).
      const r = RecurrenceRule(
        frequency: Recurrence.monthly,
        monthlyWeek: 5,
        monthlyWeekday: DateTime.monday,
      );
      final next = r.nextAfter(DateTime(2026, 5, 2));
      expect(next.month, 6);
      expect(next.weekday, DateTime.monday);
      expect(next, DateTime(2026, 6, 29));
    });

    test('nth-weekday respects interval (skip a month)', () {
      const r = RecurrenceRule(
        frequency: Recurrence.monthly,
        interval: 2,
        monthlyWeek: 1,
        monthlyWeekday: DateTime.monday,
      );
      // From May → +2 months = July 2026; 1st Monday is the 6th.
      expect(r.nextAfter(DateTime(2026, 5, 10)), DateTime(2026, 7, 6));
    });
  });

  group('describe', () {
    test('daily / yearly: bare cadence, singular vs plural', () {
      expect(const RecurrenceRule(frequency: Recurrence.daily).describe(),
          'Every day');
      expect(
          const RecurrenceRule(frequency: Recurrence.daily, interval: 3)
              .describe(),
          'Every 3 days');
      expect(const RecurrenceRule(frequency: Recurrence.yearly).describe(),
          'Every year');
    });

    test('weekly: empty weekdays omit the "on" clause', () {
      expect(
          const RecurrenceRule(frequency: Recurrence.weekly, interval: 2)
              .describe(),
          'Every 2 weeks');
    });

    test('weekly: selected weekdays listed Mon-first', () {
      expect(
          const RecurrenceRule(
            frequency: Recurrence.weekly,
            byWeekdays: {DateTime.friday, DateTime.monday},
          ).describe(),
          'Every week on Mon, Fri');
    });

    test('monthly day-of-month: no qualifier clause', () {
      expect(const RecurrenceRule(frequency: Recurrence.monthly).describe(),
          'Every month');
    });

    test('monthly nth-weekday: ordinal + full weekday, "last" for -1', () {
      expect(
          const RecurrenceRule(
            frequency: Recurrence.monthly,
            monthlyWeek: 2,
            monthlyWeekday: DateTime.tuesday,
          ).describe(),
          'Every month on the second Tuesday');
      expect(
          const RecurrenceRule(
            frequency: Recurrence.monthly,
            interval: 3,
            monthlyWeek: -1,
            monthlyWeekday: DateTime.friday,
          ).describe(),
          'Every 3 months on the last Friday');
    });
  });

  group('shortLabel', () {
    test('interval 1 uses the bare cadence word', () {
      expect(const RecurrenceRule(frequency: Recurrence.daily).shortLabel,
          'Daily');
      expect(const RecurrenceRule(frequency: Recurrence.weekly).shortLabel,
          'Weekly');
      expect(const RecurrenceRule(frequency: Recurrence.monthly).shortLabel,
          'Monthly');
      expect(const RecurrenceRule(frequency: Recurrence.yearly).shortLabel,
          'Yearly');
    });

    test('interval > 1 uses "Every N units" and pluralises', () {
      expect(
          const RecurrenceRule(frequency: Recurrence.weekly, interval: 2)
              .shortLabel,
          'Every 2 weeks');
      expect(
          const RecurrenceRule(frequency: Recurrence.daily, interval: 3)
              .shortLabel,
          'Every 3 days');
    });

    test('omits the structured qualifier (unlike describe)', () {
      const rule = RecurrenceRule(
        frequency: Recurrence.weekly,
        byWeekdays: {DateTime.monday, DateTime.friday},
      );
      expect(rule.shortLabel, 'Weekly');
      expect(rule.describe(), 'Every week on Mon, Fri');
    });
  });

  // Calendar-day arithmetic across US DST boundaries (2026-03-08 spring
  // forward, 2026-11-01 fall back). These pass trivially under UTC; run with
  // `TZ=America/New_York flutter test test/domain/recurrence_rule_test.dart`
  // to exercise the transitions — fixed 24h `Duration` math fails there.
  group('DST boundaries keep wall-clock date and time', () {
    void expectWallClock(DateTime actual, DateTime expected) {
      expect(
        [actual.year, actual.month, actual.day, actual.hour, actual.minute],
        [
          expected.year,
          expected.month,
          expected.day,
          expected.hour,
          expected.minute,
        ],
      );
    }

    test('untimed daily item across fall back lands on the next midnight',
        () {
      const r = RecurrenceRule(frequency: Recurrence.daily);
      final first = r.nextAfter(DateTime(2026, 10, 31));
      expectWallClock(first, DateTime(2026, 11, 1));
      // The drift must not persist into the following occurrences.
      expectWallClock(r.nextAfter(first), DateTime(2026, 11, 2));
    });

    test('timed daily item across spring forward keeps 9:00', () {
      const r = RecurrenceRule(frequency: Recurrence.daily);
      expectWallClock(
          r.nextAfter(DateTime(2026, 3, 7, 9)), DateTime(2026, 3, 8, 9));
      expectWallClock(
          r.nextAfter(DateTime(2026, 3, 8, 9)), DateTime(2026, 3, 9, 9));
    });

    test('weekly with no weekdays across fall back keeps weekday', () {
      const r = RecurrenceRule(frequency: Recurrence.weekly);
      final next = r.nextAfter(DateTime(2026, 10, 28));
      expectWallClock(next, DateTime(2026, 11, 4));
      expect(next.weekday, DateTime.wednesday);
    });

    test('weekly by weekday across spring forward lands on that weekday',
        () {
      // Fri 2026-03-06 → next Monday 2026-03-09, crossing Sun 03-08.
      const r = RecurrenceRule(
        frequency: Recurrence.weekly,
        byWeekdays: {DateTime.monday, DateTime.friday},
      );
      final next = r.nextAfter(DateTime(2026, 3, 6));
      expectWallClock(next, DateTime(2026, 3, 9));
      expect(next.weekday, DateTime.monday);
    });

    test('weekly by weekday later in the week across fall back', () {
      // Sat 2026-10-31 → Sun 2026-11-01 (same Mon–Sun week), crossing the
      // fall-back transition that night.
      const r = RecurrenceRule(
        frequency: Recurrence.weekly,
        byWeekdays: {DateTime.sunday},
      );
      final next = r.nextAfter(DateTime(2026, 10, 31));
      expectWallClock(next, DateTime(2026, 11, 1));
      expect(next.weekday, DateTime.sunday);
    });

    test('UTC bases stay UTC', () {
      const r = RecurrenceRule(frequency: Recurrence.daily);
      final next = r.nextAfter(DateTime.utc(2026, 10, 31, 23));
      expect(next, DateTime.utc(2026, 11, 1, 23));
      expect(next.isUtc, isTrue);
    });
  });
}
