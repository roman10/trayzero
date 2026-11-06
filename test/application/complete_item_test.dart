import 'package:cleartray/application/complete_item.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late FakeNotificationScheduler scheduler;
  late FakeClock clock;
  late FixedIdGenerator ids;
  late SaveItem saveItem;
  late CompleteItem completeItem;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    ids = FixedIdGenerator(['next-1']);
    items = ItemRepository(db, clock);
    scheduler = FakeNotificationScheduler();
    saveItem = SaveItem(items: items, scheduler: scheduler, clock: clock);
    completeItem = CompleteItem(
      items: items,
      scheduler: scheduler,
      clock: clock,
      ids: ids,
      saveItem: saveItem,
    );
  });

  tearDown(() async => db.close());

  test('marks the item done and cancels its reminders', () async {
    await items.upsert(
      Item(
        id: 'i1',
        title: 'Buy milk',
        status: ItemStatus.nextAction,
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );
    await completeItem('i1');
    final fetched = await items.getById('i1');
    expect(fetched?.status, ItemStatus.done);
    expect(fetched?.completedAt, isNotNull);
    expect(scheduler.cancelled, hasLength(3)); // due + defer + soon ids
    expect(scheduler.cancelled, contains(notificationIdFor('i1', 3)));
  });

  test('non-recurring items leave the active list', () async {
    await items.upsert(
      Item(
        id: 'i1',
        title: 'Once',
        status: ItemStatus.nextAction,
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );
    await completeItem('i1');
    final active = await items.allActive();
    expect(active, isEmpty);
  });

  test('recurring items spawn a fresh instance with advanced dates', () async {
    // A recurring next action is anchored on `deferUntil` (Option A: it
    // never carries a hard `dueAt`); the tickler advances on rollover.
    await items.upsert(
      Item(
        id: 'i1',
        title: 'Water plants',
        status: ItemStatus.nextAction,
        recurrence: Recurrence.weekly,
        deferUntil: DateTime(2026, 5, 14),
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );
    await completeItem('i1');
    final active = await items.allActive();
    expect(active.length, 1);
    expect(active.single.id, isNot('i1'));
    expect(active.single.dueAt, isNull);
    expect(active.single.deferUntil, DateTime(2026, 5, 21));
    expect(active.single.recurrence, Recurrence.weekly);
  });

  test('returns the spawned recurrence id, null otherwise', () async {
    await items.upsert(
      Item(
        id: 'plain',
        title: 'Once',
        status: ItemStatus.nextAction,
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );
    expect(await completeItem('plain'), isNull);

    await items.upsert(
      Item(
        id: 'rec',
        title: 'Water plants',
        status: ItemStatus.nextAction,
        recurrence: Recurrence.weekly,
        deferUntil: DateTime(2026, 5, 14),
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );
    final spawned = await completeItem('rec');
    expect(spawned, isNotNull);
    expect((await items.allActive()).single.id, spawned);
  });

  test(
    'recurring rollover schedules the spawned occurrence reminder',
    () async {
      await items.upsert(
        Item(
          id: 'rec',
          title: 'Water plants',
          status: ItemStatus.nextAction,
          recurrence: Recurrence.weekly,
          deferUntil: DateTime(2026, 5, 14),
          createdAt: DateTime(2026, 5, 14),
          updatedAt: DateTime(2026, 5, 14),
        ),
      );
      final spawned = await completeItem('rec');
      // The whole point of routing through SaveItem: the next occurrence's
      // "Ready:" reminder is armed, so a recurring task notifies on every
      // occurrence, not just the first. (No-time defer → 09:00.)
      final ready = scheduler.scheduled
          .where((s) => s.id == notificationIdFor(spawned!, 2))
          .toList();
      expect(ready, hasLength(1));
      expect(ready.single.at, DateTime(2026, 5, 21, 9));
    },
  );

  test(
    'UndoComplete deletes the spawned instance and restores prior status',
    () async {
      final undo = UndoComplete(
        items: items,
        scheduler: scheduler,
        saveItem: saveItem,
      );
      await items.upsert(
        Item(
          id: 'rec',
          title: 'Water plants',
          status: ItemStatus.waiting,
          recurrence: Recurrence.weekly,
          dueAt: DateTime(2026, 5, 14),
          createdAt: DateTime(2026, 5, 14),
          updatedAt: DateTime(2026, 5, 14),
        ),
      );
      final spawned = await completeItem('rec');
      await undo('rec', spawnedRecurrenceId: spawned);

      final original = await items.getById('rec');
      expect(original?.status, ItemStatus.waiting);
      expect(original?.completedAt, isNull);
      final sid = spawned!;
      expect(await items.getById(sid), isNull);
      // Undo must also tear down the spawned occurrence's reminders, or they'd
      // fire for a row that no longer exists.
      expect(scheduler.cancelled, contains(notificationIdFor(sid, 1)));
      expect(scheduler.cancelled, contains(notificationIdFor(sid, 2)));
      expect(scheduler.cancelled, contains(notificationIdFor(sid, 3)));
    },
  );

  test(
    'UndoComplete re-arms reminders for the restored original item',
    () async {
      final undo = UndoComplete(
        items: items,
        scheduler: scheduler,
        saveItem: saveItem,
      );
      final due = DateTime(2026, 5, 20, 10);
      await items.upsert(
        Item(
          id: 'due',
          title: 'File taxes',
          status: ItemStatus.calendar,
          dueAt: due,
          createdAt: DateTime(2026, 5, 14),
          updatedAt: DateTime(2026, 5, 14),
        ),
      );

      await completeItem('due');
      scheduler.scheduled.clear();
      await undo('due');

      final original = await items.getById('due');
      expect(original?.status, ItemStatus.calendar);
      expect(original?.completedAt, isNull);
      final dueReminder = scheduler.scheduled.singleWhere(
        (s) => s.id == notificationIdFor('due', 1),
      );
      expect(dueReminder.at, due);
      expect(dueReminder.title, 'Due: File taxes');
    },
  );

  test(
    'overlapping completion through separate use cases creates one successor',
    () async {
      await items.upsert(
        Item(
          id: 'rec',
          title: 'Repeat',
          status: ItemStatus.nextAction,
          recurrence: Recurrence.weekly,
          deferUntil: clock.now(),
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );
      final otherItems = ItemRepository(db, clock);
      final other = CompleteItem(
        items: otherItems,
        scheduler: scheduler,
        clock: clock,
        ids: ids,
        saveItem: SaveItem(
          items: otherItems,
          scheduler: scheduler,
          clock: clock,
        ),
      );
      final results = await Future.wait([completeItem('rec'), other('rec')]);
      expect(results.whereType<String>(), hasLength(1));
      expect(await items.allActive(), hasLength(1));
      expect(
        (await items.getById('rec'))!.previousStatus,
        ItemStatus.nextAction,
      );
      expect(scheduler.scheduled, hasLength(1));
    },
  );

  test(
    'completion and successor roll back together when persistence fails',
    () async {
      await items.upsert(
        Item(
          id: 'rec',
          title: 'Repeat',
          status: ItemStatus.nextAction,
          recurrence: Recurrence.weekly,
          deferUntil: clock.now(),
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );
      await db.customStatement(
        '''CREATE TRIGGER fail_successor BEFORE INSERT ON items
      WHEN NEW.id != 'rec' BEGIN SELECT RAISE(ABORT, 'failed successor'); END''',
      );
      await expectLater(completeItem('rec'), throwsA(isA<Exception>()));
      expect((await items.getById('rec'))!.status, ItemStatus.nextAction);
      expect(await items.allActive(), hasLength(1));
      expect(scheduler.cancelled, isEmpty);
      await db.customStatement('DROP TRIGGER fail_successor');
      expect(await completeItem('rec'), isNotNull);
    },
  );

  test('completing an already-done recurring item is a no-op', () async {
    // Two reminders for the same item (Soon: + Due:) can both fire
    // while the app is dead; the journal drain replays the two Done
    // taps sequentially. Without the idempotency guard the second
    // call's `nextRecurrenceOf` would re-spawn a successor because
    // the rollover function only checks the rule, not the row state.
    await items.upsert(
      Item(
        id: 'rec',
        title: 'Water plants',
        status: ItemStatus.nextAction,
        recurrence: Recurrence.weekly,
        deferUntil: DateTime(2026, 5, 14),
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );

    final firstSpawned = await completeItem('rec');
    final secondSpawned = await completeItem('rec');

    expect(firstSpawned, isNotNull);
    expect(
      secondSpawned,
      isNull,
      reason: 'second completion on an already-done row must not spawn',
    );
    final active = await items.allActive();
    expect(
      active,
      hasLength(1),
      reason: 'exactly one successor — not two siblings',
    );
    expect(active.single.id, firstSpawned);
  });

  test(
    'completing an already-done non-recurring item preserves completion',
    () async {
      await items.upsert(
        Item(
          id: 'i1',
          title: 'Once',
          status: ItemStatus.waiting,
          createdAt: DateTime(2026, 5, 14),
          updatedAt: DateTime(2026, 5, 14),
        ),
      );
      await completeItem('i1');
      final firstPass = await items.getById('i1');

      // Advance the clock so a re-stamp would be detectable.
      clock.advance(const Duration(hours: 3));
      await completeItem('i1');
      final secondPass = await items.getById('i1');

      expect(
        secondPass?.completedAt,
        firstPass?.completedAt,
        reason: 'idempotent: do not bump completedAt on a re-done row',
      );
      expect(
        secondPass?.previousStatus,
        firstPass?.previousStatus,
        reason: 'previousStatus must remain the status we completed *from*',
      );
    },
  );

  test(
    'ReopenItem restores status but leaves the recurrence instance',
    () async {
      final reopen = ReopenItem(items: items, saveItem: saveItem);
      await items.upsert(
        Item(
          id: 'rec',
          title: 'Water plants',
          status: ItemStatus.nextAction,
          recurrence: Recurrence.weekly,
          deferUntil: DateTime(2026, 5, 14),
          createdAt: DateTime(2026, 5, 14),
          updatedAt: DateTime(2026, 5, 14),
        ),
      );
      final spawned = await completeItem('rec');
      await reopen('rec');

      expect((await items.getById('rec'))?.status, ItemStatus.nextAction);
      expect(await items.getById(spawned!), isNotNull);
    },
  );

  test('ReopenItem re-arms reminders for future dated items', () async {
    final reopen = ReopenItem(items: items, saveItem: saveItem);
    await items.upsert(
      Item(
        id: 'defer',
        title: 'Call Alice',
        status: ItemStatus.nextAction,
        deferUntil: DateTime(2026, 5, 20),
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ),
    );

    await completeItem('defer');
    scheduler.scheduled.clear();
    await reopen('defer');

    final original = await items.getById('defer');
    expect(original?.status, ItemStatus.nextAction);
    expect(original?.completedAt, isNull);
    final readyReminder = scheduler.scheduled.singleWhere(
      (s) => s.id == notificationIdFor('defer', 2),
    );
    expect(readyReminder.at, DateTime(2026, 5, 20, 9));
    expect(readyReminder.title, 'Ready: Call Alice');
  });
}
