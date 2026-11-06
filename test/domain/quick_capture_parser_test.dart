import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/quick_capture_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Wednesday.
  final now = DateTime(2026, 10, 28, 9, 30);
  final created = DateTime(2026, 1, 1);
  const contexts = [
    GtdContext(id: 'c-phone', name: '@phone', icon: 'label', color: 0),
    GtdContext(id: 'c-home', name: '@home', icon: 'label', color: 0),
    GtdContext(id: 'c-hobby', name: '@hobby shop', icon: 'label', color: 0),
  ];
  final projects = [
    Project(
      id: 'p-garage',
      title: 'Clean the garage',
      status: ProjectStatus.active,
      createdAt: created,
      updatedAt: created,
    ),
    Project(
      id: 'p-garden',
      title: 'Garden',
      status: ProjectStatus.active,
      createdAt: created,
      updatedAt: created,
    ),
    Project(
      id: 'p-gala',
      title: 'Gala',
      status: ProjectStatus.active,
      createdAt: created,
      updatedAt: created,
    ),
    Project(
      id: 'p-tax',
      title: 'Taxes 2026',
      status: ProjectStatus.onHold,
      createdAt: created,
      updatedAt: created,
    ),
  ];

  const tags = [
    Tag(id: 't-kitchen', name: 'Kitchen'),
    Tag(id: 't-rocks', name: 'Big Rocks'),
    Tag(id: 't-alice', name: 'Alice', isPerson: true),
  ];

  QuickCaptureParse parse(
    String input, {
    bool parseDates = true,
    Set<String> ignored = const {},
  }) => parseQuickCapture(
    input,
    now: now,
    contexts: contexts,
    projects: projects,
    tags: tags,
    parseDates: parseDates,
    ignored: ignored,
  );

  group('dates', () {
    final cases = <String, DateTime>{
      'Call mom today': DateTime(2026, 10, 28),
      'Call mom tonight': DateTime(2026, 10, 28),
      'Call mom tomorrow': DateTime(2026, 10, 29),
      'Call mom tmrw': DateTime(2026, 10, 29),
      'Call mom on friday': DateTime(2026, 10, 30),
      'Call mom Wednesday': DateTime(2026, 11, 4),
      'Call mom next wednesday': DateTime(2026, 11, 4),
      'Call mom this wednesday': DateTime(2026, 10, 28),
      'Call mom monday': DateTime(2026, 11, 2),
      'Call mom next week': DateTime(2026, 11, 2),
      'Call mom next month': DateTime(2026, 11, 1),
      'Call mom this weekend': DateTime(2026, 10, 31),
      'Call mom in 3 days': DateTime(2026, 10, 31),
      'Call mom in a week': DateTime(2026, 11, 4),
      'Call mom in 2 weeks': DateTime(2026, 11, 11),
      'Call mom in 4 months': DateTime(2027, 2, 28),
      'Call mom Nov 3': DateTime(2026, 11, 3),
      'Call mom oct 28th': DateTime(2026, 10, 28),
      'Call mom 3 March': DateTime(2027, 3, 3),
      'Call mom 3rd of march 2028': DateTime(2028, 3, 3),
      'Call mom january 5, 2027': DateTime(2027, 1, 5),
      'Call mom 2026-12-24': DateTime(2026, 12, 24),
    };
    cases.forEach((input, expected) {
      test(input, () {
        final r = parse(input);
        expect(r.deferUntil, expected);
        expect(r.dueAt, isNull);
        expect(r.title, 'Call mom');
      });
    });

    test('a month/day already past rolls to next year', () {
      expect(parse('Renew passport Jan 2').deferUntil, DateTime(2027, 1, 2));
    });

    test('in N months clamps to the end of a short month', () {
      final r = parseQuickCapture(
        'Pay in 1 month',
        now: DateTime(2026, 1, 31),
      );
      expect(r.deferUntil, DateTime(2026, 2, 28));
    });

    test('due, by and a trailing ! make a due date', () {
      for (final input in [
        'Submit report due friday',
        'Submit report by friday',
        'Submit report friday!',
        'Submit report due on friday',
      ]) {
        final r = parse(input);
        expect(r.dueAt, DateTime(2026, 10, 30), reason: input);
        expect(r.deferUntil, isNull, reason: input);
        expect(r.title, 'Submit report', reason: input);
      }
    });

    test('invalid calendar dates are not recognized', () {
      final r = parse('Party Feb 30');
      expect(r.tokens, isEmpty);
      expect(r.title, 'Party Feb 30');
      expect(parse('Ship 2026-13-01').tokens, isEmpty);
    });

    test('only the first date is applied; later ones stay as text', () {
      final r = parse('Move meeting from monday to friday');
      expect(r.deferUntil, DateTime(2026, 11, 2));
      expect(r.title, 'Move meeting from to friday');
    });

    test('words containing date keywords are left alone', () {
      for (final input in [
        'Watch Mondays show',
        'Fix todays build',
        'Prep tomorrow’s slides',
        'Prep tomorrow\'s slides',
        'Maybe call Sunday school',
        'Buy may flowers',
        'Visit the 2026 expo',
      ]) {
        final r = parse(input);
        if (input == 'Maybe call Sunday school') {
          // A real weekday word is recognized; the chip lets the user undo it.
          expect(r.tokens, hasLength(1));
          continue;
        }
        expect(r.tokens, isEmpty, reason: input);
        expect(r.title, input, reason: input);
      }
    });

    test('dates are not parsed when disabled (non-English UI)', () {
      final r = parse('Anruf tomorrow @phone', parseDates: false);
      expect(r.deferUntil, isNull);
      expect(r.contextId, 'c-phone');
      expect(r.title, 'Anruf tomorrow');
    });

    test('a non-English title without sigils is never changed', () {
      for (final input in [
        'Morgen Mama anrufen',
        '明日 牛乳を買う',
        'Позвонить маме завтра',
        'Llamar a mamá mañana',
      ]) {
        final r = parse(input, parseDates: false);
        expect(r.tokens, isEmpty);
        expect(r.title, input);
      }
    });

    test('spans cover the recognized source text', () {
      final r = parse('Pay rent due tomorrow please');
      final t = r.dateToken!;
      expect('Pay rent due tomorrow please'.substring(t.start, t.end),
          'due tomorrow');
      expect(r.title, 'Pay rent please');
    });
  });

  group('contexts', () {
    test('exact and prefix matches, case-insensitive', () {
      expect(parse('Call Bob @phone').contextId, 'c-phone');
      expect(parse('Call Bob @PHONE').contextId, 'c-phone');
      expect(parse('Call Bob @ph').contextId, 'c-phone');
      expect(parse('Call Bob @ph').title, 'Call Bob');
    });

    test('ambiguous prefixes and unknown names are left as text', () {
      final r = parse('Fix @ho sink');
      expect(r.contextId, isNull);
      expect(r.title, 'Fix @ho sink');
      expect(parse('Ask @unknown').tokens, isEmpty);
    });

    test('names with spaces match without them', () {
      expect(parse('Buy glue @hobbyshop').contextId, 'c-hobby');
    });

    test('email addresses are not contexts', () {
      final r = parse('Email bob@phone.com');
      expect(r.tokens, isEmpty);
    });
  });

  group('projects', () {
    test('matches active projects ignoring case, spaces and punctuation', () {
      expect(parse('Sweep #cleanthegarage').projectId, 'p-garage');
      expect(parse('Sweep #clean').projectId, 'p-garage');
      expect(parse('Plant #garden').projectId, 'p-garden');
    });

    test('a unique word start matches ("#garage" → "Clean the garage")', () {
      expect(parse('Sweep #garage').projectId, 'p-garage');
      expect(parse('Sweep #the').projectId, 'p-garage');
    });

    test('exact beats prefix; ambiguous prefixes do not match', () {
      expect(parse('Book #gala').projectId, 'p-gala');
      expect(parse('Book #ga').projectId, isNull);
    });

    test('single-character prefixes and inactive projects do not match', () {
      expect(parse('Do #c').projectId, isNull);
      expect(parse('File #taxes2026').projectId, isNull);
      expect(parse('Fix bug #123').title, 'Fix bug #123');
    });
  });

  test('everything together', () {
    final r = parse('Call Bob about tiles @phone #garage tomorrow!');
    expect(r.title, 'Call Bob about tiles');
    expect(r.contextId, 'c-phone');
    expect(r.projectId, 'p-garage');
    expect(r.dueAt, DateTime(2026, 10, 29));
    expect(r.tokens.map((t) => t.kind), [
      CaptureTokenKind.context,
      CaptureTokenKind.project,
      CaptureTokenKind.date,
    ]);
  });

  test('ignored tokens stay as text and block overlapping matches', () {
    final first = parse('Call Bob due tomorrow');
    final ignored = {first.dateToken!.key};
    final r = parse('Call Bob due tomorrow', ignored: ignored);
    expect(r.tokens, isEmpty);
    expect(r.title, 'Call Bob due tomorrow');
    // Still ignored while the user keeps typing around it.
    final more = parse('Call Bob due tomorrow at noon', ignored: ignored);
    expect(more.tokens, isEmpty);
  });

  test('a title made only of tokens is not blanked', () {
    final r = parse('tomorrow @phone');
    expect(r.tokens, isEmpty);
    expect(r.title, 'tomorrow @phone');
  });

  test('punctuation around removed tokens is tidied', () {
    expect(parse('Call Bob, tomorrow').title, 'Call Bob');
    expect(parse('Tomorrow: renew permit').title, 'renew permit');
  });

  group('tags', () {
    test('+word matches an existing tag ignoring case and punctuation', () {
      final r = parse('Ask about the budget +alice +big-rocks');
      expect(r.title, 'Ask about the budget');
      expect(r.tokens.map((t) => (t.kind, t.tagId, t.tagName)), [
        (CaptureTokenKind.tag, 't-alice', 'Alice'),
        (CaptureTokenKind.tag, 't-rocks', 'Big Rocks'),
      ]);
      expect(r.tagNames, ['Alice', 'Big Rocks']);
    });

    test('an unknown word becomes a new tag; no prefix matching', () {
      final r = parse('Buy filters +kit +groceries');
      expect(r.title, 'Buy filters');
      expect(r.tokens.map((t) => (t.tagId, t.tagName)), [
        (null, 'kit'),
        (null, 'groceries'),
      ]);
    });

    test('a repeated tag is attached once; the repeat stays text', () {
      final r = parse('Wipe +Kitchen counters +kitchen');
      expect(r.tagNames, ['Kitchen']);
      expect(r.title, 'Wipe counters +kitchen');
    });

    test('a + inside a word, before a digit, or after a sigil is text', () {
      for (final input in [
        'Learn C++ basics',
        'Call +44 20 7946 0000',
        'Score 3+2',
        'Email a+b@example.com',
      ]) {
        expect(parse(input).tokens, isEmpty, reason: input);
      }
    });

    test('date words after + are a tag, not a date', () {
      final r = parse('Plan +tomorrow');
      expect(r.deferUntil, isNull);
      expect(r.tagNames, ['tomorrow']);
    });

    test('works beside @context, #project, and a date', () {
      final r = parse('Paint shelf @home #garage +kitchen friday');
      expect(r.title, 'Paint shelf');
      expect(r.contextId, 'c-home');
      expect(r.projectId, 'p-garage');
      expect(r.tagNames, ['Kitchen']);
      expect(r.deferUntil, DateTime(2026, 10, 30));
    });

    test('Keep as text leaves the word in the title', () {
      final first = parse('Fix tap +kitchen');
      final r = parse('Fix tap +kitchen', ignored: {first.tokens.single.key});
      expect(r.tokens, isEmpty);
      expect(r.title, 'Fix tap +kitchen');
    });

    test('a trailing hyphen is not part of the tag', () {
      expect(parse('Sort +house- stuff').tagNames, ['house']);
    });
  });
}
