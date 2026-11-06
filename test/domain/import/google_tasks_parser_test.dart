import 'dart:convert';
import 'dart:io';

import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/google_tasks_parser.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 3);
  String export(List<Object?> tasks) => jsonEncode({
    'kind': 'tasks#taskLists',
    'items': [
      {'title': 'Home', 'items': tasks},
    ],
  });

  test('retains list, parent, notes, dates and completed tasks', () {
    final plan = parseGoogleTasks(
      File('test/fixtures/import/google_tasks.json').readAsStringSync(),
      now: now,
    );
    expect(plan.projects, isEmpty);
    expect(plan.items.map((i) => i.status), [
      ItemStatus.inbox,
      ItemStatus.done,
    ]);
    expect(plan.items.first.notes, 'Bring bags\n\nList: Home');
    expect(plan.items.last.notes, 'List: Home · Subtask of: Buy groceries');
    expect(
      plan.items.last.completedAt!.toUtc(),
      DateTime.utc(2026, 10, 21, 12, 30),
    );
    expect(plan.warnings[ImportWarning.subtasksFlattened], 1);
  });

  test(
    'current scheduled date wins and completed fallback is deterministic',
    () {
      final plan = parseGoogleTasks(
        export([
          {
            'title': 'Done',
            'status': 'completed',
            'scheduled_time': [
              {'start': '2020-01-01T10:00:00Z'},
              {'current': true, 'start': '2026-11-04T10:00:00Z'},
            ],
            'due': '2026-11-05T00:00:00Z',
          },
        ]),
        now: now,
      );
      expect(plan.items.single.dueAt!.toUtc(), DateTime.utc(2026, 11, 4, 10));
      expect(plan.items.single.completedAt, now);
    },
  );

  test(
    'invalid dates stay in notes, malformed rows count, deleted tasks skip',
    () {
      final plan = parseGoogleTasks(
        export([
          null,
          {'title': 'Deleted', 'deleted': true},
          {'title': 'Keep', 'due': 'not a date'},
          {'title': 42},
        ]),
        now: now,
      );
      expect(plan.items.map((i) => i.title), ['Keep', '(untitled)']);
      expect(plan.items.first.notes, contains('Due: not a date'));
      expect(plan.warnings[ImportWarning.unparsedDate], 1);
      expect(plan.warnings[ImportWarning.unreadableRows], 1);
      expect(plan.warnings[ImportWarning.completedSkipped], 1);
    },
  );

  test(
    'due is a local calendar date; scheduled and completion values are instants',
    () {
      final plan = parseGoogleTasks(
        export([
          {'title': 'Date only', 'due': '2026-11-03T00:00:00.000Z'},
          {
            'title': 'Timed',
            'due': '2026-11-03T00:00:00Z',
            'scheduled_time': [
              {'current': true, 'start': '2026-11-03T00:30:00Z'},
            ],
            'status': 'completed',
            'completed': '2026-11-03T00:45:00Z',
          },
        ]),
        now: now,
      );
      expect(plan.items.first.dueAt, DateTime(2026, 11, 3));
      expect(plan.items.first.dueAt!.isUtc, isFalse);
      expect(plan.items.last.dueAt!.toUtc(), DateTime.utc(2026, 11, 3, 0, 30));
      expect(
        plan.items.last.completedAt!.toUtc(),
        DateTime.utc(2026, 11, 3, 0, 45),
      );
    },
  );

  test('date-only due ignores time and offset, validates the written day', () {
    for (final input in [
      '2024-02-29T00:00:00Z',
      '2024-02-29T23:30:00-12:00',
      '2024-02-29T00:30:00+14:00',
      '2024-02-29',
    ]) {
      final plan = parseGoogleTasks(
        export([
          {'title': 'Leap day', 'due': input},
        ]),
        now: now,
      );
      expect(plan.items.single.dueAt, DateTime(2024, 2, 29), reason: input);
    }
    for (final input in [
      '2026-02-30T00:00:00Z',
      '2026-13-01T00:00:00Z',
      'nonsense',
    ]) {
      final plan = parseGoogleTasks(
        export([
          {'title': 'Invalid', 'due': input},
        ]),
        now: now,
      );
      expect(plan.items.single.dueAt, isNull, reason: input);
      expect(plan.items.single.notes, contains('Due: $input'));
      expect(plan.warnings[ImportWarning.unparsedDate], 1);
    }
  });

  test('rejects backups, unrelated JSON and invalid JSON', () {
    for (final text in [
      '{"version":2,"items":[]}',
      '{"items":[{}]}',
      '[]',
      '{',
    ]) {
      expect(
        () => parseGoogleTasks(text, now: now),
        throwsA(isA<ImportFormatException>()),
      );
    }
  });
}
