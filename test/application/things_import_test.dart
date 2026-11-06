import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/mappers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';
import '../support/things_fixture.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create(now: DateTime(2026, 11, 3, 10)));
  tearDown(() => env.dispose());

  test(
    'preview is read-only; confirm preserves organization and undo removes additions',
    () async {
      final container = env.container();
      final importer = container.read(importFromAppProvider);
      final plan = importer.parseFile(
        ImportSourceApp.things,
        fileName: 'main.sqlite',
        bytes: thingsFixture(),
      );
      final preview = await importer.preview(plan);
      expect(preview.total, 3);
      expect(preview.newAreas, ['Family']);
      expect(preview.newContexts, ['@home']);
      expect(preview.newTags, ['weekend']);
      expect(preview.byStatus[ItemStatus.calendar], 1);
      expect(await env.db.select(env.db.items).get(), isEmpty);
      expect(await env.db.select(env.db.areas).get(), isEmpty);

      final receipt = await importer(plan);
      final projects = await container
          .read(projectRepositoryProvider)
          .watchAll()
          .first;
      expect(projects.single.areaId, receipt.areaIds.single);
      final rows = (await env.db.select(env.db.items).get()).map(
        (r) => r.toEntity(),
      );
      final action = rows.singleWhere((i) => i.title == 'Measure walls');
      expect(action.projectId, projects.single.id);
      expect(action.contextId, receipt.contextIds.single);
      expect(action.status, ItemStatus.calendar);
      expect(action.dueAt, DateTime(2026, 11, 10, 9));
      expect(action.deferUntil, DateTime(2026, 11, 4));
      expect(env.scheduler.scheduled, isNotEmpty);

      await importer.undo(receipt);
      for (final table in ['items', 'projects', 'areas', 'contexts', 'tags']) {
        expect(
          (await env.db
                  .customSelect('SELECT COUNT(*) AS n FROM $table')
                  .getSingle())
              .read<int>('n'),
          0,
        );
      }
    },
  );

  test(
    'existing names merge and undo leaves existing organization untouched',
    () async {
      final container = env.container();
      final areas = container.read(areaRepositoryProvider);
      await areas.upsert(const Area(id: 'existing-area', name: ' family '));
      final importer = container.read(importFromAppProvider);
      final plan = importer.parseFile(
        ImportSourceApp.things,
        fileName: 'main.sqlite',
        bytes: thingsFixture(),
      );
      final first = await importer(plan);
      expect(first.areaIds, isEmpty);
      final project =
          (await container.read(projectRepositoryProvider).watchAll().first)
              .single;
      expect(project.areaId, 'existing-area');
      final second = await importer(plan);
      expect(second.projectIds, isEmpty);
      expect(second.areaIds, isEmpty);
      await importer.undo(second);
      expect(
        await container.read(projectRepositoryProvider).getById(project.id),
        isNotNull,
      );
      await importer.undo(first);
      expect(await areas.getById('existing-area'), isNotNull);
    },
  );

  test(
    'Things import history survives renaming and undo clears only its batch',
    () async {
      final importer = env.container().read(importFromAppProvider);
      final bytes = thingsFixture();
      final plan = importer.parseFile(
        ImportSourceApp.things,
        fileName: 'main.sqlite',
        bytes: bytes,
      );
      expect(await importer.wasImported(plan), isFalse);
      final first = await importer(plan);
      final renamed = importer.parseFile(
        ImportSourceApp.things,
        fileName: 'renamed.sqlite',
        bytes: bytes,
      );
      expect(await importer.wasImported(renamed), isTrue);
      final second = await importer(renamed);
      await importer.undo(second);
      expect(await importer.wasImported(renamed), isTrue);
      await importer.undo(first);
      expect(await importer.wasImported(plan), isFalse);
    },
  );

  test('undo keeps a new Area when another Project starts using it', () async {
    final container = env.container();
    final importer = container.read(importFromAppProvider);
    final receipt = await importer(
      importer.parseFile(
        ImportSourceApp.things,
        fileName: 'main.sqlite',
        bytes: thingsFixture(),
      ),
    );
    final projects = container.read(projectRepositoryProvider);
    await projects.upsert(
      Project(
        id: 'other',
        title: 'Other outcome',
        status: ProjectStatus.active,
        areaId: receipt.areaIds.single,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      ),
    );
    await importer.undo(receipt);
    expect(
      await container
          .read(areaRepositoryProvider)
          .getById(receipt.areaIds.single),
      isNotNull,
    );
    expect((await projects.getById('other'))!.areaId, receipt.areaIds.single);
  });

  test(
    'write failure rolls back Areas, Projects, Contexts and Items together',
    () async {
      final importer = env.container().read(importFromAppProvider);
      final plan = importer.parseFile(
        ImportSourceApp.things,
        fileName: 'main.sqlite',
        bytes: thingsFixture(),
      );
      await env.db.customStatement(
        "CREATE TRIGGER fail_items BEFORE INSERT ON items BEGIN SELECT RAISE(ABORT, 'test failure'); END",
      );
      await expectLater(importer(plan), throwsA(anything));
      for (final table in ['areas', 'projects', 'contexts', 'items', 'tags']) {
        expect(
          (await env.db
                  .customSelect('SELECT COUNT(*) AS n FROM $table')
                  .getSingle())
              .read<int>('n'),
          0,
        );
      }
    },
  );

  test('all-closed export rejects an empty import without writing', () async {
    final importer = env.container().read(importFromAppProvider);
    expect(
      () => importer.parseFile(
        ImportSourceApp.things,
        fileName: 'main.sqlite',
        bytes: thingsFixture(
          modify: (db) => db.execute('UPDATE TMTask SET status=3'),
        ),
      ),
      throwsA(
        isA<ImportFormatException>().having(
          (e) => e.failure,
          'failure',
          ImportFailure.noTasks,
        ),
      ),
    );
    expect(await env.db.select(env.db.items).get(), isEmpty);
  });
}
