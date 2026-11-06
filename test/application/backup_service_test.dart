import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/core/id_generator.dart';
import '../support/backup_files_fake.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;
  late Clock clock;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14));
    backup = BackupService(
      database: db,
      attachments: AttachmentRepository(db, clock, FixedIdGenerator([])),
      reviews: ReviewRepository(db),
      files: MemoryBackupFiles(),
      items: ItemRepository(db, clock),
      projects: ProjectRepository(db),
      contexts: ContextRepository(db),
      tags: TagRepository(db),
      areas: AreaRepository(db),
      clock: clock,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('round-trips items, projects, and contexts', () async {
    final items = ItemRepository(db, clock);
    final projects = ProjectRepository(db);
    final contexts = ContextRepository(db);

    final now = DateTime(2026, 5, 14);
    await contexts.upsert(const GtdContext(
      id: 'c1',
      name: '@home',
      icon: 'home',
      color: 0xFF43A047,
    ));
    await projects.upsert(Project(
      id: 'p1',
      title: 'Demo',
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ));
    await items.upsert(Item(
      id: 'i1',
      title: 'Buy milk',
      status: ItemStatus.nextAction,
      contextId: 'c1',
      projectId: 'p1',
      projectSortOrder: 3,
      createdAt: now,
      updatedAt: now,
    ));

    final snapshot = await backup.export();

    // wipe everything and reimport
    await items.delete('i1');
    await projects.delete('p1');
    await contexts.delete('c1');
    expect(await items.allActive(), isEmpty);

    final count = await backup.import(snapshot);
    expect(count, 3);
    final restored = await items.getById('i1');
    expect(restored?.title, 'Buy milk');
    expect(restored?.contextId, 'c1');
    expect(restored?.projectId, 'p1');
    expect(restored?.projectSortOrder, 3);
  });

  test('round-trips Today focus and project review (format v7)', () async {
    final items = ItemRepository(db, clock);
    final projects = ProjectRepository(db);
    final now = DateTime(2026, 5, 14);
    final focusedAt = DateTime(2026, 5, 14, 8, 30);
    final reviewedAt = DateTime(2026, 5, 10, 18);
    await projects.upsert(Project(
      id: 'p1',
      title: 'Demo',
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ));
    await projects.markReviewed('p1', reviewedAt);
    await items.upsert(Item(
      id: 'i1',
      title: 'Call Bob',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await items.setFocusedAt({'i1': focusedAt});

    final snapshot = await backup.export();
    expect(snapshot['version'], 8);
    await items.delete('i1');
    await projects.delete('p1');
    await backup.import(snapshot);

    expect((await items.getById('i1'))!.focusedAt, focusedAt);
    expect((await projects.getById('p1'))!.lastReviewedAt, reviewedAt);
  });

  group('tags (format v8)', () {
    late ItemRepository items;
    late TagRepository tags;
    final now = DateTime(2026, 5, 14);

    setUp(() async {
      items = ItemRepository(db, clock);
      tags = TagRepository(db);
      for (final id in ['i1', 'i2']) {
        await items.upsert(Item(
          id: id,
          title: id,
          status: ItemStatus.nextAction,
          createdAt: now,
          updatedAt: now,
        ));
      }
      await tags.upsertAll(const [
        Tag(id: 't1', name: 'Alice', isPerson: true),
        Tag(id: 't2', name: 'Kitchen'),
      ], createdAt: now);
      await tags.replaceItemTags({
        'i1': ['t1', 't2'],
      });
    });

    test('round-trips tags, people, and item links', () async {
      final snapshot = await backup.export();
      expect(snapshot['version'], 8);
      await items.deleteAll(['i1', 'i2']);
      await tags.delete('t1');
      await tags.delete('t2');

      await backup.import(snapshot);

      expect(await tags.all(), const [
        Tag(id: 't1', name: 'Alice', isPerson: true),
        Tag(id: 't2', name: 'Kitchen'),
      ]);
      expect((await tags.tagIdsFor('i1')).toSet(), {'t1', 't2'});
      expect(await tags.tagIdsFor('i2'), isEmpty);
    });

    test('a tag with a local name merges instead of duplicating', () async {
      final snapshot = await backup.export();
      for (final m in (snapshot['tags'] as List).cast<Map>()) {
        m['id'] = 'other-${m['id']}';
      }
      for (final m in (snapshot['items'] as List).cast<Map>()) {
        m['tagIds'] = [for (final id in m['tagIds'] as List) 'other-$id'];
      }
      await tags.replaceItemTags({'i1': []});

      await backup.import(snapshot);

      expect((await tags.all()).map((t) => t.id), ['t1', 't2']);
      expect((await tags.tagIdsFor('i1')).toSet(), {'t1', 't2'});
    });

    test('a v7 backup imports and leaves current tags alone', () async {
      final snapshot = await backup.export();
      snapshot['version'] = 7;
      snapshot.remove('tags');
      for (final m in (snapshot['items'] as List).cast<Map>()) {
        m.remove('tagIds');
      }

      await backup.import(snapshot);

      expect(await tags.all(), hasLength(2));
      expect((await tags.tagIdsFor('i1')).toSet(), {'t1', 't2'});
    });

    test('an item linked to a tag not in the backup is rejected', () async {
      final snapshot = await backup.export();
      (snapshot['tags'] as List).removeWhere((m) => (m as Map)['id'] == 't2');
      await items.deleteAll(['i1', 'i2']);

      await expectLater(backup.import(snapshot), throwsFormatException);
      expect(await items.getById('i1'), isNull);
    });
  });

  test('imports a v6 backup without focus or review fields', () async {
    final items = ItemRepository(db, clock);
    final projects = ProjectRepository(db);
    final now = DateTime(2026, 5, 14);
    await projects.upsert(Project(
      id: 'p1',
      title: 'Demo',
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ));
    await items.upsert(Item(
      id: 'i1',
      title: 'Call Bob',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    final snapshot = await backup.export();
    snapshot['version'] = 6;
    for (final m in (snapshot['items'] as List).cast<Map>()) {
      m.remove('focusedAt');
    }
    for (final m in (snapshot['projects'] as List).cast<Map>()) {
      m.remove('lastReviewedAt');
    }
    await items.delete('i1');
    await projects.delete('p1');

    await backup.import(snapshot);

    expect((await items.getById('i1'))!.focusedAt, isNull);
    expect((await projects.getById('p1'))!.lastReviewedAt, isNull);
    expect((await items.getById('i1'))!.title, 'Call Bob');
  });

  test('imports a legacy backup with no projectSortOrder field as 0',
      () async {
    final items = ItemRepository(db, clock);
    final now = DateTime(2026, 5, 14);
    await items.upsert(Item(
      id: 'i1',
      title: 'Old item',
      status: ItemStatus.nextAction,
      projectId: 'p1',
      projectSortOrder: 7,
      createdAt: now,
      updatedAt: now,
    ));
    final snapshot = await backup.export();
    // Simulate a pre-v9 backup: strip the new key from every item map.
    for (final m in (snapshot['items'] as List).cast<Map>()) {
      m.remove('projectSortOrder');
    }
    await items.delete('i1');

    await backup.import(snapshot);

    expect((await items.getById('i1'))!.projectSortOrder, 0);
  });

  test('round-trips recurrence end conditions (format v3)', () async {
    final items = ItemRepository(db, clock);
    final now = DateTime(2026, 5, 14);
    await items.upsert(Item(
      id: 'r1',
      title: 'Pay rent',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
      dueAt: now,
      recurrence: Recurrence.monthly,
      recurrenceInterval: 2,
      recurrenceUntil: DateTime(2026, 12, 31),
      recurrenceCount: 6,
      recurrenceDoneCount: 2,
    ));

    final snapshot = await backup.export();
    expect(snapshot['version'], BackupService.formatVersion);

    await items.delete('r1');
    await backup.import(snapshot);

    final restored = await items.getById('r1');
    expect(restored?.recurrence, Recurrence.monthly);
    expect(restored?.recurrenceInterval, 2);
    expect(restored?.recurrenceUntil, DateTime(2026, 12, 31));
    expect(restored?.recurrenceCount, 6);
    expect(restored?.recurrenceDoneCount, 2);
  });

  test('round-trips completed items so backup preserves history', () async {
    final items = ItemRepository(db, clock);
    final now = DateTime(2026, 5, 14, 9);
    final completedAt = DateTime(2026, 5, 15, 17);
    await items.upsert(
      Item(
        id: 'done-1',
        title: 'Ship release',
        status: ItemStatus.done,
        previousStatus: ItemStatus.nextAction,
        completedAt: completedAt,
        createdAt: now,
        updatedAt: completedAt,
      ),
    );

    final snapshot = await backup.export();
    final exportedItems = (snapshot['items'] as List).cast<Map>();
    expect(exportedItems.map((m) => m['id']), contains('done-1'));

    await items.delete('done-1');
    await backup.import(snapshot);

    final restored = await items.getById('done-1');
    expect(restored?.status, ItemStatus.done);
    expect(restored?.completedAt, completedAt);
    expect(restored?.previousStatus, ItemStatus.nextAction);
  });

  test('round-trips structured recurrence qualifiers (format v4)', () async {
    final items = ItemRepository(db, clock);
    final now = DateTime(2026, 5, 14);
    await items.upsert(Item(
      id: 's1',
      title: 'Team sync',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
      recurrence: Recurrence.weekly,
      recurrenceByWeekdays: const [1, 3, 5],
    ));
    await items.upsert(Item(
      id: 's2',
      title: 'Pay invoice',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
      recurrence: Recurrence.monthly,
      recurrenceMonthlyWeek: -1,
      recurrenceMonthlyWeekday: DateTime.friday,
    ));

    final snapshot = await backup.export();
    expect(snapshot['version'], BackupService.formatVersion);

    await items.delete('s1');
    await items.delete('s2');
    await backup.import(snapshot);

    final s1 = await items.getById('s1');
    expect(s1?.recurrenceByWeekdays, const [1, 3, 5]);
    expect(s1?.recurrenceRule?.byWeekdays, {1, 3, 5});
    final s2 = await items.getById('s2');
    expect(s2?.recurrenceMonthlyWeek, -1);
    expect(s2?.recurrenceMonthlyWeekday, DateTime.friday);
    expect(s2?.recurrenceRule?.monthlyMode, MonthlyMode.nthWeekday);
  });

  test('imports a pre-v3 backup with no end-condition fields', () async {
    final items = ItemRepository(db, clock);
    // Simulate an old (v2) export: recurrence present, end fields absent.
    final legacy = {
      'version': 2,
      'contexts': <Object?>[],
      'areas': <Object?>[],
      'projects': <Object?>[],
      'items': [
        {
          'id': 'old1',
          'title': 'Legacy weekly',
          'status': 'nextAction',
          'createdAt': '2026-05-14T00:00:00.000',
          'updatedAt': '2026-05-14T00:00:00.000',
          'recurrence': 'weekly',
          'recurrenceInterval': 1,
        },
      ],
    };

    await backup.import(legacy);

    final restored = await items.getById('old1');
    expect(restored?.recurrence, Recurrence.weekly);
    expect(restored?.recurrenceUntil, isNull);
    expect(restored?.recurrenceCount, isNull);
    expect(restored?.recurrenceDoneCount, 0);
  });
}
