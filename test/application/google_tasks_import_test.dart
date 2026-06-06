import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/application/google_tasks_import.dart';

void main() {
  final fallback = DateTime.utc(2026, 5, 16);

  Map<String, Object?> takeout(List<Map<String, Object?>> tasks,
          {String list = 'Next action'}) =>
      {
        'kind': 'tasks#taskLists',
        'items': [
          {'title': list, 'id': 'list-1', 'items': tasks},
        ],
      };

  group('isGoogleTasksExport', () {
    test('true for a Takeout export', () {
      expect(isGoogleTasksExport(takeout(const [])), isTrue);
    });

    test('true via fallback when kind is absent', () {
      expect(
        isGoogleTasksExport({
          'items': [
            {'title': 'L', 'items': const []},
          ],
        }),
        isTrue,
      );
    });

    test('false for a Trayzero backup', () {
      expect(
        isGoogleTasksExport({'version': 2, 'items': const []}),
        isFalse,
      );
    });

    test('false for arbitrary JSON', () {
      expect(isGoogleTasksExport({'hello': 'world'}), isFalse);
    });
  });

  group('convertGoogleTasksExport', () {
    List<Map<String, Object?>> itemsOf(Map<String, Object?> backup) =>
        (backup['items']! as List).cast<Map<String, Object?>>();

    test('produces a Trayzero v2 backup envelope', () {
      final out = convertGoogleTasksExport(takeout(const []),
          fallback: fallback);
      expect(out['version'], 2);
      expect(out['contexts'], isEmpty);
      expect(out['areas'], isEmpty);
      expect(out['projects'], isEmpty);
      expect(out['items'], isEmpty);
    });

    test('open task → inbox with no completion date', () {
      final out = convertGoogleTasksExport(
        takeout([
          {'id': 'a', 'title': 'Open one', 'status': 'needsAction'},
        ]),
        fallback: fallback,
      );
      final i = itemsOf(out).single;
      expect(i['status'], 'inbox');
      expect(i['completedAt'], isNull);
      expect(i['title'], 'Open one');
    });

    test('completed task → done carrying its completion date', () {
      final out = convertGoogleTasksExport(
        takeout([
          {
            'id': 'b',
            'title': 'Done one',
            'status': 'completed',
            'completed': '2024-11-20T07:14:05.940Z',
          },
        ]),
        fallback: fallback,
      );
      final i = itemsOf(out).single;
      expect(i['status'], 'done');
      expect(
        DateTime.parse(i['completedAt']! as String),
        DateTime.utc(2024, 11, 20, 7, 14, 5, 940),
      );
    });

    test('completed without a timestamp still gets a completion date', () {
      final out = convertGoogleTasksExport(
        takeout([
          {
            'id': 'c',
            'title': 'Done, undated',
            'status': 'completed',
            'updated': '2024-01-02T03:04:05Z',
          },
        ]),
        fallback: fallback,
      );
      final i = itemsOf(out).single;
      expect(i['status'], 'done');
      expect(i['completedAt'], isNotNull);
    });

    test('dueAt comes from scheduled_time (current entry preferred)', () {
      final out = convertGoogleTasksExport(
        takeout([
          {
            'id': 'd',
            'title': 'Scheduled',
            'status': 'needsAction',
            'scheduled_time': [
              {'current': false, 'start': '2020-01-01T00:00:00Z'},
              {'current': true, 'start': '2026-05-17T10:00:00Z'},
            ],
          },
        ]),
        fallback: fallback,
      );
      final i = itemsOf(out).single;
      expect(
        DateTime.parse(i['dueAt']! as String),
        DateTime.utc(2026, 5, 17, 10),
      );
    });

    test('dueAt falls back to the legacy due field', () {
      final out = convertGoogleTasksExport(
        takeout([
          {
            'id': 'e',
            'title': 'Legacy due',
            'status': 'needsAction',
            'due': '2025-06-01T00:00:00Z',
          },
        ]),
        fallback: fallback,
      );
      final i = itemsOf(out).single;
      expect(
        DateTime.parse(i['dueAt']! as String),
        DateTime.utc(2025, 6, 1),
      );
    });

    test('notes compose original + list + resolved parent title', () {
      final out = convertGoogleTasksExport(
        takeout([
          {'id': 'p', 'title': 'Parent task', 'status': 'needsAction'},
          {
            'id': 'ch',
            'title': 'Child task',
            'status': 'needsAction',
            'parent': 'p',
            'notes': 'remember this',
          },
        ], list: 'Project'),
        fallback: fallback,
      );
      final child =
          itemsOf(out).firstWhere((m) => m['id'] == 'gt-ch');
      final notes = child['notes']! as String;
      expect(notes, contains('remember this'));
      expect(notes, contains('List: Project'));
      expect(notes, contains('Subtask of: Parent task'));
    });

    test('untitled tasks get a placeholder and ids are gt-prefixed', () {
      final src = takeout([
        {'id': 'x', 'status': 'needsAction'},
      ]);
      final a = convertGoogleTasksExport(src, fallback: fallback);
      final b = convertGoogleTasksExport(src, fallback: fallback);
      final ia = (a['items']! as List).cast<Map<String, Object?>>().single;
      final ib = (b['items']! as List).cast<Map<String, Object?>>().single;
      expect(ia['title'], '(untitled)');
      expect(ia['id'], 'gt-x');
      expect(ia['id'], ib['id']); // stable across runs → re-import upserts
    });

    test('garbage/empty Takeout yields no items without throwing', () {
      final out = convertGoogleTasksExport(
        {
          'kind': 'tasks#taskLists',
          'items': [
            {'title': 'L', 'items': 'not a list'},
            'junk',
          ],
        },
        fallback: fallback,
      );
      expect(out['items'], isEmpty);
    });
  });
}
