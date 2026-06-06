import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/application/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;
  late Clock clock;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14));
    backup = BackupService(
      items: ItemRepository(db, clock),
      projects: ProjectRepository(db),
      contexts: ContextRepository(db),
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
    expect(snapshot['version'], 4);

    await items.delete('r1');
    await backup.import(snapshot);

    final restored = await items.getById('r1');
    expect(restored?.recurrence, Recurrence.monthly);
    expect(restored?.recurrenceInterval, 2);
    expect(restored?.recurrenceUntil, DateTime(2026, 12, 31));
    expect(restored?.recurrenceCount, 6);
    expect(restored?.recurrenceDoneCount, 2);
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
    expect(snapshot['version'], 4);

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
