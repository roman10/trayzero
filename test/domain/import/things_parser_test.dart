import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/domain/import/things_parser.dart';
import 'package:cleartray/infrastructure/sqlite_things_snapshot_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../support/things_fixture.dart';

void main() {
  ImportPlan parse({void Function(Database)? modify}) => parseThings(
    SqliteThingsSnapshotReader().read(thingsFixture(modify: modify)),
  );

  test(
    'preserves projects, Areas, heading membership, checklists, tags and dates',
    () {
      final plan = parse();
      expect(plan.source, ImportSourceApp.things);
      expect(plan.projects.single.title, 'Kitchen');
      expect(plan.projects.single.area, 'Family');
      expect(plan.projects.single.outcome, 'New cabinets');
      expect(plan.items, hasLength(3));
      final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
      expect(action.project, 'Kitchen');
      expect(action.tags, ['@home', 'weekend']);
      expect(
        action.notes,
        'Bring tape\n\n[x] Find tape\n\n[ ] Take a photo\n\nSection: Preparation',
      );
      expect(action.deferUntil, DateTime(2026, 11, 4));
      expect(action.dueAt, DateTime(2026, 11, 10));
      expect(
        plan.items.singleWhere((i) => i.title == 'Capture idea').status,
        ItemStatus.inbox,
      );
      expect(
        plan.items.singleWhere((i) => i.title == 'Learn 日本語').status,
        ItemStatus.someday,
      );
      expect(plan.warnings[ImportWarning.completedSkipped], 3);
    },
  );

  test('checklist and Area details count each source task once', () {
    final plan = parse(
      modify: (db) {
        db.execute("UPDATE TMTask SET area='area' WHERE uuid='action'");
      },
    );
    final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
    expect(action.notes, contains('[ ] Take a photo'));
    expect(action.notes, contains('Area: Family'));
    expect(plan.warnings[ImportWarning.detailsInNotes], 1);
  });

  test('blank checklist entries do not claim to preserve details', () {
    final plan = parse(
      modify: (db) {
        db.execute("UPDATE TMChecklistItem SET title='   '");
      },
    );
    final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
    expect(action.notes, 'Bring tape\n\nSection: Preparation');
    expect(plan.warnings[ImportWarning.detailsInNotes], isNull);
  });

  test('children of trashed headings and closed projects stay excluded', () {
    for (final sql in [
      "UPDATE TMTask SET trashed=1 WHERE uuid='heading'",
      "UPDATE TMTask SET status=3 WHERE uuid='project'",
    ]) {
      final plan = parse(modify: (db) => db.execute(sql));
      expect(plan.items.any((i) => i.title == 'Measure walls'), isFalse);
      expect(plan.warnings[ImportWarning.completedSkipped], 4);
    }
  });

  test('Someday projects keep their children out of Next Actions', () {
    final plan = parse(
      modify: (db) =>
          db.execute("UPDATE TMTask SET start=2 WHERE uuid='project'"),
    );
    expect(plan.projects.single.status, ProjectStatus.someday);
    expect(
      plan.items.singleWhere((i) => i.title == 'Measure walls').status,
      ItemStatus.someday,
    );
  });

  test('project start defers children and inherited tags stay attached', () {
    final plan = parse(
      modify: (db) {
        db.execute(
          "UPDATE TMTask SET startDate=(2026 << 16) | (11 << 12) | (8 << 7) WHERE uuid='project'",
        );
        db.execute("INSERT INTO TMTag VALUES ('tag-work', 'computer', NULL)");
        db.execute("INSERT INTO TMTaskTag VALUES ('project', 'tag-work')");
      },
    );
    final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
    expect(action.deferUntil, DateTime(2026, 11, 8));
    expect(action.tags, ['@home', 'weekend', 'computer']);
  });

  test('invalid packed dates are warned and preserved, never rolled forward', () {
    final plan = parse(
      modify: (db) => db.execute(
        "UPDATE TMTask SET deadline = (2026 << 16) | (2 << 12) | (30 << 7) WHERE uuid='action'",
      ),
    );
    final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
    expect(action.dueAt, isNull);
    expect(action.notes, contains('Things deadline:'));
    expect(plan.warnings[ImportWarning.unparsedDate], 1);
  });

  test('legacy schema decodes Unix dates and actionGroup membership', () {
    final day = DateTime(2026, 11, 10, 12);
    final plan = parse(
      modify: (db) {
        db.execute('ALTER TABLE TMTask RENAME COLUMN deadline TO dueDate');
        db.execute('ALTER TABLE TMTask RENAME COLUMN heading TO actionGroup');
        db.execute('UPDATE TMTask SET startDate=NULL, dueDate=NULL');
        db.execute("UPDATE TMTask SET dueDate=? WHERE uuid='action'", [
          day.millisecondsSinceEpoch / 1000,
        ]);
      },
    );
    final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
    expect(action.project, 'Kitchen');
    expect(action.dueAt, DateTime(2026, 11, 10));
  });

  test('repeat templates do not create duplicate actionable tasks', () {
    final plan = parse(
      modify: (db) {
        db.execute(
          "UPDATE TMTask SET rt1_recurrenceRule=x'0102' WHERE uuid='someday'",
        );
        db.execute(
          "UPDATE TMTask SET rt1_repeatingTemplate='someday', reminderTime=123 WHERE uuid='action'",
        );
      },
    );
    expect(plan.items, hasLength(2));
    final action = plan.items.singleWhere((i) => i.title == 'Measure walls');
    expect(action.repeat, isNull);
    expect(action.notes, contains('recreate its repeat schedule'));
    expect(plan.warnings[ImportWarning.thingsRecurrence], 2);
    expect(plan.warnings[ImportWarning.sourceReminders], 1);
  });
}
