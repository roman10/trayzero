/// When a deferred item's "Ready:" reminder should actually fire.
///
/// `deferUntil` plays two roles: it gates list visibility (an item is hidden
/// from Next Actions until `deferUntil <= now`) and it anchors the "Ready:"
/// notification. For a *no-time* defer we want the item visible from the
/// start of its day but the nudge to arrive at a humane configured hour, so
/// the two are decoupled here.
///
/// Heuristic: a `deferUntil` at local midnight is, by construction, a no-time
/// defer (only the inbox-triage date picker produces start-of-day values) and
/// is shifted to [surfaceMinutes] minutes past midnight on the same day. Any
/// other `deferUntil` carries an explicit time the user chose (e.g. from the
/// item-edit date+time picker) and is returned unchanged.
DateTime deferReminderAt(DateTime deferUntil, int surfaceMinutes) {
  final isStartOfDay = deferUntil.hour == 0 &&
      deferUntil.minute == 0 &&
      deferUntil.second == 0 &&
      deferUntil.millisecond == 0 &&
      deferUntil.microsecond == 0;
  if (!isStartOfDay) return deferUntil;
  return DateTime(
    deferUntil.year,
    deferUntil.month,
    deferUntil.day,
    surfaceMinutes ~/ 60,
    surfaceMinutes % 60,
  );
}
