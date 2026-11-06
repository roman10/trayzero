import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cleartray/application/import_from_app.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/mappers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

List<int> _fixture(String name) =>
    File('test/fixtures/import/$name').readAsBytesSync();

List<int> _zip(Map<String, String> files) {
  final archive = Archive();
  files.forEach((name, text) {
    final bytes = utf8.encode(text);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  });
  return ZipEncoder().encode(archive);
}

void main() {
  late TestEnv env;
  late ImportFromApp import;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 10, 26, 10));
    import = env.container().read(importFromAppProvider);
  });
  tearDown(() => env.dispose());

  Future<List<Item>> allItems() async => [
    for (final row in await env.db.select(env.db.items).get()) row.toEntity(),
  ];

  test(
    'Google Tasks previews, preserves Done dates and undoes only new rows',
    () async {
      final plan = import.parseFile(
        ImportSourceApp.googleTasks,
        fileName: 'Tasks.json',
        bytes: _fixture('google_tasks.json'),
      );
      final preview = await import.preview(plan);
      expect(preview.total, 2);
      expect(preview.byStatus, {ItemStatus.inbox: 1, ItemStatus.done: 1});
      expect(preview.projects, isEmpty);
      final first = await import(plan);
      final second = await import(plan);
      final items = await allItems();
      expect(items, hasLength(4));
      expect(items.firstWhere((i) => i.status == ItemStatus.inbox).dueAt,
          DateTime(2026, 11, 5, 9));
      final done = items.firstWhere((i) => i.status == ItemStatus.done);
      expect(done.completedAt!.toUtc(), DateTime.utc(2026, 10, 21, 12, 30));
      expect(done.notes, contains('Subtask of: Buy groceries'));
      expect(
        items.firstWhere((i) => i.status == ItemStatus.inbox).notes,
        'Bring bags\n\nList: Home',
      );
      await import.undo(second);
      expect(
        (await allItems()).map((i) => i.id).toSet(),
        first.itemIds.toSet(),
      );
      expect(await import.wasImported(plan), isTrue);
      await import.undo(first);
      expect(await allItems(), isEmpty);
      expect(await import.wasImported(plan), isFalse);
    },
  );

  test(
    'duplicate history survives a new use case and renaming the file',
    () async {
      final bytes = _fixture('nirvana_export.csv');
      final plan = import.parseFile(
        ImportSourceApp.nirvana,
        fileName: 'a.csv',
        bytes: bytes,
      );
      expect(await import.wasImported(plan), isFalse);
      await import.preview(plan);
      expect(await import.wasImported(plan), isFalse);
      final receipt = await import(plan);
      final reopened = env.container().read(importFromAppProvider);
      final renamed = reopened.parseFile(
        ImportSourceApp.nirvana,
        fileName: 'b.csv',
        bytes: bytes,
      );
      expect(await reopened.wasImported(renamed), isTrue);
      final changed = reopened.parseText(
        ImportSourceApp.plainText,
        'Different task',
      );
      expect(await reopened.wasImported(changed), isFalse);
      await reopened.undo(receipt);
      expect(await reopened.wasImported(plan), isFalse);
    },
  );

  test('failed history write rolls back imported items too', () async {
    final plan = import.parseText(ImportSourceApp.plainText, 'Call Bob');
    await env.db.customStatement(
      "CREATE TRIGGER reject_import BEFORE INSERT ON import_batches BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(import(plan), throwsA(anything));
    expect(await allItems(), isEmpty);
    expect(await import.wasImported(plan), isFalse);
  });

  test(
    'renamed Todoist ZIP warns, but same CSV for another project does not',
    () async {
      final bytes = _zip({'Garage.csv': 'TYPE,CONTENT\ntask,Paint'});
      final plan = import.parseFile(
        ImportSourceApp.todoist,
        fileName: 'backup.zip',
        bytes: bytes,
      );
      await import(plan);
      expect(
        await import.wasImported(
          import.parseFile(
            ImportSourceApp.todoist,
            fileName: 'renamed.zip',
            bytes: bytes,
          ),
        ),
        isTrue,
      );
      final csv = utf8.encode('TYPE,CONTENT\ntask,Paint');
      await import(
        import.parseFile(
          ImportSourceApp.todoist,
          fileName: 'Garage.csv',
          bytes: csv,
        ),
      );
      expect(
        await import.wasImported(
          import.parseFile(
            ImportSourceApp.todoist,
            fileName: 'Kitchen.csv',
            bytes: csv,
          ),
        ),
        isFalse,
      );
    },
  );

  test('merges with existing Contexts and Projects instead of duplicating',
      () async {
    final contexts = env.container().read(contextRepositoryProvider);
    final projects = env.container().read(projectRepositoryProvider);
    await contexts.upsert(
      const GtdContext(id: 'c1', name: '@Errands', icon: 'x', color: 0),
    );
    await projects.upsert(
      Project(
        id: 'p1',
        title: 'Write A Blogpost About TaskPaper',
        status: ProjectStatus.active,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      ),
    );

    final plan = import.parseFile(
      ImportSourceApp.omniFocus,
      fileName: 'omnifocus.taskpaper',
      bytes: _fixture('omnifocus.taskpaper'),
    );
    final preview = await import.preview(plan);
    expect(preview.existingContexts, contains('@Errands'));
    expect(preview.newContexts, isNot(contains('@errands')));
    expect(
      preview.projects.where((p) => !p.isNew).map((p) => p.title),
      contains('Write A Blogpost About TaskPaper'),
    );

    final receipt = await import(plan);
    expect(receipt.projectIds, isNot(contains('p1')));
    expect(receipt.contextIds, isNot(contains('c1')));
    expect(await contexts.all(), hasLength(1 + receipt.contextIds.length));
    final names = (await contexts.all()).map((c) => c.name.toLowerCase());
    expect(names.toSet().length, names.length);

    final stamps = (await allItems()).singleWhere(
      (i) => i.title == 'Buy stamps',
    );
    expect(stamps.contextId, 'c1');
    expect(stamps.status, ItemStatus.inbox);
  });

  test('a second import of the same file reuses what the first created',
      () async {
    final bytes = _fixture('nirvana_export.csv');
    final first = await import(
      import.parseFile(ImportSourceApp.nirvana, fileName: 'n.csv', bytes: bytes),
    );
    final second = await import(
      import.parseFile(ImportSourceApp.nirvana, fileName: 'n.csv', bytes: bytes),
    );
    expect(first.projectIds, isNotEmpty);
    expect(second.projectIds, isEmpty);
    expect(second.contextIds, isEmpty);
  });

  test('schedules reminders for dated items after the commit', () async {
    final plan = import.parseFile(
      ImportSourceApp.nirvana,
      fileName: 'n.csv',
      bytes: _fixture('nirvana_export.csv'),
    );
    final receipt = await import(plan);
    expect(receipt.remindersFailed, isFalse);
    expect(env.scheduler.scheduled, isNotEmpty);
  });

  test('undo removes only what the import created', () async {
    final items = env.container().read(itemRepositoryProvider);
    final contexts = env.container().read(contextRepositoryProvider);
    await items.upsert(
      Item(
        id: 'mine',
        title: 'Already here',
        status: ItemStatus.nextAction,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      ),
    );

    final receipt = await import(
      import.parseFile(
        ImportSourceApp.tickTick,
        fileName: 't.csv',
        bytes: _fixture('ticktick_backup.csv'),
      ),
    );
    expect(receipt.contextIds, isNotEmpty);
    // The user files something of their own under an imported Context
    // before undoing: that Context must survive.
    final kept = receipt.contextIds.first;
    await items.upsert(
      Item(
        id: 'later',
        title: 'Filed after import',
        status: ItemStatus.nextAction,
        contextId: kept,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      ),
    );

    await import.undo(receipt);
    expect((await allItems()).map((i) => i.id), unorderedEquals(['mine', 'later']));
    expect(await env.container().read(projectRepositoryProvider).watchAll().first,
        isEmpty);
    expect((await contexts.all()).map((c) => c.id), [kept]);
  });

  test(
    'source tags become tags and people; undo removes unused ones',
    () async {
      final manage = env.container().read(manageTagsProvider);
      final tags = env.container().read(tagRepositoryProvider);
      final kitchen = (await manage.obtain('kitchen'))!;
      final plan = import.parseText(
        ImportSourceApp.omniFocus,
        '- Budget @tags(Agendas : Alice, Kitchen)\n'
        '- Drill @tags(Agenda/Bob, Garage)\n',
      );
      final preview = await import.preview(plan);
      expect(preview.newTags, ['Alice', 'Bob', 'Garage']);
      expect(preview.existingTags, ['kitchen']);

      final receipt = await import(plan);
      final byName = {for (final t in await tags.all()) t.name: t};
      expect(byName.keys, ['Alice', 'Bob', 'Garage', 'kitchen']);
      expect(byName['Alice']!.isPerson, isTrue);
      expect(byName['Garage']!.isPerson, isFalse);
      final rows = await env.db.select(env.db.items).get();
      final budget = rows
          .map((r) => r.toEntity())
          .singleWhere((i) => i.title == 'Budget');
      expect(budget.notes, isNull);
      expect((await tags.tagIdsFor(budget.id)).toSet(), {
        byName['Alice']!.id,
        kitchen.id,
      });

      // Something of the user's now uses Garage, so undo keeps it.
      await env
          .container()
          .read(itemRepositoryProvider)
          .upsert(anItem(id: 'mine', status: ItemStatus.nextAction));
      await manage.setItemTags('mine', [byName['Garage']!.id]);

      await import.undo(receipt);
      expect((await tags.all()).map((t) => t.name), ['Garage', 'kitchen']);
    },
  );

  test('a Todoist backup ZIP imports every project CSV', () async {
    final bytes = _zip({
      'Inbox.csv': 'TYPE,CONTENT,PRIORITY,INDENT,DATE\ntask,Call Ana,4,1,\n',
      'Garage [123].csv':
          'TYPE,CONTENT,PRIORITY,INDENT,DATE\ntask,Sweep,4,1,\n',
      'Someday.csv': 'TYPE,CONTENT,PRIORITY,INDENT,DATE\ntask,Kayak,4,1,\n',
      '__MACOSX/._Garage.csv': 'junk',
      'readme.txt': 'not a csv',
    });
    final plan = import.parseFile(
      ImportSourceApp.todoist,
      fileName: 'backup.zip',
      bytes: bytes,
    );
    await import(plan);
    final byTitle = {for (final i in await allItems()) i.title: i};
    expect(byTitle['Call Ana']!.status, ItemStatus.inbox);
    expect(byTitle['Kayak']!.status, ItemStatus.someday);
    expect(byTitle['Sweep']!.projectId, isNotNull);
    final project = await env.container()
        .read(projectRepositoryProvider)
        .getById(byTitle['Sweep']!.projectId!);
    expect(project!.title, 'Garage');
  });

  group('decoding and failures', () {
    test('UTF-16 with a byte-order mark decodes', () {
      final units = '﻿Call Mom\nÜ-Bahn\n'.codeUnits;
      final le = [
        for (final u in units) ...[u & 0xFF, u >> 8],
      ];
      final be = [
        for (final u in units) ...[u >> 8, u & 0xFF],
      ];
      // The BOM is the first code unit: FF FE / FE FF.
      expect(decodeImportText(le), 'Call Mom\nÜ-Bahn\n');
      expect(decodeImportText(be), 'Call Mom\nÜ-Bahn\n');
    });

    test('binary input is unreadable', () {
      expect(
        () => import.parseFile(
          ImportSourceApp.plainText,
          fileName: 'x.bin',
          bytes: _fixture('binary.bin'),
        ),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.failure,
            'failure',
            ImportFailure.unreadable,
          ),
        ),
      );
    });

    test('a ZIP for a source that never exports one is unrecognized', () {
      expect(
        () => import.parseFile(
          ImportSourceApp.tickTick,
          fileName: 'x.zip',
          bytes: _zip({'a.csv': 'x'}),
        ),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.failure,
            'failure',
            ImportFailure.unrecognized,
          ),
        ),
      );
    });

    test('empty or blank input has nothing to import', () {
      for (final source in ImportSourceApp.values) {
        expect(
          () => import.parseText(source, ' \n\t'),
          throwsA(
            isA<ImportFormatException>().having(
              (e) => e.failure,
              'failure',
              ImportFailure.noTasks,
            ),
          ),
          reason: source.name,
        );
      }
    });
  });
}
