import 'package:intl/intl.dart';

import '../../l10n/gen/app_localizations.dart';

extension LocalizedDateLocale on AppLocalizations {
  /// intl has zh_TW date symbols, but no zh_Hant symbols. Its automatic
  /// language fallback would display Simplified Chinese weekdays instead.
  String get dateLocaleName => localeName == 'zh_Hant' ? 'zh_TW' : localeName;
}

/// True when [d] is exactly local midnight, the convention for a date-only
/// value (no time of day chosen).
bool isStartOfDay(DateTime d) =>
    d.hour == 0 &&
    d.minute == 0 &&
    d.second == 0 &&
    d.millisecond == 0 &&
    d.microsecond == 0;

/// Defer/start date for display: weekday + month + day (year only when it
/// isn't the current one), plus the time only when one was actually chosen.
/// A midnight value reads as "Fri, Jun 5", never "Fri, Jun 5, 12:00 AM".
String localizedDeferLabel(
  DateTime d,
  AppLocalizations l10n, {
  DateTime? now,
}) {
  final sameYear = d.year == (now ?? DateTime.now()).year;
  final format = sameYear
      ? DateFormat.MMMEd(l10n.dateLocaleName)
      : DateFormat.yMMMEd(l10n.dateLocaleName);
  return (isStartOfDay(d) ? format : format.add_jm()).format(d);
}
