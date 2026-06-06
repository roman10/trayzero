import 'package:cleartray/core/due_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final now = DateTime(2026, 5, 16, 12);
  // intl's jm() separates the AM/PM with a narrow no-break space (U+202F),
  // not a plain space, so build expectations through the same formatter.
  String at(DateTime d) => DateFormat.jm().format(d);

  test('a past date is overdue with the absolute day delta', () {
    final s = dueStatusOf(DateTime(2026, 5, 15, 9), now);
    expect(s.phase, DuePhase.overdue);
    expect(s.dayDelta.abs(), 1);
    expect(dueChipLabel(DateTime(2026, 5, 15, 9), now), 'Overdue · 1d');
  });

  test('earlier today is "today", not overdue', () {
    final s = dueStatusOf(DateTime(2026, 5, 16, 8), now);
    expect(s.phase, DuePhase.today);
    expect(dueChipLabel(DateTime(2026, 5, 16, 8), now),
        'Due today, ${at(DateTime(2026, 5, 16, 8))}');
  });

  test('a set time of day is appended to the chip label', () {
    final today = DateTime(2026, 5, 16, 15, 30);
    final future = DateTime(2026, 5, 20, 9, 5);
    expect(dueChipLabel(today, now), 'Due today, ${at(today)}');
    expect(dueChipLabel(future, now), 'May 20, ${at(future)}');
  });

  test('midnight is treated as no time (date-only stays bare)', () {
    expect(dueChipLabel(DateTime(2026, 5, 16), now), 'Due today');
    expect(dueChipLabel(DateTime(2026, 5, 20), now), 'May 20');
  });

  test('exactly now is "today"', () {
    expect(dueStatusOf(now, now).phase, DuePhase.today);
  });

  test('a future date is upcoming with a compact label', () {
    final due = DateTime(2026, 5, 17, 9);
    expect(dueStatusOf(due, now).phase, DuePhase.upcoming);
    expect(dueChipLabel(due, now), 'May 17, ${at(due)}');
  });

  test('30 days overdue', () {
    final due = DateTime(2026, 4, 16, 12);
    expect(dueChipLabel(due, now), 'Overdue · 30d');
  });

  test('day delta spans year boundaries', () {
    final s = dueStatusOf(DateTime(2025, 12, 31), DateTime(2026, 1, 2));
    expect(s.phase, DuePhase.overdue);
    expect(s.dayDelta.abs(), 2);
  });

  test('day delta is exact across a DST transition', () {
    // US spring-forward is 2026-03-08. Two calendar days span it; local
    // midnights are only 47h apart, which truncates to 1 with naive
    // Duration.inDays. UTC flooring keeps this an exact 2.
    final s = dueStatusOf(DateTime(2026, 3, 7), DateTime(2026, 3, 9));
    expect(s.phase, DuePhase.overdue);
    expect(s.dayDelta.abs(), 2);
  });
}
