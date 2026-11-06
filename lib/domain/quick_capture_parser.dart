import 'entities/entities.dart';
import 'tags.dart';

/// Natural-language quick capture (ADR 0007). Pure Dart, no I/O.
///
/// Recognizes, at most one of each kind except tags (the first wins):
/// - `@word` — an existing [GtdContext] (case-insensitive, exact name or a
///   unique prefix; the name's own leading `@` is ignored);
/// - `#word` — an existing active [Project] (case-, space- and
///   punctuation-insensitive: exact, else a unique prefix of 2+ characters,
///   else a unique word start of 3+ characters, e.g. `#garage`);
/// - `+word` — tags (ADR 0010), any number: an existing [Tag] whose name
///   matches ignoring case, spaces, and punctuation (`+big-rocks` → "Big
///   Rocks"), else a new tag named `word`. No prefix matching, because an
///   unknown word creates a tag. The word must start with a letter and the
///   `+` must not follow a word character or sigil, so `C++` and `+1` stay
///   text;
/// - an English date phrase (only when `parseDates` is true): `today`,
///   `tonight`, `tomorrow`/`tmrw`/`tmr`, weekday names (optionally `this` /
///   `next`), `next week`, `next month`, `(this) weekend`,
///   `in N days|weeks|months`, `Oct 28` / `28 October` (optional year), and
///   ISO `2026-10-28`. An optional leading `on` is consumed.
///
/// A date is a **start (defer) date** by default — GTD's "not before". A
/// leading `due` / `by` or a trailing `!` makes it a **due date**.
///
/// Recognized spans are removed from [QuickCaptureParse.title]. Tokens whose
/// [CaptureToken.key] is in `ignored` stay as text. If removal would leave
/// an empty title nothing is recognized, so a capture is never blanked.
enum CaptureTokenKind { date, context, project, tag }

class CaptureToken {
  const CaptureToken({
    required this.kind,
    required this.start,
    required this.end,
    required this.source,
    this.date,
    this.isDue = false,
    this.contextId,
    this.projectId,
    this.tagId,
    this.tagName,
  });

  final CaptureTokenKind kind;

  /// Span of the recognized text in the input, `[start, end)`.
  final int start;
  final int end;
  final String source;

  /// Local start of day; set for [CaptureTokenKind.date].
  final DateTime? date;
  final bool isDue;
  final String? contextId;
  final String? projectId;

  /// For [CaptureTokenKind.tag]: the existing tag's id (null for a new tag)
  /// and the name to attach — the existing spelling, or the typed word.
  final String? tagId;
  final String? tagName;

  /// Stable identity for "keep as text": the same words stay unrecognized
  /// while the user keeps typing around them.
  String get key => '${kind.name}:${source.toLowerCase()}';
}

class QuickCaptureParse {
  const QuickCaptureParse({required this.title, this.tokens = const []});

  /// The title with recognized spans removed and whitespace collapsed.
  final String title;

  /// Recognized tokens, in input order.
  final List<CaptureToken> tokens;

  CaptureToken? _of(CaptureTokenKind kind) {
    for (final t in tokens) {
      if (t.kind == kind) return t;
    }
    return null;
  }

  CaptureToken? get dateToken => _of(CaptureTokenKind.date);
  DateTime? get deferUntil =>
      dateToken?.isDue == false ? dateToken!.date : null;
  DateTime? get dueAt => dateToken?.isDue == true ? dateToken!.date : null;
  String? get contextId => _of(CaptureTokenKind.context)?.contextId;
  String? get projectId => _of(CaptureTokenKind.project)?.projectId;

  /// Names of the tags to attach, in input order without repeats.
  List<String> get tagNames => [
    for (final t in tokens)
      if (t.kind == CaptureTokenKind.tag) t.tagName!,
  ];
}

QuickCaptureParse parseQuickCapture(
  String input, {
  required DateTime now,
  List<GtdContext> contexts = const [],
  List<Project> projects = const [],
  List<Tag> tags = const [],
  bool parseDates = true,
  Set<String> ignored = const {},
}) {
  final accepted = <CaptureToken>[];
  final blocked = <(int, int)>[];
  bool overlaps(int s, int e) => blocked.any((b) => s < b.$2 && b.$1 < e);

  void pick(Iterable<CaptureToken> candidates) {
    for (final c in candidates) {
      if (overlaps(c.start, c.end)) continue;
      blocked.add((c.start, c.end));
      if (ignored.contains(c.key)) continue;
      accepted.add(c);
      return;
    }
  }

  pick(_sigilTokens(input, '@', CaptureTokenKind.context, (word) {
    return _uniqueMatch(
      word,
      contexts,
      (c) => _normalizeName(c.name),
      minPrefix: 1,
    )?.id;
  }));
  pick(_sigilTokens(input, '#', CaptureTokenKind.project, (word) {
    final active = projects.where((p) => p.status == ProjectStatus.active);
    final needle = _normalizeName(word);
    return (_uniqueMatch(
              word,
              active,
              (p) => _normalizeName(p.title),
              minPrefix: 2,
            ) ??
            // "#garage" → "Clean the garage": a unique word-start match.
            (needle.length < 3
                ? null
                : _single(
                    active.where(
                      (p) => p.title
                          .split(RegExp(r'\s+'))
                          .any((w) => _normalizeName(w).startsWith(needle)),
                    ),
                  )))
        ?.id;
  }));
  // Tags are not one-of-a-kind: keep every non-overlapping `+word`, once
  // per tag.
  final seenTags = <String>{};
  for (final t in _tagTokens(input, tags)) {
    if (overlaps(t.start, t.end)) continue;
    blocked.add((t.start, t.end));
    if (ignored.contains(t.key) || !seenTags.add(tagKey(t.tagName!))) continue;
    accepted.add(t);
  }
  if (parseDates) pick(_dateTokens(input, now));

  if (accepted.isEmpty) return QuickCaptureParse(title: input.trim());
  accepted.sort((a, b) => a.start.compareTo(b.start));
  final buffer = StringBuffer();
  var cursor = 0;
  for (final t in accepted) {
    buffer
      ..write(input.substring(cursor, t.start))
      ..write(' ');
    cursor = t.end;
  }
  buffer.write(input.substring(cursor));
  final title = buffer
      .toString()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAllMapped(RegExp(r'\s+([,.;:!?])'), (m) => m.group(1)!)
      .replaceAll(RegExp(r'^[\s,;:]+|[\s,;:]+$'), '');
  if (title.isEmpty) return QuickCaptureParse(title: input.trim());
  return QuickCaptureParse(title: title, tokens: List.unmodifiable(accepted));
}

// ---- Sigils -----------------------------------------------------------------

const _wordChars = r'\p{L}\p{N}_';

Iterable<CaptureToken> _sigilTokens(
  String input,
  String sigil,
  CaptureTokenKind kind,
  String? Function(String word) resolve,
) sync* {
  final re = RegExp(
    '(?<![$_wordChars@#])${RegExp.escape(sigil)}([$_wordChars\\-]+)',
    unicode: true,
  );
  for (final m in re.allMatches(input)) {
    final id = resolve(m.group(1)!);
    if (id == null) continue;
    yield CaptureToken(
      kind: kind,
      start: m.start,
      end: m.end,
      source: m.group(0)!,
      contextId: kind == CaptureTokenKind.context ? id : null,
      projectId: kind == CaptureTokenKind.project ? id : null,
    );
  }
}

/// `+word`: the word starts with a letter and may hold inner hyphens but not
/// end with one.
final _tagPattern = RegExp(
  '(?<![$_wordChars@#+])\\+(\\p{L}(?:[$_wordChars\\-]*[$_wordChars])?)',
  unicode: true,
);

Iterable<CaptureToken> _tagTokens(String input, List<Tag> tags) sync* {
  for (final m in _tagPattern.allMatches(input)) {
    final word = m.group(1)!;
    final needle = _normalizeName(word);
    final existing = _single(tags.where((t) => _normalizeName(t.name) == needle));
    final name = existing?.name ?? cleanTagName(word);
    if (name == null) continue;
    yield CaptureToken(
      kind: CaptureTokenKind.tag,
      start: m.start,
      end: m.end,
      source: m.group(0)!,
      tagId: existing?.id,
      tagName: name,
    );
  }
}

String _normalizeName(String name) => name
    .toLowerCase()
    .replaceAll(RegExp('[^$_wordChars]|_', unicode: true), '');

/// Exact normalized match wins; otherwise the single entity whose name
/// starts with [word]. Ambiguity recognizes nothing rather than guessing.
T? _uniqueMatch<T>(
  String word,
  Iterable<T> entities,
  String Function(T) name, {
  required int minPrefix,
}) {
  final needle = _normalizeName(word);
  if (needle.isEmpty) return null;
  T? prefixMatch;
  var prefixCount = 0;
  for (final e in entities) {
    final n = name(e);
    if (n == needle) return e;
    if (needle.length >= minPrefix && n.startsWith(needle)) {
      prefixMatch = e;
      prefixCount++;
    }
  }
  return prefixCount == 1 ? prefixMatch : null;
}

T? _single<T>(Iterable<T> matches) =>
    matches.length == 1 ? matches.first : null;

// ---- Dates -------------------------------------------------------------------

const _weekdays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

const _months =
    r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|'
    r'aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)';

int _monthIndex(String name) => const [
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec',
].indexOf(name.substring(0, 3).toLowerCase()) + 1;

typedef _Resolver = DateTime? Function(RegExpMatch m, DateTime today);

final List<(String, _Resolver)> _datePatterns = [
  (r'today|tonight', (_, t) => t),
  (r'tomorrow|tmrw|tmr', (_, t) => _addDays(t, 1)),
  (
    '(?:(this|next)\\s+)?(${_weekdays.join('|')})',
    (m, t) {
      final target = _weekdays.indexOf(m.group(3)!.toLowerCase()) + 1;
      var delta = (target - t.weekday) % 7;
      // "this <day>" may be today; a bare or "next" weekday is the next one.
      if (delta == 0 && m.group(2)?.toLowerCase() != 'this') delta = 7;
      return _addDays(t, delta);
    },
  ),
  (r'next\s+week', (_, t) => _addDays(t, 8 - t.weekday)),
  (r'next\s+month', (_, t) => DateTime(t.year, t.month + 1)),
  (
    r'(?:this\s+)?weekend',
    (_, t) => t.weekday == DateTime.sunday
        ? t
        : _addDays(t, DateTime.saturday - t.weekday),
  ),
  (
    r'in\s+(\d{1,3}|an?|one)\s+(days?|weeks?|months?)',
    (m, t) {
      final raw = m.group(2)!.toLowerCase();
      final n = int.tryParse(raw) ?? 1;
      final unit = m.group(3)!.toLowerCase();
      if (unit.startsWith('month')) return _addMonths(t, n);
      return _addDays(t, unit.startsWith('week') ? n * 7 : n);
    },
  ),
  (
    '$_months\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?(?:,?\\s+(\\d{4}))?',
    (m, t) => _calendarDate(
      t,
      _monthIndex(m.group(2)!),
      int.parse(m.group(3)!),
      m.group(4),
    ),
  ),
  (
    '(\\d{1,2})(?:st|nd|rd|th)?\\s+(?:of\\s+)?$_months\\.?(?:,?\\s+(\\d{4}))?',
    (m, t) => _calendarDate(
      t,
      _monthIndex(m.group(3)!),
      int.parse(m.group(2)!),
      m.group(4),
    ),
  ),
  (
    r'(\d{4})-(\d{2})-(\d{2})',
    (m, t) => _validDate(
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      int.parse(m.group(4)!),
    ),
  ),
];

final List<(RegExp, _Resolver)> _compiled = [
  for (final (core, resolve) in _datePatterns)
    (
      RegExp(
        // Group 1 is the optional due/by marker; the core's own groups start
        // at 2. A trailing `!` (last group) also marks a due date.
        // `@`/`#` before and an apostrophe after keep sigil words and
        // possessives ("tomorrow's") as plain text.
        '(?<![$_wordChars@#+])(?:(due|by)\\s+)?(?:on\\s+)?(?:$core)'
        "(?![$_wordChars'’])(!)?",
        caseSensitive: false,
        unicode: true,
      ),
      resolve,
    ),
];

Iterable<CaptureToken> _dateTokens(String input, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final found = <CaptureToken>[];
  for (final (re, resolve) in _compiled) {
    for (final m in re.allMatches(input)) {
      final date = resolve(m, today);
      if (date == null) continue;
      found.add(
        CaptureToken(
          kind: CaptureTokenKind.date,
          start: m.start,
          end: m.end,
          source: m.group(0)!,
          date: date,
          isDue: m.group(1) != null || m.group(m.groupCount) != null,
        ),
      );
    }
  }
  found.sort((a, b) {
    final byStart = a.start.compareTo(b.start);
    return byStart != 0 ? byStart : b.end.compareTo(a.end);
  });
  return found;
}

DateTime _addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

DateTime _addMonths(DateTime d, int months) {
  final first = DateTime(d.year, d.month + months);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, d.day > lastDay ? lastDay : d.day);
}

DateTime? _validDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1) return null;
  final d = DateTime(year, month, day);
  return d.month == month && d.day == day ? d : null;
}

/// A month/day without a year is the next such date, today included.
DateTime? _calendarDate(DateTime today, int month, int day, String? year) {
  if (year != null) return _validDate(int.parse(year), month, day);
  final thisYear = _validDate(today.year, month, day);
  if (thisYear != null && !thisYear.isBefore(today)) return thisYear;
  return _validDate(today.year + 1, month, day);
}
