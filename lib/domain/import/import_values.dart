import '../entities/entities.dart';
import 'import_plan.dart';

/// Field-value readers shared by the import parsers (ADR 0008): dates,
/// repeat rules, and durations. All pure; local time throughout. A date
/// without a time is returned at local midnight, which the import use case
/// treats as "date only".

/// Reads the absolute date forms exports use:
/// `2026-10-28`, `2026/10/28`, `20261028`, `2026-10-28 17:00[:00]`,
/// `2026-10-28 5pm`, `2026-10-28T09:00:00Z`, `…+0800`, `…+08:00`.
/// A value with a UTC offset is converted to local time. Null when
/// unreadable.
DateTime? parseAbsoluteDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final compact = RegExp(r'^(\d{4})(\d{2})(\d{2})$').firstMatch(s);
  if (compact != null) {
    return _validDate(
      int.parse(compact.group(1)!),
      int.parse(compact.group(2)!),
      int.parse(compact.group(3)!),
    );
  }
  final m = RegExp(
    r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})'
    r'(?:[T ](\d{1,2})(?::(\d{2}))?(?::(\d{2})(?:\.\d+)?)?\s*([ap]\.?m\.?)?)?'
    r'\s*(Z|[+-]\d{2}:?\d{2})?$',
    caseSensitive: false,
  ).firstMatch(s);
  if (m == null) return null;
  final date = _validDate(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
  if (date == null) return null;
  if (m.group(4) == null) return date;
  final time = _clockTime(
    int.parse(m.group(4)!),
    int.parse(m.group(5) ?? '0'),
    m.group(7),
  );
  if (time == null) return null;
  final second = int.parse(m.group(6) ?? '0');
  final zone = m.group(8);
  if (zone == null) {
    return DateTime(date.year, date.month, date.day, time.$1, time.$2, second);
  }
  var offset = Duration.zero;
  if (zone.toUpperCase() != 'Z') {
    final digits = zone.replaceAll(':', '');
    final sign = digits.startsWith('-') ? -1 : 1;
    offset = Duration(
      hours: int.parse(digits.substring(1, 3)),
      minutes: int.parse(digits.substring(3, 5)),
    ) * sign;
  }
  return DateTime.utc(
    date.year,
    date.month,
    date.day,
    time.$1,
    time.$2,
    second,
  ).subtract(offset).toLocal();
}

/// Like [parseAbsoluteDate], plus English month-name dates with an optional
/// year and time, as Todoist writes them: `Mar 15`, `15 March 2027`,
/// `Oct 28 2026 5pm`, `Oct 28 at 17:00`. A missing year means [now]'s year,
/// so an overdue task stays overdue instead of jumping a year ahead.
DateTime? parseExportDate(String raw, {required DateTime now}) {
  final absolute = parseAbsoluteDate(raw);
  if (absolute != null) return absolute;
  final s = raw.trim().toLowerCase().replaceAll(',', ' ');
  const time =
      r'(?:\s+(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*([ap]\.?m\.?)?)?';
  final monthFirst = RegExp(
    '^$_months\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?(?:\\s+(\\d{4}))?$time\$',
  ).firstMatch(s);
  final dayFirst = RegExp(
    '^(\\d{1,2})(?:st|nd|rd|th)?\\s+$_months\\.?(?:\\s+(\\d{4}))?$time\$',
  ).firstMatch(s);
  final int month, day;
  final String? year;
  final RegExpMatch m;
  if (monthFirst != null) {
    m = monthFirst;
    month = _monthIndex(m.group(1)!);
    day = int.parse(m.group(2)!);
  } else if (dayFirst != null) {
    m = dayFirst;
    day = int.parse(m.group(1)!);
    month = _monthIndex(m.group(2)!);
  } else {
    return null;
  }
  year = m.group(3);
  final date = _validDate(
    year == null ? now.year : int.parse(year),
    month,
    day,
  );
  if (date == null) return null;
  if (m.group(4) == null) return date;
  // A bare trailing number ("Mar 15 5") is not a time.
  if (m.group(5) == null && m.group(6) == null) return null;
  final t = _clockTime(int.parse(m.group(4)!), int.parse(m.group(5) ?? '0'),
      m.group(6));
  if (t == null) return null;
  return DateTime(date.year, date.month, date.day, t.$1, t.$2);
}

/// True when [d] carries no time of day (see library comment).
bool isDateOnly(DateTime d) =>
    d.hour == 0 &&
    d.minute == 0 &&
    d.second == 0 &&
    d.millisecond == 0 &&
    d.microsecond == 0;

/// An iCalendar RRULE (`FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH`, optionally
/// prefixed `RRULE:`), as TickTick and OmniFocus write them. Returns null
/// when any part has no exact Trayzero equivalent. A `BYMONTHDAY` /
/// `BYMONTH` that merely restates [anchor] is accepted.
ImportedRepeat? parseRRule(String raw, {DateTime? anchor}) {
  var s = raw.trim();
  if (s.toUpperCase().startsWith('RRULE:')) s = s.substring(6);
  if (s.isEmpty) return null;
  final parts = <String, String>{};
  for (final p in s.split(';')) {
    if (p.trim().isEmpty) continue;
    final eq = p.indexOf('=');
    if (eq <= 0) return null;
    parts[p.substring(0, eq).trim().toUpperCase()] =
        p.substring(eq + 1).trim().toUpperCase();
  }
  final frequency = switch (parts.remove('FREQ')) {
    'DAILY' => Recurrence.daily,
    'WEEKLY' => Recurrence.weekly,
    'MONTHLY' => Recurrence.monthly,
    'YEARLY' => Recurrence.yearly,
    _ => null,
  };
  if (frequency == null) return null;
  final interval = int.tryParse(parts.remove('INTERVAL') ?? '1');
  if (interval == null || interval < 1) return null;
  parts.remove('WKST');
  int? count;
  if (parts.containsKey('COUNT')) {
    count = int.tryParse(parts.remove('COUNT')!);
    if (count == null || count < 1) return null;
  }
  DateTime? until;
  if (parts.containsKey('UNTIL')) {
    until = parseAbsoluteDate(parts.remove('UNTIL')!.split('T').first);
    if (until == null) return null;
  }
  final monthDay = parts.remove('BYMONTHDAY');
  if (monthDay != null && (anchor == null || '${anchor.day}' != monthDay)) {
    return null;
  }
  final byMonth = parts.remove('BYMONTH');
  if (byMonth != null && (anchor == null || '${anchor.month}' != byMonth)) {
    return null;
  }
  var weekdays = const <int>[];
  int? monthlyWeek, monthlyWeekday;
  final byDay = parts.remove('BYDAY');
  final setPos = parts.remove('BYSETPOS');
  if (byDay != null) {
    final days = byDay.split(',');
    if (frequency == Recurrence.weekly && setPos == null) {
      final parsed = days.map(_weekdayCode).toList();
      if (parsed.any((d) => d == null)) return null;
      weekdays = (parsed.cast<int>().toSet().toList())..sort();
    } else if (frequency == Recurrence.monthly && days.length == 1) {
      final m = RegExp(r'^([+-]?\d)?([A-Z]{2})$').firstMatch(days.single);
      final weekday = m == null ? null : _weekdayCode(m.group(2)!);
      final nth = int.tryParse(m?.group(1) ?? setPos ?? '');
      if (weekday == null || nth == null) return null;
      if (!(nth == -1 || (nth >= 1 && nth <= 5))) return null;
      monthlyWeek = nth;
      monthlyWeekday = weekday;
    } else {
      return null;
    }
  } else if (setPos != null) {
    return null;
  }
  // Anything left (BYHOUR, TickTick's TT_SKIP, …) changes the meaning.
  if (parts.isNotEmpty) return null;
  return ImportedRepeat(
    frequency: frequency,
    interval: interval,
    byWeekdays: weekdays,
    monthlyWeek: monthlyWeek,
    monthlyWeekday: monthlyWeekday,
    until: until,
    count: count,
  );
}

/// Todoist-style English repeat phrases: `every day`, `daily`,
/// `every 3 weeks`, `every other month`, `every mon, fri`, `every weekday`,
/// `yearly`, each optionally followed by `at <time>`. Null for anything
/// else (`every! day`, `every 2nd tue`, `starting …`, `ending …`).
({ImportedRepeat repeat, ({int hour, int minute})? time})? parseEveryPhrase(
  String raw,
) {
  var s = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  ({int hour, int minute})? time;
  final at = RegExp(r' at (\d{1,2})(?::(\d{2}))?\s*([ap]\.?m\.?)?$')
      .firstMatch(s);
  if (at != null) {
    final t = _clockTime(
      int.parse(at.group(1)!),
      int.parse(at.group(2) ?? '0'),
      at.group(3),
    );
    if (t == null) return null;
    time = (hour: t.$1, minute: t.$2);
    s = s.substring(0, at.start);
  }
  ImportedRepeat? repeat;
  const simple = {
    'daily': Recurrence.daily,
    'every day': Recurrence.daily,
    'weekly': Recurrence.weekly,
    'every week': Recurrence.weekly,
    'monthly': Recurrence.monthly,
    'every month': Recurrence.monthly,
    'yearly': Recurrence.yearly,
    'annually': Recurrence.yearly,
    'every year': Recurrence.yearly,
  };
  if (simple.containsKey(s)) {
    repeat = ImportedRepeat(frequency: simple[s]!);
  } else if (s == 'every weekday' || s == 'every workday') {
    repeat = const ImportedRepeat(
      frequency: Recurrence.weekly,
      byWeekdays: [1, 2, 3, 4, 5],
    );
  } else {
    final n = RegExp(r'^every (\d{1,3}|other) (day|week|month|year)s?$')
        .firstMatch(s);
    if (n != null) {
      final interval = n.group(1) == 'other' ? 2 : int.parse(n.group(1)!);
      if (interval < 1) return null;
      repeat = ImportedRepeat(
        frequency: switch (n.group(2)!) {
          'day' => Recurrence.daily,
          'week' => Recurrence.weekly,
          'month' => Recurrence.monthly,
          _ => Recurrence.yearly,
        },
        interval: interval,
      );
    } else if (s.startsWith('every ')) {
      final names = s
          .substring(6)
          .split(RegExp(r'\s*(?:,|\band\b)\s*'))
          .where((p) => p.isNotEmpty)
          .toList();
      final days = names.map(_weekdayName).toList();
      if (names.isEmpty || days.any((d) => d == null)) return null;
      repeat = ImportedRepeat(
        frequency: Recurrence.weekly,
        byWeekdays: (days.cast<int>().toSet().toList())..sort(),
      );
    }
  }
  if (repeat == null) return null;
  return (repeat: repeat, time: time);
}

/// The first date on or after [today] that [repeat] lands on, used when a
/// source keeps the rule but not its next date (Todoist backups).
DateTime firstOccurrence(ImportedRepeat repeat, DateTime today) {
  final start = DateTime(today.year, today.month, today.day);
  if (repeat.byWeekdays.isEmpty) return start;
  for (var i = 0; i < 7; i++) {
    final d = DateTime(start.year, start.month, start.day + i);
    if (repeat.byWeekdays.contains(d.weekday)) return d;
  }
  return start;
}

/// Durations such as `30m`, `2h`, `1h30m`, `1.5h`, `45` (minutes). Null
/// for other units or nonsense.
int? parseMinutes(String raw) {
  final s = raw.trim().toLowerCase().replaceAll(' ', '');
  if (s.isEmpty) return null;
  final plain = int.tryParse(s);
  if (plain != null) return plain > 0 ? plain : null;
  final m = RegExp(r'^(?:(\d+(?:\.\d+)?)h(?:ours?|rs?)?)?'
          r'(?:(\d+)m(?:in(?:ute)?s?)?)?$')
      .firstMatch(s);
  if (m == null || (m.group(1) == null && m.group(2) == null)) return null;
  final minutes = ((double.tryParse(m.group(1) ?? '0') ?? 0) * 60).round() +
      int.parse(m.group(2) ?? '0');
  return minutes > 0 ? minutes : null;
}

const _months =
    r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|'
    r'aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)';

int _monthIndex(String name) => const [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun',
  'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
].indexOf(name.substring(0, 3)) + 1;

int? _weekdayCode(String code) => switch (code) {
  'MO' => DateTime.monday,
  'TU' => DateTime.tuesday,
  'WE' => DateTime.wednesday,
  'TH' => DateTime.thursday,
  'FR' => DateTime.friday,
  'SA' => DateTime.saturday,
  'SU' => DateTime.sunday,
  _ => null,
};

int? _weekdayName(String name) {
  const names = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday',
  ];
  if (name.length < 3) return null;
  for (var i = 0; i < names.length; i++) {
    if (names[i].startsWith(name) || name == names[i]) return i + 1;
  }
  // "tues", "thurs" etc. are prefixes already; "weds" is not.
  return name == 'weds' ? DateTime.wednesday : null;
}

(int, int)? _clockTime(int hour, int minute, String? meridiem) {
  if (minute > 59) return null;
  if (meridiem != null) {
    if (hour < 1 || hour > 12) return null;
    final pm = meridiem.toLowerCase().startsWith('p');
    hour = hour % 12 + (pm ? 12 : 0);
  }
  if (hour > 23) return null;
  return (hour, minute);
}

DateTime? _validDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1) return null;
  final d = DateTime(year, month, day);
  return d.month == month && d.day == day ? d : null;
}
