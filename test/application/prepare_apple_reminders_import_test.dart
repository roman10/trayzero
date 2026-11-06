import 'package:cleartray/application/prepare_apple_reminders_import.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/apple_reminders_gateway.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/mappers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/apple_reminders_fake.dart';
import '../support/harness.dart';

void main() {
  late FakeAppleRemindersGateway gateway;
  late PrepareAppleRemindersImport prepare;
  setUp(() {
    gateway = FakeAppleRemindersGateway();
    prepare = PrepareAppleRemindersImport(gateway);
  });

  test(
    'reads only the selection; skips completed, blank, duplicate and foreign rows',
    () async {
      gateway.reminders = const [
        AppleReminder(
          id: 'a',
          listId: 'home',
          title: 'Call Mum',
          notes: 'Bring photos',
          url: 'https://example.com',
        ),
        AppleReminder(id: 'a', listId: 'home', title: 'Duplicate result'),
        AppleReminder(id: 'b', listId: 'home', title: 'Done', completed: true),
        AppleReminder(id: 'c', listId: 'home', title: '  '),
        AppleReminder(id: 'd', listId: 'work', title: 'Private work reminder'),
        AppleReminder(id: 'e', listId: 'inbox', title: 'Capture'),
      ];
      final plan = await prepare(gateway.lists, {'home', 'inbox'});
      expect(gateway.reads, [
        {'home', 'inbox'},
      ]);
      expect(plan.source, ImportSourceApp.appleReminders);
      expect(plan.items.map((item) => item.title), ['Call Mum', 'Capture']);
      expect(
        plan.items.first.notes,
        'Bring photos\n\nhttps://example.com\n\nList: Home\n\nAccount: iCloud',
      );
      expect(plan.items.last.status, ItemStatus.inbox);
      expect(plan.projects.map((project) => project.title), ['Home']);
      expect(plan.warnings, {
        ImportWarning.completedSkipped: 1,
        ImportWarning.unreadableRows: 1,
      });
    },
  );

  test(
    'rejects empty/stale selection before reading any source data',
    () async {
      for (final selected in [
        <String>{},
        {'missing'},
      ]) {
        await expectLater(
          prepare(gateway.lists, selected),
          throwsA(isA<AppleRemindersException>()),
        );
      }
      expect(gateway.reads, isEmpty);
    },
  );

  test(
    'empty or completed-only selections do not create empty projects',
    () async {
      gateway.reminders = const [
        AppleReminder(id: 'a', listId: 'home', title: 'Done', completed: true),
      ];
      await expectLater(
        prepare(gateway.lists, {'home'}),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.failure,
            'failure',
            ImportFailure.noTasks,
          ),
        ),
      );
    },
  );

  test(
    'preserves valid recurrence and warns for dates, unsupported repeats, alerts and priorities',
    () async {
      gateway.reminders = const [
        AppleReminder(
          id: 'a',
          listId: 'home',
          title: 'Water',
          due: '2026-11-05',
          dueIsDateOnly: true,
          recurrenceRules: ['FREQ=WEEKLY;INTERVAL=2;BYDAY=TH'],
          priority: 1,
          hasAlarms: true,
        ),
        AppleReminder(
          id: 'b',
          listId: 'home',
          title: 'Complex',
          start: '2026-11-05',
          recurrenceRules: ['FREQ=MONTHLY;BYMONTHDAY=1,15'],
        ),
        AppleReminder(
          id: 'c',
          listId: 'home',
          title: 'Broken date',
          due: '2026-02-30',
          recurrenceRules: ['FREQ=DAILY'],
        ),
        AppleReminder(
          id: 'd',
          listId: 'home',
          title: 'Timed end',
          due: '2026-11-05',
          recurrenceRules: ['FREQ=DAILY;UNTIL=2026-12-01T12:00:00Z'],
        ),
        AppleReminder(
          id: 'f',
          listId: 'home',
          title: 'Limited series',
          due: '2026-11-05',
          recurrenceRules: ['FREQ=DAILY;COUNT=10'],
        ),
        AppleReminder(
          id: 'e',
          listId: 'home',
          title: 'Multiple rules',
          due: '2026-11-05',
          recurrenceRules: ['FREQ=DAILY', 'FREQ=WEEKLY'],
        ),
      ];
      final plan = await prepare(gateway.lists, {'home'});
      final repeat = plan.items.first.repeat!;
      expect(repeat.frequency, Recurrence.weekly);
      expect(repeat.interval, 2);
      expect(repeat.byWeekdays, [4]);
      expect(
        plan.items[1].notes,
        contains('Repeats: FREQ=MONTHLY;BYMONTHDAY=1,15'),
      );
      expect(plan.items[2].notes, contains('Due: 2026-02-30'));
      expect(plan.warnings[ImportWarning.repeatInNotes], 5);
      expect(plan.warnings[ImportWarning.unparsedDate], 1);
      expect(plan.warnings[ImportWarning.notImported], 1);
    },
  );

  test(
    'complex recurrence intersections and skipped dates are retained, never simplified',
    () async {
      const unsupported = [
        'FREQ=MONTHLY;BYDAY=2TU;BYSETPOS=1,-1',
        'FREQ=MONTHLY;BYDAY=2TU;BYMONTHDAY=10',
        'FREQ=DAILY;BYMONTHDAY=10',
        'FREQ=MONTHLY;BYMONTH=11',
        'FREQ=WEEKLY;INTERVAL=2;BYDAY=SU,MO;WKST=SU',
        'FREQ=MONTHLY;BYDAY=5TU',
      ];
      gateway.reminders = [
        for (var i = 0; i < unsupported.length; i++)
          AppleReminder(
            id: '$i',
            listId: 'home',
            title: 'Rule $i',
            due: '2026-11-10',
            recurrenceRules: [unsupported[i]],
          ),
        const AppleReminder(
          id: 'month-end',
          listId: 'home',
          title: 'Month end',
          due: '2026-01-31',
          recurrenceRules: ['FREQ=MONTHLY'],
        ),
        const AppleReminder(
          id: 'leap',
          listId: 'home',
          title: 'Leap day',
          due: '2028-02-29',
          recurrenceRules: ['FREQ=YEARLY'],
        ),
      ];
      final plan = await prepare(gateway.lists, {'home'});
      expect(plan.items.every((item) => item.repeat == null), isTrue);
      expect(
        plan.items.every((item) => item.notes!.contains('Repeats:')),
        isTrue,
      );
      expect(plan.warnings[ImportWarning.repeatInNotes], 8);
    },
  );

  test('ordinary monthly ordinal and yearly rules remain functional', () async {
    gateway.reminders = const [
      AppleReminder(
        id: 'monthly',
        listId: 'home',
        title: 'Monthly',
        due: '2026-11-10',
        recurrenceRules: ['FREQ=MONTHLY;BYDAY=2TU'],
      ),
      AppleReminder(
        id: 'yearly',
        listId: 'home',
        title: 'Yearly',
        due: '2026-11-10',
        recurrenceRules: ['FREQ=YEARLY;BYMONTH=11;BYMONTHDAY=10'],
      ),
    ];
    final plan = await prepare(gateway.lists, {'home'});
    expect(plan.items.first.repeat!.monthlyWeek, 2);
    expect(plan.items.first.repeat!.monthlyWeekday, DateTime.tuesday);
    expect(plan.items.last.repeat!.frequency, Recurrence.yearly);
    expect(plan.warnings, isEmpty);
  });

  test(
    'preview writes nothing; commit preserves midnight vs date-only, merges projects, and Undo preserves existing data',
    () async {
      final env = await TestEnv.create(now: DateTime(2026, 11, 3));
      addTearDown(env.dispose);
      final container = env.container();
      final items = container.read(itemRepositoryProvider);
      final projects = container.read(projectRepositoryProvider);
      await projects.upsert(
        Project(
          id: 'existing-project',
          title: 'Home',
          status: ProjectStatus.active,
          createdAt: env.clock.now(),
          updatedAt: env.clock.now(),
        ),
      );
      final existing = Item(
        id: 'existing-item',
        title: 'Already here',
        status: ItemStatus.nextAction,
        projectId: 'existing-project',
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      );
      await items.upsert(existing);
      gateway.reminders = [
        // Local ISO midnight is deliberately timed, not an all-day reminder.
        const AppleReminder(
          id: 'a',
          listId: 'home',
          title: 'Midnight',
          due: '2026-11-05T00:00:00',
        ),
        const AppleReminder(
          id: 'b',
          listId: 'home',
          title: 'Date only',
          due: '2026-11-06',
          dueIsDateOnly: true,
        ),
        const AppleReminder(
          id: 'c',
          listId: 'home',
          title: 'Timed',
          due: '2026-11-07T12:15:00+08:00',
          start: '2026-11-04',
        ),
        const AppleReminder(id: 'd', listId: 'inbox', title: 'Unsorted'),
      ];
      final plan = await prepare(gateway.lists, {'home', 'inbox'});
      final importer = container.read(importFromAppProvider);
      final preview = await importer.preview(plan);
      expect(preview.total, 4);
      expect(preview.projects.single.isNew, isFalse);
      expect((await env.db.select(env.db.items).get()), hasLength(1));
      final receipt = await importer(plan);
      final imported = (await env.db.select(env.db.items).get())
          .map((row) => row.toEntity())
          .where((item) => item.id != existing.id)
          .toList();
      Item byTitle(String title) =>
          imported.singleWhere((item) => item.title == title);
      expect(byTitle('Midnight').dueAt, DateTime(2026, 11, 5));
      expect(byTitle('Date only').dueAt, DateTime(2026, 11, 6, 9));
      expect(
        byTitle('Timed').dueAt,
        DateTime.parse('2026-11-07T12:15:00+08:00').toLocal(),
      );
      expect(byTitle('Timed').deferUntil, DateTime(2026, 11, 4));
      expect(byTitle('Midnight').status, ItemStatus.calendar);
      expect(byTitle('Unsorted').status, ItemStatus.inbox);
      expect(receipt.projectIds, isEmpty);
      expect(receipt.remindersFailed, isFalse);
      expect(
        env.scheduler.scheduled.any(
          (entry) => entry.at == DateTime(2026, 11, 5),
        ),
        isTrue,
      );
      expect(
        env.scheduler.scheduled.any(
          (entry) => entry.at == DateTime(2026, 11, 6, 9),
        ),
        isTrue,
      );
      await importer.undo(receipt);
      expect((await env.db.select(env.db.items).get()).single.id, existing.id);
      expect((await projects.watchAll().first).single.id, 'existing-project');
      for (final id in receipt.itemIds) {
        expect(env.scheduler.cancelled, contains(notificationIdFor(id, 1)));
        expect(env.scheduler.cancelled, contains(notificationIdFor(id, 2)));
      }
      expect(gateway.reminders, hasLength(4));
    },
  );
}
