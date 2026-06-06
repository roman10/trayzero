import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/application/calendar_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  test('non-recurring item maps to null', () {
    expect(calendarRecurrenceOf(anItem(title: 'x')), isNull);
  });

  test('daily with interval maps frequency + interval', () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.daily,
      recurrenceInterval: 3,
    ))!;
    expect(r.frequency, CalendarFrequency.daily);
    expect(r.interval, 3);
  });

  test('weekly carries sorted by-weekdays', () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.weekly,
      recurrenceByWeekdays: const [5, 1, 3],
    ))!;
    expect(r.frequency, CalendarFrequency.weekly);
    expect(r.byWeekdays, const [1, 3, 5]);
  });

  test('monthly Nth-weekday carries week + weekday', () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.monthly,
      recurrenceMonthlyWeek: -1,
      recurrenceMonthlyWeekday: DateTime.friday,
    ))!;
    expect(r.frequency, CalendarFrequency.monthly);
    expect(r.monthlyWeek, -1);
    expect(r.monthlyWeekday, DateTime.friday);
  });

  test('monthly day-of-month leaves the Nth fields null', () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.monthly,
    ))!;
    expect(r.monthlyWeek, isNull);
    expect(r.monthlyWeekday, isNull);
  });

  test('end conditions map to until / count (mutually exclusive)', () {
    final untilR = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.daily,
      recurrenceUntil: DateTime(2026, 12, 31),
    ))!;
    expect(untilR.until, DateTime(2026, 12, 31));
    expect(untilR.count, isNull);

    final countR = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.daily,
      recurrenceCount: 10,
    ))!;
    expect(countR.count, 10);
    expect(countR.until, isNull);
  });

  test('count exports the remaining occurrences from the live instance', () {
    // 4-times weekly, two already done: the carried event is re-anchored to
    // the live instance, so it must represent only the 2 that remain — not
    // the original 4 (which would never let the series terminate).
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.weekly,
      recurrenceCount: 4,
      recurrenceDoneCount: 2,
    ))!;
    expect(r.count, 2);
  });

  test('count floors at 1 when the series is over-completed', () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.daily,
      recurrenceCount: 3,
      recurrenceDoneCount: 5,
    ))!;
    expect(r.count, 1);
  });

  test('count of zero (corrupt/imported data) degrades to 1, not a crash',
      () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.daily,
      recurrenceCount: 0,
    ))!;
    expect(r.count, 1);
  });

  test('count is the full total before any occurrence is done', () {
    final r = calendarRecurrenceOf(anItem(
      title: 'x',
      recurrence: Recurrence.daily,
      recurrenceCount: 7,
    ))!;
    expect(r.count, 7);
  });
}
