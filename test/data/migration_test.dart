import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

/// End-to-end test of the real schema upgrade — not the migration helpers in
/// isolation, but the actual `onUpgrade` blocks drift runs when an existing
/// user's old database is opened by this build. A single in-memory sqlite
/// handle is shared across two `AppDatabase` instances so the second sees the
/// first's data at an older schema version. One upgrade covers both seams:
///   - v6 → v7: `addColumn(searchText)` + `backfillSearchText`
///   - v7 → v8: `migrateNextActionDueDates` (stray next-action `dueAt`)
void main() {
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

  test('full upgrade runs the search backfill and the next-action dueAt fix',
      () async {
    final raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

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
    raw.execute("UPDATE items SET status = 'nextAction' WHERE id = 'cal'");
    raw.execute('DROP TABLE calendar_mirrors');
    raw.execute('ALTER TABLE items DROP COLUMN focused_at');
    raw.execute('ALTER TABLE projects DROP COLUMN last_reviewed_at');
    raw.execute('ALTER TABLE reviews DROP COLUMN current_step');
    raw.execute('DROP TABLE item_tags');
    raw.execute('DROP TABLE tags');
    raw.execute('DROP TABLE import_batches');
    raw.execute('PRAGMA user_version = 6');
    expect(raw.select('PRAGMA user_version').first['user_version'], 6);

    // 3. Reopen as the current AppDatabase: drift sees the db is below the
    //    current schema and runs onUpgrade end to end (the `from < 7` and
    //    `from < 8` blocks). The first query forces the lazy migration.
    final migrated = AppDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false));
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

    // Pinned to the current schemaVersion, not a literal, so this stays
    // green as later migrations are added on top.
    expect(raw.select('PRAGMA user_version').first['user_version'],
        migrated.schemaVersion,
        reason: 'schema fully upgraded to current version');
  });
}
