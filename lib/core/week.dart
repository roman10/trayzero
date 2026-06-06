/// Midnight (local) on the Monday of the calendar week containing [now].
///
/// Used to scope the Review screen's "Completed this week" list to the
/// current GTD weekly-review cadence — it resets every Monday.
DateTime startOfWeek(DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}
