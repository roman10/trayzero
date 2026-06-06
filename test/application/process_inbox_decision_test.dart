import 'package:cleartray/application/complete_item.dart';
import 'package:cleartray/application/convert_to_project.dart';
import 'package:cleartray/application/delete_item.dart';
import 'package:cleartray/application/process_inbox_decision.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
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
  late ProcessInboxDecisionUseCase decide;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final clock = FakeClock(DateTime(2026, 5, 14, 12));
    final ids = FixedIdGenerator(['proj-1', 'roll-1']);
    items = ItemRepository(db, clock);
    projects = ProjectRepository(db);
    final attachments = AttachmentRepository(db, clock, ids);
    final scheduler = FakeNotificationScheduler();
    final saveItem =
        SaveItem(items: items, scheduler: scheduler, clock: clock);
    final completeItem = CompleteItem(
      items: items,
      scheduler: scheduler,
      clock: clock,
      ids: ids,
      saveItem: saveItem,
    );
    final deleteItem = DeleteItem(
      items: items,
      attachments: attachments,
      scheduler: scheduler,
    );
    final convertToProject = ConvertToProject(
      projects: projects,
      saveItem: saveItem,
      clock: clock,
      ids: ids,
    );
    decide = ProcessInboxDecisionUseCase(
      saveItem: saveItem,
      deleteItem: deleteItem,
      completeItem: completeItem,
      convertToProject: convertToProject,
    );
  });

  tearDown(() async => db.close());

  Future<Item> seed() async {
    final item = Item(
      id: 'inbox-1',
      title: 'Email Bob',
      status: ItemStatus.inbox,
      createdAt: DateTime(2026, 5, 14),
      updatedAt: DateTime(2026, 5, 14),
    );
    await items.upsert(item);
    return item;
  }

  test('Trash removes the row', () async {
    final item = await seed();
    await decide(item, const TrashDecision());
    expect(await items.getById('inbox-1'), isNull);
  });

  test('Reference moves the item to the reference list', () async {
    final item = await seed();
    await decide(item, const ReferenceDecision());
    expect((await items.getById('inbox-1'))?.status, ItemStatus.reference);
  });

  test('Someday moves the item to someday', () async {
    final item = await seed();
    await decide(item, const SomedayDecision());
    expect((await items.getById('inbox-1'))?.status, ItemStatus.someday);
  });

  test('DoItNow marks the item done', () async {
    final item = await seed();
    await decide(item, const DoItNowDecision());
    final fetched = await items.getById('inbox-1');
    expect(fetched?.status, ItemStatus.done);
    expect(fetched?.isTwoMin, true);
  });

  test('Waiting records who we are waiting on', () async {
    final item = await seed();
    await decide(item, const WaitingDecision('Bob'));
    final fetched = await items.getById('inbox-1');
    expect(fetched?.status, ItemStatus.waiting);
    expect(fetched?.waitingOn, 'Bob');
  });

  test('ToProject creates a project and reshapes the item', () async {
    final item = await seed();
    await decide(item, const ToProjectDecision());
    final fetched = await items.getById('inbox-1');
    expect(fetched?.status, ItemStatus.nextAction);
    expect(fetched?.projectId, 'proj-1');
    expect(fetched?.title, startsWith('Define next action for'));
    expect(await projects.getById('proj-1'), isNotNull);
  });

  test('ToCalendar sets dueAt only and leaves deferUntil clear', () async {
    final item = await seed();
    final when = DateTime(2026, 6, 1, 10);
    await decide(item, ToCalendarDecision(deferUntil: when));
    final fetched = await items.getById('inbox-1');
    expect(fetched?.status, ItemStatus.calendar);
    expect(fetched?.dueAt, when);
    // A calendar item is a deadline, not a visibility-gated tickler — no
    // duplicate "Ready:" reminder.
    expect(fetched?.deferUntil, isNull);
  });

  test('ToNextAction stamps context / energy / time / project / defer',
      () async {
    final item = await seed();
    await decide(
      item,
      const ToNextActionDecision(
        contextId: 'c1',
        energy: Energy.medium,
        timeEstimateMinutes: 30,
      ),
    );
    final fetched = await items.getById('inbox-1');
    expect(fetched?.status, ItemStatus.nextAction);
    expect(fetched?.contextId, 'c1');
    expect(fetched?.energy, Energy.medium);
    expect(fetched?.timeEstimateMinutes, 30);
  });

  test('ToCalendar with a quick-pick cadence sets recurrence on the dueAt '
      'anchor', () async {
    final item = await seed();
    final when = DateTime(2026, 6, 1, 10);
    await decide(
      item,
      ToCalendarDecision(deferUntil: when, recurrence: Recurrence.weekly),
    );
    final fetched = await items.getById('inbox-1');
    expect(fetched?.dueAt, when);
    expect(fetched?.recurrence, Recurrence.weekly);
  });

  test('ToCalendar drops the cadence when no date anchor survives', () async {
    // seed() has no dueAt; with deferUntil null there is nothing to repeat
    // on, so the recurrence must not be persisted (anchor invariant).
    final item = await seed();
    await decide(
      item,
      const ToCalendarDecision(recurrence: Recurrence.daily),
    );
    final fetched = await items.getById('inbox-1');
    expect(fetched?.dueAt, isNull);
    expect(fetched?.recurrence, isNull);
  });

  test('ToNextAction with defer + cadence sets recurrence', () async {
    final item = await seed();
    final when = DateTime(2026, 6, 1);
    await decide(
      item,
      ToNextActionDecision(deferUntil: when, recurrence: Recurrence.monthly),
    );
    final fetched = await items.getById('inbox-1');
    expect(fetched?.deferUntil, when);
    expect(fetched?.recurrence, Recurrence.monthly);
  });

  test('ToNextAction drops the cadence when there is no defer anchor',
      () async {
    final item = await seed();
    await decide(
      item,
      const ToNextActionDecision(recurrence: Recurrence.weekly),
    );
    final fetched = await items.getById('inbox-1');
    expect(fetched?.deferUntil, isNull);
    expect(fetched?.recurrence, isNull);
  });

  test('ToNextAction clears a dueAt captured on the inbox item', () async {
    final item = Item(
      id: 'inbox-1',
      title: 'Email Bob',
      status: ItemStatus.inbox,
      dueAt: DateTime(2026, 6, 1, 9),
      createdAt: DateTime(2026, 5, 14),
      updatedAt: DateTime(2026, 5, 14),
    );
    await items.upsert(item);
    await decide(item, const ToNextActionDecision());
    final fetched = await items.getById('inbox-1');
    expect(fetched?.status, ItemStatus.nextAction);
    expect(fetched?.dueAt, isNull,
        reason: "a next action's only date anchor is deferUntil");
  });
}
