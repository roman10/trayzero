import 'package:intl/intl.dart';

/// Where an item's due date sits relative to "now", in GTD terms.
///
/// [overdue] means the due *day* has already passed and the item needs a
/// conscious re-decision (reschedule / complete / drop). [today] and
/// [upcoming] are still on the hard landscape and shown subtly.
enum DuePhase { overdue, today, upcoming }

class DueStatus {
  /// Whole-day difference: due day − today (negative when overdue).
  final int dayDelta;
  final DuePhase phase;

  const DueStatus(this.phase, this.dayDelta);
}

/// Floors to midnight as a *UTC* date. Using UTC (not local) keeps
/// `difference().inDays` an exact 24h multiple, so the day delta and phase
/// stay correct across daylight-saving transitions, where two local
/// midnights can be 23h or 25h apart and `inDays` would truncate wrong.
DateTime _floor(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Classify [dueAt] against [now] on a calendar-day basis.
///
/// Comparison is date-floored so a due time earlier *today* (or exactly now)
/// reads as [DuePhase.today], not overdue — only a due date strictly before
/// today's date is [DuePhase.overdue]. [now] is injected (from the app clock)
/// so callers and tests stay deterministic.
DueStatus dueStatusOf(DateTime dueAt, DateTime now) {
  final dueDay = _floor(dueAt);
  final today = _floor(now);
  final delta = dueDay.difference(today).inDays;
  if (delta < 0) return DueStatus(DuePhase.overdue, delta);
  if (delta == 0) return const DueStatus(DuePhase.today, 0);
  return DueStatus(DuePhase.upcoming, delta);
}

/// Chip label for a due date: "Overdue · 3d" when past, "Due today" for
/// today, otherwise a compact month/day (e.g. "May 20"). When a time of
/// day is set it is appended (e.g. "Due today, 3:30 PM", "May 20, 3:30 PM").
/// Midnight is treated as "no time" — date-only imports (e.g. Google Tasks)
/// land at 00:00, so a bare date stays a bare date.
String dueChipLabel(DateTime dueAt, DateTime now) {
  final s = dueStatusOf(dueAt, now);
  final hasTime = dueAt.hour != 0 || dueAt.minute != 0;
  final time = hasTime ? ', ${DateFormat.jm().format(dueAt)}' : '';
  switch (s.phase) {
    case DuePhase.overdue:
      return 'Overdue · ${s.dayDelta.abs()}d';
    case DuePhase.today:
      return 'Due today$time';
    case DuePhase.upcoming:
      return '${DateFormat.MMMd().format(dueAt)}$time';
  }
}
