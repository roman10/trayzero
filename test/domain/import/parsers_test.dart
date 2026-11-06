import 'dart:convert';
import 'dart:io';

import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/domain/import/nirvana_parser.dart';
import 'package:cleartray/domain/import/taskpaper_parser.dart';
import 'package:cleartray/domain/import/ticktick_parser.dart';
import 'package:cleartray/domain/import/todoist_parser.dart';
import 'package:flutter_test/flutter_test.dart';

String fixture(String name) =>
    utf8.decode(File('test/fixtures/import/$name').readAsBytesSync());

ImportedItem byTitle(ImportPlan plan, String title) =>
    plan.items.singleWhere((i) => i.title == title);

void main() {
  final now = DateTime(2026, 10, 26, 10); // a Monday

  group('Todoist', () {
    late ImportPlan plan;
    setUp(() {
      plan = parseTodoist([
        (name: 'Garage [2203306141].csv', text: fixture('todoist_garage.csv')),
      ], now: now);
    });

    test('the file is one Project named after the file', () {
      expect(plan.projects.map((p) => p.title), ['Garage']);
      expect(plan.items.every((i) => i.project == 'Garage'), isTrue);
      expect(todoistProjectName('backup/Inbox [1].csv'), 'Inbox');
    });

    test('official template metadata is not an unreadable task', () {
      final template = parseTodoist([
        (name: 'Example.csv', text: fixture('todoist_official_template.csv')),
      ], now: now);
      expect(template.items, hasLength(4));
      expect(template.warnings, isNot(contains(ImportWarning.unreadableRows)));
      expect(template.warnings[ImportWarning.subtasksFlattened], 2);
      expect(
        template.items.first.notes,
        contains('Only available on Tuesdays and Thursdays'),
      );
    });

    test('metadata rows preserve section, parent and comment association', () {
      final p = parseTodoist([
        (
          name: 'Work.csv',
          text:
              'TYPE,CONTENT,INDENT\n'
              'meta,view_style=board,\n'
              'section,Preparation,\n'
              'task,Parent,1\n'
              'meta,unknown_future_setting=value,\n'
              'note,Keep this note with Parent,\n'
              'task,Child,2\n',
        ),
      ], now: now);
      expect(p.items.map((i) => i.title), ['Parent', 'Child']);
      expect(
        byTitle(p, 'Parent').notes,
        'Section: Preparation\n\nKeep this note with Parent',
      );
      expect(
        byTitle(p, 'Child').notes,
        'Section: Preparation\n\nSubtask of: Parent',
      );
      expect(p.warnings, isNot(contains(ImportWarning.unreadableRows)));
    });

    test('metadata does not hide unknown row types or malformed tasks', () {
      final p = parseTodoist([
        (
          name: 'Inbox.csv',
          text:
              'TYPE,CONTENT\n'
              'meta,view_style=list\n'
              'task,Valid task\n'
              'unknown,Unrecognized content\n'
              ',Missing type\n'
              'task,\n',
        ),
      ], now: now);
      expect(p.items.single.title, 'Valid task');
      expect(p.warnings[ImportWarning.unreadableRows], 3);
    });

    test('labels leave the title; description and notes are kept', () {
      final call = byTitle(plan, 'Call hardware store');
      expect(call.tags, ['phone', 'urgent']);
      expect(
        call.notes,
        'Ask about shelves, hooks, and bins\n\nBring measurements, they asked',
      );
      expect(call.dueAt, DateTime(2026, 11, 3));
      expect(call.timeEstimateMinutes, 15);
    });

    test('sections and subtasks are kept in notes', () {
      final sort = byTitle(plan, 'Sort boxes');
      expect(sort.notes, 'Section: Clear out');
      final label = byTitle(plan, 'Label the bins');
      expect(
        label.notes,
        'Line one\nLine two\n\nSection: Clear out\n\nSubtask of: Sort boxes',
      );
      expect(plan.warnings[ImportWarning.subtasksFlattened], 1);
    });

    test('DATE becomes the start date when a DEADLINE exists', () {
      final sort = byTitle(plan, 'Sort boxes');
      expect(sort.deferUntil, DateTime(2026, 11, 5));
      expect(sort.dueAt, DateTime(2026, 11, 20));
    });

    test('simple repeats map; others stay in notes', () {
      final water = byTitle(plan, 'Water the plants');
      expect(water.tags, ['Büro']);
      expect(water.repeat!.frequency, Recurrence.weekly);
      expect(water.repeat!.byWeekdays, [DateTime.monday]);
      expect(water.dueAt, DateTime(2026, 10, 26, 9));

      final cafe = byTitle(plan, 'Café Größe 日本語');
      expect(cafe.repeat, isNull);
      expect(cafe.notes, 'Section: Clear out\n\nRepeats: every 2nd tue');
      expect(plan.warnings[ImportWarning.repeatInNotes], 1);

      final gutters = byTitle(plan, 'Check gutters');
      expect(gutters.notes, 'Section: Clear out\n\nDate: someday soonish');
      expect(plan.warnings[ImportWarning.unparsedDate], 1);
    });

    test('blank titles are skipped; assignee and priority are counted', () {
      expect(plan.items, hasLength(6));
      expect(plan.warnings[ImportWarning.unreadableRows], 1);
      // "Call hardware store" has priority 1 (others 4), "Label the bins"
      // has an assignee.
      expect(plan.warnings[ImportWarning.notImported], 2);
    });

    test('an Inbox or Someday file maps to that list without a Project', () {
      final p = parseTodoist([
        (name: 'Inbox [1].csv', text: 'TYPE,CONTENT\ntask,Milk'),
        (name: 'Someday [2].csv', text: 'TYPE,CONTENT\ntask,Sail'),
      ], now: now);
      expect(p.projects, isEmpty);
      expect(byTitle(p, 'Milk').status, ItemStatus.inbox);
      expect(byTitle(p, 'Sail').status, ItemStatus.someday);
    });

    test('a CSV without TYPE/CONTENT is not a Todoist export', () {
      expect(
        () => parseTodoist([(name: 'x.csv', text: 'a,b\n1,2')], now: now),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.failure,
            'failure',
            ImportFailure.unrecognized,
          ),
        ),
      );
    });
  });

  group('TickTick', () {
    late ImportPlan plan;
    setUp(() => plan = parseTickTick(fixture('ticktick_backup.csv')));

    test('skips the preamble; lists become Projects or GTD lists', () {
      expect(plan.projects.map((p) => p.title), ['Renovation', 'Routines']);
      expect(byTitle(plan, 'Buy milk').status, ItemStatus.inbox);
      expect(byTitle(plan, 'Learn Portuguese').status, ItemStatus.someday);
      expect(byTitle(plan, 'Paint codes').status, ItemStatus.reference);
      expect(byTitle(plan, 'Paint codes').notes, 'RAL 9010');
    });

    test('completed and archived rows are skipped; blank titles counted', () {
      expect(plan.items.any((i) => i.title == 'Old task'), isFalse);
      expect(plan.warnings[ImportWarning.completedSkipped], 1);
      expect(plan.warnings[ImportWarning.unreadableRows], 1);
    });

    test('a date range keeps its start; multiline content survives', () {
      final paint = byTitle(plan, 'Paint the hallway');
      expect(paint.deferUntil, DateTime(2026, 11, 1));
      expect(paint.dueAt, DateTime(2026, 11, 8));
      expect(paint.tags, ['@errands', 'weekend']);
      expect(
        paint.notes,
        'Colours: white, grey\nCheck the ceiling\n\nFolder: Home\n\n'
        'Section: Prep',
      );
      expect(plan.warnings[ImportWarning.notImported], 1);
    });

    test('one date is the due date; RRULEs map when exact', () {
      final vitamins = byTitle(plan, 'Take vitamins 💊');
      expect(vitamins.dueAt, DateTime.parse('2026-10-27T07:30:00Z').toLocal());
      expect(vitamins.deferUntil, isNull);
      expect(vitamins.repeat!.byWeekdays, [1, 3, 5]);
      final skip = byTitle(plan, 'Skip-weekend thing');
      expect(skip.repeat, isNull);
      expect(skip.notes, contains('Repeats: RRULE:FREQ=DAILY'));
    });

    test('subtasks name their parent', () {
      expect(
        byTitle(plan, 'Buy brushes').notes,
        'Folder: Home\n\nSubtask of: Paint the hallway',
      );
    });

    test('all-day and floating values keep their wall date across offsets', () {
      const header =
          'Folder Name,List Name,Title,Start Date,Is All Day,Is Floating,Status';
      final plan = parseTickTick(
        '$header\n,Inbox,All day,2026-11-03T00:00:00+1400,true,false,0\n'
        ',Inbox,Floating,2026-11-03T23:30:00-1200,false,true,0',
      );
      expect(byTitle(plan, 'All day').dueAt, DateTime(2026, 11, 3));
      expect(byTitle(plan, 'Floating').dueAt, DateTime(2026, 11, 3, 23, 30));
    });

    test('reordered columns, new columns and child-before-parent exports', () {
      final plan = parseTickTick(
        'projectKind,Title,List Name,Folder Name,parentId,taskId,Status,Repeat,Start Date\n'
        'TASK,Child,Garage,Home,parent,child,0,,\n'
        'TASK,Parent,Garage,Home,,parent,0,FREQ=WEEKLY;INTERVAL=2,2026-11-03 09:00:00',
      );
      expect(byTitle(plan, 'Child').notes, contains('Subtask of: Parent'));
      expect(byTitle(plan, 'Parent').repeat!.interval, 2);
      expect(plan.projects.single.title, 'Garage');
    });

    test('a CSV without the TickTick header is rejected', () {
      expect(
        () => parseTickTick('Title,Due\nA,B'),
        throwsA(isA<ImportFormatException>()),
      );
    });
  });

  group('Nirvana', () {
    test('CSV: states, projects, waiting, scheduled, energy, recurring', () {
      final plan = parseNirvana(fixture('nirvana_export.csv'));
      expect(
        {for (final p in plan.projects) p.title: (p.status, p.outcome)},
        {
          'Plan trip': (ProjectStatus.active, 'Two weeks in Japan'),
          'Write a novel': (ProjectStatus.someday, null),
        },
      );
      expect(byTitle(plan, 'Read email from Sam').status, ItemStatus.inbox);
      final flights = byTitle(plan, 'Book flights');
      expect(flights.project, 'Plan trip');
      expect(flights.tags, ['computer', 'errands']);
      expect(flights.energy, Energy.medium);
      expect(flights.timeEstimateMinutes, 30);
      expect(flights.dueAt, DateTime(2026, 11, 15));
      final visa = byTitle(plan, 'Visa paperwork');
      expect((visa.status, visa.waitingOn), (ItemStatus.waiting, 'Embassy'));
      expect(byTitle(plan, 'Pack bags').deferUntil, DateTime(2026, 12, 1));
      expect(byTitle(plan, 'Learn to juggle').status, ItemStatus.someday);
      final water = byTitle(plan, 'Water plants');
      expect(water.repeat!.frequency, Recurrence.weekly);
      expect(water.deferUntil, DateTime(2026, 11, 2));
      expect(plan.items.any((i) => i.title == 'Renew passport'), isFalse);
      expect(plan.warnings[ImportWarning.completedSkipped], 1);
    });

    test('JSON with word states and @ tags', () {
      final plan = parseNirvana(fixture('nirvana_export.json'));
      expect(plan.projects.single.outcome, 'New cabinets');
      expect(byTitle(plan, 'Measure walls').tags, ['@home']);
      expect(byTitle(plan, 'Measure walls').energy, Energy.low);
      expect(byTitle(plan, 'Herb garden').status, ItemStatus.someday);
      expect(plan.items, hasLength(2));
    });

    test('a file without name and state fields is rejected', () {
      expect(
        () => parseNirvana('title,due\nA,B'),
        throwsA(isA<ImportFormatException>()),
      );
      expect(
        () => parseNirvana('{not json'),
        throwsA(isA<ImportFormatException>()),
      );
    });
  });

  group('TaskPaper / OmniFocus', () {
    late ImportPlan plan;
    setUp(() {
      plan = parseTaskPaper(
        fixture('omnifocus.taskpaper'),
        source: ImportSourceApp.omniFocus,
        now: now,
      );
    });

    test(
      'a top-level task with children is a Project; a lone one is Inbox',
      () {
        expect(byTitle(plan, 'Buy stamps').status, ItemStatus.inbox);
        expect(byTitle(plan, 'Buy stamps').tags, ['Errands']);
        final project = plan.projects.firstWhere(
          (p) => p.title == 'Write a blogpost about TaskPaper',
        );
        expect(project.outcome, 'Draft by Friday.');
      },
    );

    test('OmniFocus parameters', () {
      final find = byTitle(plan, 'Find out what TaskPaper is');
      expect(find.tags, ['@Wohnung']);
      expect(find.dueAt, DateTime(2019, 11, 14, 22));
      final compare = byTitle(plan, 'Compare to todo.txt');
      expect(compare.tags, ['Research', 'Deep work']);
      expect(compare.deferUntil, DateTime(2026, 11, 2));
      expect(compare.timeEstimateMinutes, 90);
      expect(plan.items.any((i) => i.title == 'Already done'), isFalse);
    });

    test('action groups flatten; relative dates stay in notes', () {
      expect(byTitle(plan, 'Intro').notes, 'Subtask of: Outline');
      expect(
        byTitle(plan, 'Conclusion').notes,
        'Subtask of: Outline\n\nDue: next Thursday -3d',
      );
      expect(plan.warnings[ImportWarning.notImported], 1); // @flagged
      expect(plan.warnings[ImportWarning.unparsedDate], 1);
    });

    test('folders, on-hold and dropped projects', () {
      final garden = plan.projects.firstWhere((p) => p.title == 'Garden');
      expect(garden.outcome, 'Folder: Errands Folder');
      expect(plan.projects.any((p) => p.title == 'Errands Folder'), isFalse);
      final door = byTitle(plan, 'Fix door');
      expect(door.repeat!.monthlyWeek, 2);
      expect(door.repeat!.monthlyWeekday, DateTime.tuesday);
      expect(
        plan.projects.firstWhere((p) => p.title == 'Paused project').status,
        ProjectStatus.onHold,
      );
      expect(plan.projects.any((p) => p.title == 'Dropped project'), isFalse);
      // "Already done" plus the dropped project's open task.
      expect(plan.warnings[ImportWarning.completedSkipped], 2);
    });

    test('plain lines (Things copy) become Inbox tasks with notes', () {
      final things = parseTaskPaper(
        fixture('things_copy.txt'),
        source: ImportSourceApp.plainText,
        now: now,
      );
      expect(things.items.map((i) => (i.title, i.status, i.notes)), [
        ('Call Mom', ItemStatus.inbox, null),
        ('Pay rent', ItemStatus.inbox, 'remember the new account'),
        ('Ü-Bahn Ticket kaufen', ItemStatus.inbox, null),
      ]);
    });

    test('checkbox lists and bare @tags', () {
      final p = parseTaskPaper(
        'Errands:\n- [ ] Post office @phone\n- [x] Bank\n✓ Done thing\n',
        source: ImportSourceApp.plainText,
        now: now,
      );
      expect(p.items.map((i) => i.title), ['Post office']);
      expect(p.items.single.tags, ['@phone']);
      expect(p.warnings[ImportWarning.completedSkipped], 2);
      expect(byTitle(p, 'Post office').project, 'Errands');
    });

    test('a flush line after an indented project block leaves the project', () {
      final p = parseTaskPaper(
        'Garden:\n\t- Buy soil\n\t- Prune roses\nCall Mom\nHouse:\n'
        '\t- Fix door\n- Pay rent\n',
        source: ImportSourceApp.plainText,
        now: now,
      );
      expect(p.items.map((i) => (i.title, i.project, i.status)), [
        ('Buy soil', 'Garden', ItemStatus.nextAction),
        ('Prune roses', 'Garden', ItemStatus.nextAction),
        ('Call Mom', null, ItemStatus.inbox),
        ('Fix door', 'House', ItemStatus.nextAction),
        ('Pay rent', null, ItemStatus.inbox),
      ]);
      expect(p.projects.map((x) => x.outcome), [null, null]);
    });

    test('blank input has nothing to import', () {
      expect(
        () => parseTaskPaper(
          '\n  \n',
          source: ImportSourceApp.plainText,
          now: now,
        ),
        throwsA(isA<ImportFormatException>()),
      );
    });
  });
}
