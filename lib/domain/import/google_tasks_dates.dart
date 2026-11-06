/// Google Tasks `due` is a calendar date encoded as an RFC3339 timestamp,
/// not an instant. Read its written date before any timezone conversion.
/// https://developers.google.com/workspace/tasks/reference/rest/v1/tasks
///
/// This applies only to `due`. Takeout's `scheduled_time.start`, creation,
/// update and completion timestamps retain their actual time and offset.
DateTime? parseGoogleTasksDueDate(Object? raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T|$)').firstMatch(value);
  if (date == null || DateTime.tryParse(value) == null) return null;
  final year = int.parse(date.group(1)!);
  final month = int.parse(date.group(2)!);
  final day = int.parse(date.group(3)!);
  // DateTime.parse normalizes overflowing dates; reject them instead of
  // silently importing February 30 as a day in March.
  final checked = DateTime.utc(year, month, day);
  if (checked.year != year || checked.month != month || checked.day != day) {
    return null;
  }
  return DateTime(year, month, day);
}
