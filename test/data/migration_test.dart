import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/search_text.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

/// Opens older SQLite schemas through the same Drift migration used by the app.
void main() {
  test(
    'v14 → v15 adds Item indexes and keeps every row and column unchanged',
    () async {
      final directory = await Directory.systemTemp.createTemp('migration_v14_');
      addTearDown(() => directory.delete(recursive: true));
      final file = await File('test/fixtures/migrations/v14.sqlite').copy(
        '${directory.path}/cleartray.sqlite',
      );
      final raw = sqlite3.open(file.path, mode: OpenMode.readOnly);
      addTearDown(raw.dispose);
      expect(raw.select('PRAGMA user_version').single['user_version'], 14);

      const newIndexes = {
        'index:items_project_id',
        'index:items_status_completed_at',
      };
      final tables = [
        for (final row in raw.select(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        ))
          row['name'] as String,
      ];
      Map<String, String?> schemaOf(Database db) => {
        for (final row in db.select(
          'SELECT type, name, sql FROM sqlite_master ORDER BY name',
        ))
          '${row['type']}:${row['name']}': row['sql'] as String?,
      };
      Map<String, List<Map<String, Object?>>> snapshot() => {
        for (final table in tables)
          table: [
            for (final row in raw.select(
              'SELECT rowid AS _rowid, * FROM "$table" ORDER BY rowid',
            ))
              Map.of(row),
          ],
      };
      final rowsBefore = snapshot();
      final schemaBefore = schemaOf(raw);
      expect(schemaBefore.keys.toSet().intersection(newIndexes), isEmpty);

      // Keep the fixture representative of every v14 table and column.
      for (final entry in rowsBefore.entries) {
        final table = entry.key;
        expect(entry.value, isNotEmpty, reason: '$table has fixture rows');
        for (final column in raw.select('PRAGMA table_info("$table")')) {
          final name = column['name'] as String;
          final values = entry.value.map((row) => row[name]);
          expect(values, contains(isNotNull), reason: '$table.$name has a value');
          if (column['notnull'] == 0 && column['pk'] == 0) {
            expect(values, contains(isNull), reason: '$table.$name has a null');
          }
        }
      }

      // Open the copy with the same background SQLite executor as the app.
      final migrated = AppDatabase.forTesting(
        NativeDatabase.createInBackground(file),
      );
      try {
        final completedAt = DateTime.fromMillisecondsSinceEpoch(1794994200000);
        final repo = ItemRepository(migrated, FakeClock(completedAt));
        expect(
          (await repo.watchForProject('p').first).single.title,
          'Visit the Café',
        );
        expect((await repo.getById('b'))!.completedAt, completedAt);
        expect(await repo.watchProjectStatusCounts().first, {
          'p': {ItemStatus.nextAction: 1},
        });
      } finally {
        await migrated.close();
      }

      expect(raw.select('PRAGMA user_version').single['user_version'], 15);
      expect(snapshot(), rowsBefore);
      final schemaAfter = schemaOf(raw);
      expect(
        schemaAfter.keys.toSet().difference(schemaBefore.keys.toSet()),
        newIndexes,
      );
      expect(
        Map.of(schemaAfter)..removeWhere((key, _) => newIndexes.contains(key)),
        schemaBefore,
      );
      expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
      expect(raw.select('PRAGMA integrity_check').single.values.single, 'ok');

      final fresh = sqlite3.openInMemory();
      addTearDown(fresh.dispose);
      final freshDb = AppDatabase.forTesting(
        NativeDatabase.opened(fresh, closeUnderlyingOnClose: false),
      );
      try {
        await freshDb.customSelect('SELECT 1').get();
      } finally {
        await freshDb.close();
      }
      expect(schemaOf(fresh), schemaAfter);
    },
  );

  test(
    'v13 → v14 adds persistent import history without changing items',
    () async {
      final raw = sqlite3.openInMemory();
      addTearDown(raw.dispose);
      AppDatabase open() => AppDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      final seed = open();
      final now = DateTime(2026, 11, 3);
      await ItemRepository(seed, FakeClock(now)).upsert(
        Item(
          id: 'keep',
          title: 'Existing task',
          status: ItemStatus.inbox,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await seed.close();
      raw.execute('DROP TABLE import_batches');
      raw.execute('PRAGMA user_version = 13');
      final migrated = open();
      addTearDown(migrated.close);
      expect(
        (await ItemRepository(migrated, FakeClock(now)).getById('keep'))!.title,
        'Existing task',
      );
      await migrated
          .into(migrated.importBatches)
          .insert(
            ImportBatchesCompanion.insert(id: 'batch', fingerprint: 'digest'),
          );
      expect(
        (await migrated.select(migrated.importBatches).get())
            .single
            .fingerprint,
        'digest',
      );
      expect(
        raw.select(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'import_batches_fingerprint'",
        ),
        hasLength(1),
      );
    },
  );

  test('v11 → v12 adds Today focus and project review without touching rows',
      () async {
    final raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);
    final now = DateTime(2026, 10, 26, 8);
    AppDatabase open() => AppDatabase.forTesting(
          NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
        );
    final seed = open();
    await ItemRepository(seed, FakeClock(now)).upsert(Item(
      id: 'a',
      title: 'Call Bob',
      status: ItemStatus.nextAction,
      projectId: 'p',
      createdAt: now,
      updatedAt: now,
    ));
    await ProjectRepository(seed).upsert(Project(
      id: 'p',
      title: 'Garage',
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ));
    await seed.close();
    raw.execute('ALTER TABLE items DROP COLUMN focused_at');
    raw.execute('ALTER TABLE projects DROP COLUMN last_reviewed_at');
    raw.execute('DROP TABLE item_tags');
    raw.execute('DROP TABLE tags');
    raw.execute('DROP TABLE import_batches');
    raw.execute('PRAGMA user_version = 11');

    final migrated = open();
    addTearDown(migrated.close);
    final items = ItemRepository(migrated, FakeClock(now));
    final projects = ProjectRepository(migrated);
    final item = (await items.getById('a'))!;
    expect(item.title, 'Call Bob');
    expect(item.focusedAt, isNull);
    final project = (await projects.getById('p'))!;
    expect(project.title, 'Garage');
    expect(project.lastReviewedAt, isNull);

    // The new columns are writable after the upgrade.
    await items.setFocusedAt({'a': now});
    await projects.markReviewed('p', now);
    expect((await items.getById('a'))!.focusedAt, now);
    expect((await projects.getById('p'))!.lastReviewedAt, now);
    expect(
      raw.select('PRAGMA user_version').first['user_version'],
      migrated.schemaVersion,
    );
  });

  test('v12 → v13 adds tags without touching rows', () async {
    final raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);
    final now = DateTime(2026, 10, 27, 8);
    AppDatabase open() => AppDatabase.forTesting(
          NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
        );
    final seed = open();
    await ItemRepository(seed, FakeClock(now)).upsert(Item(
      id: 'a',
      title: 'Ask Alice about the budget',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await seed.close();
    raw.execute('DROP TABLE item_tags');
    raw.execute('DROP TABLE tags');
    raw.execute('DROP TABLE import_batches');
    raw.execute('PRAGMA user_version = 12');

    final migrated = open();
    addTearDown(migrated.close);
    final items = ItemRepository(migrated, FakeClock(now));
    final tags = TagRepository(migrated);
    expect((await items.getById('a'))!.title, 'Ask Alice about the budget');
    expect(await tags.all(), isEmpty);

    // The new tables, their index, and the cascade are in place.
    await tags.upsert(
      const Tag(id: 't', name: 'Alice', isPerson: true),
      createdAt: now,
    );
    await tags.replaceItemTags({
      'a': ['t'],
    });
    expect(await tags.tagIdsFor('a'), ['t']);
    expect(
      raw.select(
        "SELECT name FROM sqlite_master WHERE name = 'item_tags_tag_id'",
      ),
      hasLength(1),
    );
    await items.delete('a');
    expect(await tags.allItemTagIds(), isEmpty);
    expect(raw.select('PRAGMA user_version').first['user_version'],
        migrated.schemaVersion);
  });

  test(
    'v10 reviews migrate with their history intact and can resume after reopening',
    () async {
      final raw = sqlite3.openInMemory();
      addTearDown(raw.dispose);
      final now = DateTime(2026, 5, 14);
      AppDatabase open() => AppDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      final seed = open();
      final reviews = ReviewRepository(seed);
      await reviews.insert(
        ReviewLog(
          id: 'unfinished',
          type: ReviewType.weekly,
          startedAt: now,
          notes: 'original note',
        ),
      );
      await reviews.insert(
        ReviewLog(
          id: 'finished',
          type: ReviewType.weekly,
          startedAt: now.subtract(const Duration(days: 7)),
          completedAt: now,
        ),
      );
      await seed.close();
      raw.execute('ALTER TABLE items DROP COLUMN focused_at');
      raw.execute('ALTER TABLE projects DROP COLUMN last_reviewed_at');
      raw.execute('ALTER TABLE reviews DROP COLUMN current_step');
      raw.execute('DROP TABLE item_tags');
      raw.execute('DROP TABLE tags');
      raw.execute('DROP TABLE import_batches');
      raw.execute('PRAGMA user_version = 10');
      final migrated = open();
      final repo = ReviewRepository(migrated);
      final pending = await repo.watchIncompleteWeekly().first;
      expect(pending!.id, 'unfinished');
      expect(pending.currentStep, WeeklyReviewStep.capture);
      expect(pending.startedAt, now);
      expect(pending.notes, 'original note');
      expect(
        (await repo.all()).singleWhere((r) => r.id == 'finished').completedAt,
        now,
      );
      await repo.saveStep('unfinished', WeeklyReviewStep.projects);
      await migrated.close();
      final reopened = open();
      addTearDown(reopened.close);
      expect(
        (await ReviewRepository(
          reopened,
        ).watchIncompleteWeekly().first)!.currentStep,
        WeeklyReviewStep.projects,
      );
      expect(await ReviewRepository(reopened).all(), hasLength(2));
    },
  );

  test('failed v6 upgrade rolls back its schema and data and can be retried',
      () async {
    final directory = await Directory.systemTemp.createTemp('schema_retry_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/cleartray.sqlite');
    final raw = sqlite3.open(file.path);
    addTearDown(raw.dispose);
    AppDatabase open() =>
        AppDatabase.forTesting(NativeDatabase.createInBackground(file));

    final now = DateTime(2026, 5, 14);
    final dueDate = DateTime(2026, 5, 20, 9);

    // 1. Bring the shared handle up to the current schema and seed it the way
    //    a real user's data would look. The 'cal' row is seeded as a calendar
    //    item so its `dueAt` survives the seed upsert's invariant; step 2
    //    rewrites it into the pre-v8 invalid shape (a next action with a
    //    stray `dueAt`) that the v7→v8 migration must repair.
    final seedDb = AppDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false));
    final seedRepo = ItemRepository(seedDb, FakeClock(now));
    await seedRepo.upsert(Item(
      id: 'a',
      title: 'Visit the Café',
      notes: 'near São Paulo',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await seedRepo.upsert(Item(
      id: 'cal',
      title: 'Email the lawyer',
      status: ItemStatus.calendar,
      dueAt: dueDate,
      createdAt: now,
      updatedAt: now,
    ));
    // Two project actions to prove the v8→v9 `projectSortOrder` add is
    // non-destructive and that the all-zero default reproduces the previous
    // createdAt-ascending project order.
    await seedRepo.upsert(Item(
      id: 'pa1',
      title: 'First step',
      status: ItemStatus.nextAction,
      projectId: 'proj',
      createdAt: now,
      updatedAt: now,
    ));
    await seedRepo.upsert(Item(
      id: 'pa2',
      title: 'Second step',
      status: ItemStatus.nextAction,
      projectId: 'proj',
      createdAt: now.add(const Duration(days: 1)),
      updatedAt: now,
    ));
    await seedDb.close(); // leaves `raw` open

    // 2. Rewind that same database to the pre-v7 on-disk shape: drop the
    //    columns added since (search_text @v7, project_sort_order @v9),
    //    downgrade 'cal' to a next action still carrying its `dueAt` (the
    //    legacy state v8 retires), and reset the schema version.
    raw.execute('ALTER TABLE items DROP COLUMN search_text');
    raw.execute('ALTER TABLE items DROP COLUMN project_sort_order');
    raw.execute(
      "UPDATE items SET status = 'nextAction', calendar_event_id = 'event' "
      "WHERE id = 'cal'",
    );
    raw.execute('DROP TABLE calendar_mirrors');
    raw.execute('ALTER TABLE items DROP COLUMN focused_at');
    raw.execute('ALTER TABLE projects DROP COLUMN last_reviewed_at');
    raw.execute('ALTER TABLE reviews DROP COLUMN current_step');
    raw.execute('DROP TABLE item_tags');
    raw.execute('DROP TABLE tags');
    raw.execute('DROP TABLE import_batches');
    raw.execute('DROP INDEX items_project_id');
    raw.execute('DROP INDEX items_status_completed_at');
    raw.execute('PRAGMA user_version = 6');

    // Fail after the schema changes and search backfill have run.
    raw.execute('''
      CREATE TRIGGER fail_upgrade BEFORE UPDATE OF due_at ON items
      BEGIN
        SELECT RAISE(ABORT, 'injected migration failure');
      END
    ''');
    List<Map<String, Object?>> snapshot(String sql) =>
        raw.select(sql).map((row) => Map.of(row)).toList();
    const schemaSql = 'SELECT * FROM sqlite_master ORDER BY name';
    const itemsSql = 'SELECT rowid, * FROM items ORDER BY rowid';
    final schemaBefore = snapshot(schemaSql);
    final itemsBefore = snapshot(itemsSql);

    final failing = open();
    try {
      await expectLater(
        failing.customSelect('SELECT 1').get(),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('injected migration failure'),
          ),
        ),
      );
    } finally {
      await failing.close();
    }
    expect(raw.select('PRAGMA user_version').single['user_version'], 6);
    expect(snapshot(schemaSql), schemaBefore);
    expect(snapshot(itemsSql), itemsBefore);

    raw.execute('DROP TRIGGER fail_upgrade');
    final migrated = open();
    addTearDown(migrated.close);
    final repo = ItemRepository(migrated, FakeClock(now));

    // v6 → v7: pre-existing accented rows are searchable post-migration.
    expect((await repo.search('cafe')).single.id, 'a',
        reason: 'accented title folded by the backfill');
    expect((await repo.search('sao paulo')).single.id, 'a',
        reason: 'notes were folded into searchText too');

    // v7 → v8: the stray next-action dueAt is retired into the defer anchor,
    // preserving the user's date rather than discarding it.
    final cal = await repo.getById('cal');
    expect(cal!.status, ItemStatus.nextAction);
    expect(cal.dueAt, isNull, reason: 'hard dueAt retired from a next action');
    expect(cal.deferUntil, dueDate,
        reason: 'date preserved as the defer anchor by the v7→v8 migration');

    final originalColumns = itemsBefore.first.keys.map((name) => '"$name"');
    final expectedItems = [
      for (final row in itemsBefore)
        if (row['id'] == 'cal')
          {...row, 'due_at': null, 'defer_until': row['due_at']}
        else
          row,
    ];
    expect(
      snapshot('SELECT ${originalColumns.join(', ')} FROM items ORDER BY rowid'),
      expectedItems,
    );

    // v8 → v9: the additive `projectSortOrder` column is non-destructive.
    // No rows lost, every pre-existing field preserved, and the all-zero
    // default reproduces the previous createdAt-ascending project order.
    final all = await migrated.select(migrated.items).get();
    expect(all.map((r) => r.id).toSet(), {'a', 'cal', 'pa1', 'pa2'},
        reason: 'no rows lost across the full v6→v9 upgrade');
    final pa1 = await repo.getById('pa1');
    final pa2 = await repo.getById('pa2');
    expect(pa1!.title, 'First step');
    expect(pa1.projectId, 'proj');
    expect(pa1.createdAt, now, reason: 'pre-existing fields untouched');
    expect(pa1.projectSortOrder, 0, reason: 'addColumn default backfill');
    expect(pa2!.projectSortOrder, 0);
    final projActions = await repo.watchForProject('proj').first;
    expect(projActions.map((e) => e.id), ['pa1', 'pa2'],
        reason: 'all-zero projectSortOrder falls back to createdAt ASC — '
            'identical to the pre-v9 project ordering');

    final mirror = raw.select('SELECT * FROM calendar_mirrors').single;
    expect(mirror['event_id'], 'event');
    expect(mirror['item_id'], 'cal');
    expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
    expect(raw.select('PRAGMA integrity_check').single.values.single, 'ok');

    // Pinned to the current schemaVersion, not a literal, so this stays
    // green as later migrations are added on top.
    expect(raw.select('PRAGMA user_version').first['user_version'],
        migrated.schemaVersion,
        reason: 'schema fully upgraded to current version');
  });

  test('resumes a legacy upgrade with changes already committed', () async {
    final raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);
    AppDatabase open() => AppDatabase.forTesting(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    final seed = open();
    await seed.customSelect('SELECT 1').get();
    await seed.close();

    // Model an older migrator interrupted after its schema changes and
    // backfills, but before it could update user_version.
    raw.execute('DROP INDEX items_project_id');
    raw.execute('DROP INDEX items_status_completed_at');
    raw.execute('PRAGMA user_version = 6');
    raw.execute('''
      INSERT INTO items (
        id, title, status, created_at, updated_at, defer_until, search_text,
        calendar_event_id
      ) VALUES ('a', 'Visit the Café', 'nextAction', 1, 2, 3, ?, 'event')
    ''', [searchTextFor('Visit the Café', null)]);
    raw.execute('''
      INSERT INTO calendar_mirrors (calendar_id, event_id, item_id, is_current)
      VALUES ('', 'event', 'a', 0)
    ''');
    final rowsBefore = raw
        .select('SELECT rowid, * FROM items')
        .map(Map.of)
        .toList();
    final mirrorsBefore = raw
        .select('SELECT rowid, * FROM calendar_mirrors')
        .map(Map.of)
        .toList();

    final migrated = open();
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();

    expect(raw.select('PRAGMA user_version').single['user_version'], 15);
    expect(
      raw.select('SELECT rowid, * FROM items').map(Map.of).toList(),
      rowsBefore,
    );
    expect(
      raw.select('SELECT rowid, * FROM calendar_mirrors').map(Map.of).toList(),
      mirrorsBefore,
    );
    expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
    expect(raw.select('PRAGMA integrity_check').single.values.single, 'ok');
  });
}
