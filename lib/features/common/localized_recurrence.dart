import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import 'localized_entity_labels.dart';
import 'localized_dates.dart';

/// DateTime uses Monday=1; January 1, 2024 was a Monday. Formatting a date
/// avoids assuming that intl's locale-specific weekday arrays start on Monday.
String localizedWeekday(
  int weekday,
  AppLocalizations l10n, {
  bool short = false,
}) {
  return DateFormat(
    short ? 'E' : 'EEEE',
    l10n.dateLocaleName,
  ).format(DateTime(2024, 1, weekday));
}

String localizedMonthlyOrdinal(int week, AppLocalizations l10n) =>
    switch (week) {
      1 => l10n.repeatFirst,
      2 => l10n.repeatSecond,
      3 => l10n.repeatThird,
      4 => l10n.repeatFourth,
      5 => l10n.repeatFifth,
      -1 => l10n.repeatLast,
      _ => throw ArgumentError.value(week, 'week'),
    };

String _ordinalKey(int week) => switch (week) {
  1 => 'first',
  2 => 'second',
  3 => 'third',
  4 => 'fourth',
  5 => 'fifth',
  -1 => 'last',
  _ => throw ArgumentError.value(week, 'week'),
};

extension LocalizedRecurrenceInterval on Recurrence {
  String localizedInterval(AppLocalizations l10n, int count) => switch (this) {
    Recurrence.daily => l10n.repeatEveryDays(count),
    Recurrence.weekly => l10n.repeatEveryWeeks(count),
    Recurrence.monthly => l10n.repeatEveryMonths(count),
    Recurrence.yearly => l10n.repeatEveryYears(count),
  };
}

extension LocalizedRecurrenceRule on RecurrenceRule {
  String localizedShortLabel(AppLocalizations l10n) => interval == 1
      ? frequency.localizedLabel(l10n)
      : frequency.localizedInterval(l10n, interval);

  String localizedDescription(AppLocalizations l10n) {
    final cadence = frequency.localizedInterval(l10n, interval);
    switch (frequency) {
      case Recurrence.daily:
      case Recurrence.yearly:
        return cadence;
      case Recurrence.weekly:
        if (byWeekdays.isEmpty) return cadence;
        final days = (byWeekdays.toList()..sort())
            .map((day) => localizedWeekday(day, l10n, short: true))
            .join(l10n.weekdayListSeparator);
        return l10n.recurrenceOnWeekdays(cadence, days);
      case Recurrence.monthly:
        if (monthlyMode == MonthlyMode.dayOfMonth) return cadence;
        return l10n.recurrenceOnNthWeekday(
          cadence,
          _ordinalKey(monthlyWeek!),
          localizedWeekday(monthlyWeekday!, l10n),
        );
    }
  }
}

extension LocalizedItemRecurrence on Item {
  String localizedRecurrenceSummary(AppLocalizations l10n) {
    final pattern = recurrenceRule!.localizedDescription(l10n);
    if (recurrenceCount != null) {
      return l10n.recurrenceCountSummary(pattern, recurrenceCount!);
    }
    if (recurrenceUntil != null) {
      return l10n.recurrenceUntilSummary(
        pattern,
        DateFormat.yMMMd(l10n.dateLocaleName).format(recurrenceUntil!),
      );
    }
    return pattern;
  }
}
