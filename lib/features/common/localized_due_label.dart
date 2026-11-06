import 'package:intl/intl.dart';

import '../../core/due_status.dart';
import '../../l10n/gen/app_localizations.dart';
import 'localized_dates.dart';

/// Preserve calendar-day classification and the date-only midnight convention,
/// while displaying every date/time in the selected app language.
String localizedDueChipLabel(
  DateTime dueAt,
  DateTime now,
  AppLocalizations l10n,
) {
  final status = dueStatusOf(dueAt, now);
  final hasTime = dueAt.hour != 0 || dueAt.minute != 0;
  switch (status.phase) {
    case DuePhase.overdue:
      return l10n.dueOverdueDays(status.dayDelta.abs());
    case DuePhase.today:
      return hasTime
          ? l10n.dueTodayAt(DateFormat.jm(l10n.dateLocaleName).format(dueAt))
          : l10n.dueToday;
    case DuePhase.upcoming:
      final format = DateFormat.MMMd(l10n.dateLocaleName);
      return (hasTime ? format.add_jm() : format).format(dueAt);
  }
}
