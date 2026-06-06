import 'package:cleartray/application/convert_to_project.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late ProjectRepository projects;
  late FakeNotificationScheduler scheduler;
  late FakeClock clock;
  late FixedIdGenerator ids;
  late SaveItem saveItem;
  late ConvertToProject convertToProject;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    ids = FixedIdGenerator(['proj-1']);
    items = ItemRepository(db, clock);
    projects = ProjectRepository(db);
    scheduler = FakeNotificationScheduler();
    saveItem = SaveItem(items: items, scheduler: scheduler, clock: clock);
    convertToProject = ConvertToProject(
      projects: projects,
      saveItem: saveItem,
      clock: clock,
      ids: ids,
    );
  });

  tearDown(() async => db.close());

  Item captured() => Item(
        id: 'i1',
        title: 'Plan offsite',
        notes: 'Everyone aligned and booked',
        status: ItemStatus.inbox,
        createdAt: DateTime(2026, 5, 14, 10),
        updatedAt: DateTime(2026, 5, 14, 10),
      );

  test('creates an active project carrying the captured title and outcome',
      () async {
    final result = await convertToProject(captured());

    expect(result.project.id, 'proj-1');
    expect(result.project.title, 'Plan offsite');
    expect(result.project.outcome, 'Everyone aligned and booked');
    expect(result.project.status, ProjectStatus.active);
    expect(result.project.createdAt, DateTime(2026, 5, 14, 12));

    final stored = await projects.getById('proj-1');
    expect(stored?.title, 'Plan offsite');
  });

  test('reshapes the original item into the project first next-action',
      () async {
    final result = await convertToProject(captured());

    expect(result.firstAction.id, 'i1');
    expect(result.firstAction.status, ItemStatus.nextAction);
    expect(result.firstAction.projectId, 'proj-1');
    expect(result.firstAction.title,
        'Define next action for "Plan offsite"');
  });

  test('persists the first action through SaveItem (clock-stamped)',
      () async {
    await convertToProject(captured());

    final stored = await items.getById('i1');
    expect(stored?.status, ItemStatus.nextAction);
    expect(stored?.projectId, 'proj-1');
    expect(stored?.updatedAt, DateTime(2026, 5, 14, 12));
  });

  test('routes notification reconciliation through SaveItem', () async {
    // No dueAt / deferUntil → SaveItem cancels the due, defer, soon ids.
    await convertToProject(captured());
    expect(scheduler.cancelled, hasLength(3));
  });

  test('drops a captured due date — the first action is a next action',
      () async {
    // Option A: the reshaped first action is a next action, which never
    // carries a hard `dueAt`, so no "Due:" reminder is scheduled and the
    // stored date is cleared rather than silently surfacing nowhere.
    final result = await convertToProject(
        captured().copyWith(dueAt: DateTime(2026, 5, 20, 9)));
    expect(result.firstAction.dueAt, isNull);
    expect((await items.getById('i1'))?.dueAt, isNull);
    expect(scheduler.scheduled.any((s) => s.title.startsWith('Due')),
        isFalse);
  });
}
