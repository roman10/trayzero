import 'dart:convert';
import 'dart:io';

import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/domain/import/microsoft_todo_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

List<Map<String, Object?>> snapshot() =>
    (jsonDecode(
              File(
                'test/fixtures/import/microsoft_todo_graph.json',
              ).readAsStringSync(),
            )
            as List)
        .cast<Map<String, Object?>>();

void main() {
  setUpAll(tzdata.initializeTimeZones);
  ImportPlan task(
    Map<String, Object?> overrides, {
    String name = 'Garage',
    bool defaultList = false,
  }) => parseMicrosoftTodo([
    {
      'displayName': name,
      'wellknownListName': defaultList ? 'defaultList' : 'none',
      'tasks': [
        {
          'title': 'Task',
          'status': 'notStarted',
          'checklistItems': <Object?>[],
          ...overrides,
        },
      ],
    },
  ]);

  test('localized default list is Inbox; custom lists are Projects', () {
    final plan = parseMicrosoftTodo(snapshot());
    expect(plan.source, ImportSourceApp.microsoftToDo);
    expect(plan.projects.map((p) => p.title), ['Garage']);
    final mom = plan.items.singleWhere((i) => i.title == 'Call Mom 日本語');
    expect(mom.status, ItemStatus.inbox);
    expect(mom.project, isNull);
    expect(mom.notes, 'Ask about travel');
    expect(mom.tags, ['phone', 'family']);
  });

  test(
    'keeps HTML paragraphs, entities and links without executable content',
    () {
      final item = task({
        'body': {
          'contentType': 'html',
          'content':
              '<script>hidden()</script><style>.bad{}</style><p>A &amp; B<br>C</p><p><a href="https://example.com">Guide</a></p>',
        },
      }).items.single;
      expect(item.notes, 'A & B\nC\nGuide (https://example.com)');
    },
  );

  test('HTML block boundaries do not join adjacent note words', () {
    final item = task({
      'body': {
        'contentType': 'html',
        'content': 'Before<div>middle</div>After<section>Last</section>End',
      },
    }).items.single;
    expect(item.notes, 'Before\nmiddle\nAfter\nLast\nEnd');
  });

  test('HTML table cells stay separated in imported notes', () {
    final item = task({
      'body': {
        'contentType': 'html',
        'content':
            '<table><tr><th>Name</th><th>Phone</th></tr><tr><td>Bob</td><td>123</td></tr></table>',
      },
    }).items.single;
    expect(item.notes, 'Name\tPhone\nBob\t123');
  });

  test(
    'skips completed parents and checked steps; flattens open steps once',
    () {
      final plan = parseMicrosoftTodo(snapshot());
      expect(plan.items, hasLength(5));
      expect(plan.warnings[ImportWarning.completedSkipped], 2);
      expect(plan.warnings[ImportWarning.subtasksFlattened], 1);
      final step = plan.items.singleWhere((i) => i.title == 'Buy brushes');
      expect(step.notes, 'Subtask of: Paint shelves');
      expect(step.project, 'Garage');
      expect(step.tags, ['@home', 'weekend']);
      expect(step.dueAt, isNull);
      expect(step.deferUntil, isNull);
    },
  );

  test(
    'preserves Waiting and Someday task states and conventional list names',
    () {
      final plan = parseMicrosoftTodo(snapshot());
      expect(
        plan.items.singleWhere((i) => i.title == 'Wait for delivery').status,
        ItemStatus.waiting,
      );
      expect(
        plan.items.singleWhere((i) => i.title == 'Build workbench').status,
        ItemStatus.someday,
      );
      for (final entry in {
        'Inbox': ItemStatus.inbox,
        'Waiting for': ItemStatus.waiting,
        'Someday': ItemStatus.someday,
      }.entries) {
        final mapped = task({}, name: entry.key);
        expect(mapped.projects, isEmpty);
        expect(mapped.items.single.status, entry.value);
      }
    },
  );

  test(
    'date-only UTC due/start values keep their calendar day in any local zone',
    () {
      final plan = parseMicrosoftTodo(snapshot());
      final paint = plan.items.singleWhere((i) => i.title == 'Paint shelves');
      expect(paint.dueAt, DateTime(2026, 11, 6));
      expect(paint.deferUntil, DateTime(2026, 11, 4));
      expect(paint.dueAt!.isUtc, isFalse);
    },
  );

  test('timed UTC and IANA dates convert using source offset and DST', () {
    for (final entry in {
      'UTC': DateTime.utc(2026, 7, 3, 15),
      'America/New_York': DateTime.utc(2026, 7, 3, 19),
      'Asia/Singapore': DateTime.utc(2026, 7, 3, 7),
    }.entries) {
      final item = task({
        'dueDateTime': {
          'dateTime': '2026-07-03T15:00:00.0000000',
          'timeZone': entry.key,
        },
      }).items.single;
      expect(item.dueAt, entry.value.toLocal());
    }
    final explicit = task({
      'dueDateTime': {
        'dateTime': '2026-07-03T15:00:00+02:00',
        'timeZone': 'unknown',
      },
    }).items.single;
    expect(explicit.dueAt, DateTime.utc(2026, 7, 3, 13).toLocal());
  });

  test(
    'source UTC wall time is unaffected by a daylight-saving gap on the device',
    () {
      final item = task({
        'dueDateTime': {'dateTime': '2026-03-08T02:30:00', 'timeZone': 'UTC'},
      }).items.single;
      expect(item.dueAt, DateTime.utc(2026, 3, 8, 2, 30).toLocal());
    },
  );

  test('unreadable date and unsupported Windows time zone stay in notes', () {
    for (final value in [
      {'dateTime': '2026-02-30T15:00:00', 'timeZone': 'UTC'},
      {'dateTime': '2026-07-03T15:00:00', 'timeZone': 'Pacific Standard Time'},
      {'dateTime': 'not a date', 'timeZone': 'UTC'},
      {'dateTime': '2026-03-08T02:30:00', 'timeZone': 'America/New_York'},
      {'dateTime': '2026-07-03T15:00:00'},
    ]) {
      final plan = task({'dueDateTime': value});
      expect(plan.items.single.dueAt, isNull);
      expect(plan.items.single.notes, contains(jsonEncode(value)));
      expect(plan.warnings[ImportWarning.unparsedDate], 1);
    }
  });

  test(
    'recurrence is preserved as text; unsupported source fields are counted',
    () {
      final plan = parseMicrosoftTodo(snapshot());
      final item = plan.items.singleWhere((i) => i.title == 'Paint shelves');
      expect(item.repeat, isNull);
      expect(item.notes, contains('Repeats: {"pattern"'));
      expect(plan.warnings[ImportWarning.repeatInNotes], 1);
      expect(plan.warnings[ImportWarning.notImported], 1);
      expect(plan.warnings[ImportWarning.sourceDetailsNotImported], 1);
    },
  );

  test('skips malformed rows but refuses an incomplete checklist snapshot', () {
    final plan = parseMicrosoftTodo([
      {
        'displayName': 'Tasks',
        'tasks': [
          null,
          {'title': '  '},
          {
            'title': 'Good',
            'checklistItems': [
              null,
              {'displayName': 'Step'},
            ],
          },
        ],
      },
    ]);
    expect(plan.items.map((i) => i.title), ['Good', 'Step']);
    expect(plan.warnings[ImportWarning.unreadableRows], 3);
    expect(
      () => task({'checklistItems': null}),
      throwsA(isA<ImportFormatException>()),
    );
    expect(
      () => parseMicrosoftTodo([
        {'displayName': 'Tasks'},
      ]),
      throwsA(isA<ImportFormatException>()),
    );
  });

  test('unknown task statuses are retained in notes and reported', () {
    final plan = task({'status': 'unknownFutureValue'});
    expect(plan.items.single.notes, 'Status: unknownFutureValue');
    expect(plan.warnings[ImportWarning.sourceDetailsNotImported], 1);
  });

  test(
    'empty or completed-only accounts produce noTasks, not an empty import',
    () {
      for (final lists in [
        <Map<String, Object?>>[],
        [
          {
            'displayName': 'Tasks',
            'tasks': [
              {'title': 'Done', 'status': 'completed'},
            ],
          },
        ],
      ]) {
        expect(
          () => parseMicrosoftTodo(lists),
          throwsA(
            isA<ImportFormatException>().having(
              (e) => e.failure,
              'failure',
              ImportFailure.noTasks,
            ),
          ),
        );
      }
    },
  );
}
