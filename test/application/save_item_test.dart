import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/core/clock.dart';
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
  late SaveItem saveItem;
  late FakeClock clock;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    items = ItemRepository(db, clock);
    scheduler = FakeNotificationScheduler();
    saveItem = SaveItem(items: items, scheduler: scheduler, clock: clock);
  });

  tearDown(() async => db.close());

  Item baseItem() => Item(
        id: 'i1',
        title: 'Email Alice',
        status: ItemStatus.nextAction,
        createdAt: DateTime(2026, 5, 14, 10),
        updatedAt: DateTime(2026, 5, 14, 10),
      );

  test('persists the item with updatedAt stamped from the clock', () async {
    final saved = await saveItem(baseItem());
    expect(saved.updatedAt, DateTime(2026, 5, 14, 12));
    final fetched = await items.getById('i1');
    expect(fetched?.title, 'Email Alice');
  });

  test('schedules a due reminder when dueAt is set', () async {
    final due = DateTime(2026, 5, 20, 9);
    // Only a calendar item carries a hard dueAt (Option A).
    await saveItem(
        baseItem().copyWith(status: ItemStatus.calendar, dueAt: due));
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.at, due);
    expect(scheduler.scheduled.single.title, contains('Email Alice'));
  });

  test('schedules a defer reminder when deferUntil is set', () async {
    final defer = DateTime(2026, 5, 17, 8);
    await saveItem(baseItem().copyWith(deferUntil: defer));
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.at, defer);
    expect(scheduler.scheduled.single.title, startsWith('Ready'));
  });

  test('a start-of-day defer nudges at the configured surface hour',
      () async {
    final surfaceSaver = SaveItem(
      items: items,
      scheduler: scheduler,
      clock: clock,
      deferSurfaceMinutes: 540, // 09:00
    );
    await surfaceSaver(
        baseItem().copyWith(deferUntil: DateTime(2026, 5, 18)));
    expect(scheduler.scheduled.single.at, DateTime(2026, 5, 18, 9));
    expect(scheduler.scheduled.single.title, startsWith('Ready'));
  });

  test('an explicit-time defer is left at that exact time', () async {
    final surfaceSaver = SaveItem(
      items: items,
      scheduler: scheduler,
      clock: clock,
      deferSurfaceMinutes: 540,
    );
    final defer = DateTime(2026, 5, 18, 14, 30);
    await surfaceSaver(baseItem().copyWith(deferUntil: defer));
    expect(scheduler.scheduled.single.at, defer);
  });

  test('cancels obsolete reminders when dates are cleared', () async {
    await saveItem(baseItem());
    expect(scheduler.cancelled, hasLength(3)); // due id + defer id + soon id
  });

  test('schedules both due and defer when both are set', () async {
    // baseItem() is a next action, which never carries a dueAt — give it a
    // calendar status so both anchors are legitimately honoured here.
    await saveItem(baseItem().copyWith(
      status: ItemStatus.calendar,
      dueAt: DateTime(2026, 5, 20),
      deferUntil: DateTime(2026, 5, 18),
    ));
    expect(scheduler.scheduled, hasLength(2));
  });

  test('a next action never persists a dueAt nor schedules a "Due" reminder',
      () async {
    final saved = await saveItem(baseItem().copyWith(
      dueAt: DateTime(2026, 5, 20, 9),
      deferUntil: DateTime(2026, 5, 18, 8),
    ));
    expect(saved.dueAt, isNull,
        reason: 'baseItem() is a next action — dueAt is stripped');
    expect(await items.getById('i1'), isNotNull);
    expect((await items.getById('i1'))!.dueAt, isNull);
    expect(scheduler.scheduled.any((s) => s.title.startsWith('Due')), isFalse);
    expect(scheduler.cancelled, contains(notificationIdFor('i1', 1)));
    // The deferUntil tickler — a next action's only anchor — still fires.
    final ready =
        scheduler.scheduled.singleWhere((s) => s.title.startsWith('Ready'));
    expect(ready.at, DateTime(2026, 5, 18, 8));
  });

  group('pre-due lead-time reminder', () {
    SaveItem withLead(int minutes) =>
        SaveItem(items: items, scheduler: scheduler, clock: clock,
            leadTimeMinutes: minutes);

    // The "Soon" tickler hangs off dueAt, which only a calendar item carries.
    Item dated(DateTime due) =>
        baseItem().copyWith(status: ItemStatus.calendar, dueAt: due);

    test('schedules a "Soon" reminder at dueAt minus the lead time',
        () async {
      await withLead(60)(dated(DateTime(2026, 5, 20, 9)));
      final soon = scheduler.scheduled
          .firstWhere((s) => s.title.startsWith('Soon'));
      expect(soon.at, DateTime(2026, 5, 20, 8));
      expect(soon.id, notificationIdFor('i1', 3));
      // Due reminder still scheduled independently.
      expect(scheduler.scheduled.any((s) => s.title.startsWith('Due')),
          isTrue);
    });

    test('lead time 0 schedules no "Soon" reminder and cancels its id',
        () async {
      await withLead(0)(dated(DateTime(2026, 5, 20, 9)));
      expect(scheduler.scheduled.any((s) => s.title.startsWith('Soon')),
          isFalse);
      expect(scheduler.cancelled, contains(notificationIdFor('i1', 3)));
    });

    test('skips "Soon" when the lead window has already passed but still '
        'schedules the due reminder', () async {
      // Clock is 2026-05-14 12:00; due is 2h out, lead is 1 day.
      await withLead(1440)(dated(DateTime(2026, 5, 14, 14)));
      expect(scheduler.scheduled.any((s) => s.title.startsWith('Soon')),
          isFalse);
      expect(scheduler.scheduled.any((s) => s.title.startsWith('Due')),
          isTrue);
      expect(scheduler.cancelled, contains(notificationIdFor('i1', 3)));
    });

    test('cancels the "Soon" id when dueAt is cleared even with lead set',
        () async {
      await withLead(60)(baseItem());
      expect(scheduler.cancelled, contains(notificationIdFor('i1', 3)));
    });
  });
}
