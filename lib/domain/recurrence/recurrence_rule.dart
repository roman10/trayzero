import '../entities/enums.dart';

/// Short weekday names keyed by `DateTime.monday`(1)..`DateTime.sunday`(7).
const _weekdayShort = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

/// Full weekday names, same 1..7 keying. Used by the nth-weekday phrasing.
const _weekdayFull = {
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday',
};

/// Ordinal words for the monthly nth-weekday qualifier; -1 is "last".
const _weekOrdinal = {
  1: 'first',
  2: 'second',
  3: 'third',
  4: 'fourth',
  5: 'fifth',
  -1: 'last',
};

/// How a *monthly* recurrence picks its day.
enum MonthlyMode {
  /// Same day-of-month as the anchor (clamped for short months).
  dayOfMonth,

  /// The Nth weekday of the month, e.g. "2nd Tuesday", "last Friday".
  nthWeekday,
}

/// Structured recurrence pattern. Pure value object with no storage or IO
/// concerns: it is assembled from an [Item]'s flat columns by
/// `Item.recurrenceRule` and is the single place the *date math* lives, so
/// the rollover policy and (later) calendar RRULE export share one
/// definition of "when does this repeat".
///
/// Only the qualifier relevant to [frequency] is honoured:
/// - weekly  → [byWeekdays] (empty = repeat on the anchor's own weekday)
/// - monthly → [monthlyWeek] + [monthlyWeekday] (both null = day-of-month)
/// - daily / yearly carry no qualifier.
class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.byWeekdays = const {},
    this.monthlyWeek,
    this.monthlyWeekday,
  });

  final Recurrence frequency;
  final int interval;

  /// Weekly only. Weekdays the task repeats on, `DateTime.monday`(1) ..
  /// `DateTime.sunday`(7). Empty means "same weekday as the anchor date",
  /// which is the original weekly behaviour.
  final Set<int> byWeekdays;

  /// Monthly nth-weekday only. 1..5, or -1 for "last". Null selects
  /// [MonthlyMode.dayOfMonth].
  final int? monthlyWeek;

  /// Monthly nth-weekday only. `DateTime.monday`..`DateTime.sunday`. Paired
  /// with [monthlyWeek].
  final int? monthlyWeekday;

  MonthlyMode get monthlyMode =>
      monthlyWeek != null && monthlyWeekday != null
          ? MonthlyMode.nthWeekday
          : MonthlyMode.dayOfMonth;

  /// Plain-English description of the cadence and pattern, e.g.
  /// "Every 2 weeks on Mon, Wed" or "Every month on the last Friday".
  ///
  /// Covers frequency, interval and the structured qualifier only; the end
  /// condition lives on [Item] (it has no date math) and is composed by the
  /// caller. Pure and free of `intl` so it stays unit-testable in the domain.
  String describe() {
    final unit =
        interval == 1 ? frequency.unitNoun : '${frequency.unitNoun}s';
    final every =
        interval == 1 ? 'Every ${frequency.unitNoun}' : 'Every $interval $unit';
    switch (frequency) {
      case Recurrence.daily:
      case Recurrence.yearly:
        return every;
      case Recurrence.weekly:
        if (byWeekdays.isEmpty) return every;
        final days = (byWeekdays.toList()..sort())
            .map((d) => _weekdayShort[d]!)
            .join(', ');
        return '$every on $days';
      case Recurrence.monthly:
        if (monthlyMode == MonthlyMode.dayOfMonth) return every;
        return '$every on the ${_weekOrdinal[monthlyWeek!]!} '
            '${_weekdayFull[monthlyWeekday!]!}';
    }
  }

  /// Terse cadence label with no structured qualifier, for chips and other
  /// compact surfaces: "Daily", "Every 2 weeks", "Monthly". The sentence
  /// form (with weekday / nth-weekday clauses) is [describe].
  String get shortLabel => interval == 1
      ? frequency.label
      : 'Every $interval ${frequency.unitNoun}s';

  /// The first occurrence strictly after [base], preserving its time of day.
  DateTime nextAfter(DateTime base) => switch (frequency) {
        Recurrence.daily => base.add(Duration(days: interval)),
        Recurrence.weekly => _nextWeekly(base),
        Recurrence.monthly => monthlyMode == MonthlyMode.nthWeekday
            ? _nthWeekdayInShiftedMonth(base)
            : shiftMonths(base, interval),
        Recurrence.yearly => shiftMonths(base, 12 * interval),
      };

  DateTime _nextWeekly(DateTime base) {
    if (byWeekdays.isEmpty) {
      return base.add(Duration(days: 7 * interval));
    }
    final sorted = byWeekdays.toList()..sort();
    // A selected weekday still ahead in the current Mon–Sun week.
    for (final w in sorted) {
      if (w > base.weekday) {
        return base.add(Duration(days: w - base.weekday));
      }
    }
    // None left this week: jump to the first selected weekday in the week
    // `interval` weeks ahead (Monday-aligned blocks, matching RRULE).
    final daysToBlockStart = (8 - base.weekday) + (interval - 1) * 7;
    return base.add(Duration(days: daysToBlockStart + (sorted.first - 1)));
  }

  DateTime _nthWeekdayInShiftedMonth(DateTime base) {
    final total = base.month - 1 + interval;
    final year = base.year + total ~/ 12;
    final month = total % 12 + 1;
    return _nthWeekdayOf(
      year,
      month,
      monthlyWeekday!,
      monthlyWeek!,
      base.hour,
      base.minute,
    );
  }
}

/// Resolve the [nth] [weekday] of [year]/[month]. [nth] is 1..5 or -1
/// ("last"). When a positive [nth] does not exist in the month (e.g. a 5th
/// Tuesday), the last occurrence is used so the series never skips a month.
DateTime _nthWeekdayOf(
  int year,
  int month,
  int weekday,
  int nth,
  int hour,
  int minute,
) {
  final firstWeekday = DateTime(year, month, 1).weekday;
  final offset = (weekday - firstWeekday + 7) % 7;
  final firstOccurrence = 1 + offset;
  final lastDay = DateTime(year, month + 1, 0).day;
  final lastOccurrence =
      firstOccurrence + ((lastDay - firstOccurrence) ~/ 7) * 7;
  final day = nth == -1
      ? lastOccurrence
      : (() {
          final d = firstOccurrence + (nth - 1) * 7;
          return d > lastDay ? lastOccurrence : d;
        })();
  return DateTime(year, month, day, hour, minute);
}

/// Advance [base] by [months] calendar months, clamping the day-of-month so
/// it never overflows into the following month.
///
/// Dart's `DateTime` constructor silently normalises out-of-range days
/// (`DateTime(2026, 2, 31)` becomes 2026-03-03), which would push a
/// month-end recurring task off its intended month entirely. Instead we
/// clamp to the target month's last valid day: Jan 31 monthly → Feb 28
/// (or 29), Feb 29 yearly → Feb 28 in non-leap years.
DateTime shiftMonths(DateTime base, int months) {
  final total = base.month - 1 + months;
  final year = base.year + total ~/ 12;
  final month = total % 12 + 1;
  // Day 0 of the next month resolves to the last day of [month].
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = base.day < lastDay ? base.day : lastDay;
  return DateTime(year, month, day, base.hour, base.minute);
}
