import 'package:cleartray/application/rearm_item_reminders.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// An [ItemRepository] that runs [_onFirstGet] exactly once, the first time
/// `getById` is called — i.e. *after* `RearmItemReminders` has taken its
/// `allActive()` snapshot but *before* it reconciles. Lets a test land a
/// concurrent edit / delete in the race window the unawaited re-arm opens.
class _RaceRepo extends ItemRepository {
  _RaceRepo(super.db, super.clock, this._onFirstGet);
  final Future<void> Function(ItemRepository repo) _onFirstGet;
  bool _fired = false;

  @override
  Future<Item?> getById(String id) async {
    if (!_fired) {
      _fired = true;
      await _onFirstGet(this);
    }
    return super.getById(id);
  }
}

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late FakeNotificationScheduler scheduler;
  late FakeClock clock;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    items = ItemRepository(db, clock);
    scheduler = FakeNotificationScheduler();
  });

  tearDown(() async => db.close());

  RearmItemReminders rearm() => RearmItemReminders(
        items: items,
        scheduler: scheduler,
        clock: clock,
        leadTimeMinutes: 0,
        deferSurfaceMinutes: 540,
      );

  // Raw upsert deliberately bypasses SaveItem — this is what a restored
  // backup / Google Tasks import does (BackupService.import → upsertAll).
  Item mk(
    String id, {
    required ItemStatus status,
    DateTime? dueAt,
    DateTime? deferUntil,
    DateTime? completedAt,
  }) =>
      Item(
        id: id,
        title: 'T-$id',
        status: status,
        dueAt: dueAt,
        deferUntil: deferUntil,
        completedAt: completedAt,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
      );

  test('re-arms reminders for raw-upserted dated items (restore path)',
      () async {
    await items.upsert(
        mk('a', status: ItemStatus.nextAction, deferUntil: DateTime(2026, 5, 20, 8)));
    await items.upsert(
        mk('b', status: ItemStatus.calendar, dueAt: DateTime(2026, 5, 21, 9)));

    await rearm().call();

    final ready =
        scheduler.scheduled.singleWhere((s) => s.id == notificationIdFor('a', 2));
    expect(ready.at, DateTime(2026, 5, 20, 8));
    expect(ready.title, startsWith('Ready'));
    final due =
        scheduler.scheduled.singleWhere((s) => s.id == notificationIdFor('b', 1));
    expect(due.at, DateTime(2026, 5, 21, 9));
    expect(due.title, startsWith('Due'));
  });

  test('skips items with no dueAt and no deferUntil — no schedule, no cancel',
      () async {
    await items.upsert(mk('c', status: ItemStatus.inbox));
    await rearm().call();
    // Empty `cancelled` proves the perf guard `continue`d before reconcile
    // (a thousands-of-rows restore stays O(dated items)).
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelled, isEmpty);
  });

  test('skips imported "cal-" calendar events even when they carry a dueAt',
      () async {
    await items.upsert(
        mk('cal-evt1', status: ItemStatus.calendar, dueAt: DateTime(2026, 5, 22, 9)));
    await rearm().call();
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelled, isEmpty);
  });

  test('skips a completed-but-not-done row', () async {
    await items.upsert(mk('d',
        status: ItemStatus.nextAction,
        deferUntil: DateTime(2026, 5, 20, 8),
        completedAt: DateTime(2026, 5, 13)));
    await rearm().call();
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelled, isEmpty);
  });

  test('a next action with a stray dueAt: invariant strips it, defer still arms',
      () async {
    await items.upsert(mk('e',
        status: ItemStatus.nextAction,
        dueAt: DateTime(2026, 5, 25, 9),
        deferUntil: DateTime(2026, 5, 20, 8)));

    await rearm().call();

    expect(scheduler.scheduled.map((s) => s.id), [notificationIdFor('e', 2)]);
    expect(scheduler.scheduled.single.title, startsWith('Ready'));
    expect(scheduler.scheduled.single.at, DateTime(2026, 5, 20, 8));
    // The stale "Due:" id is torn down, never scheduled.
    expect(scheduler.cancelled, contains(notificationIdFor('e', 1)));
    expect(
      scheduler.scheduled.any((s) => s.title.startsWith('Due')),
      isFalse,
    );
  });

  test('idempotent: a second pass yields the same scheduled id set', () async {
    await items.upsert(
        mk('a', status: ItemStatus.nextAction, deferUntil: DateTime(2026, 5, 20, 8)));
    final r = rearm();
    await r.call();
    await r.call();
    // The fake's `scheduled` is append-only, so assert on the id *set*.
    expect(
      scheduler.scheduled.map((s) => s.id).toSet(),
      {notificationIdFor('a', 2)},
    );
  });

  RearmItemReminders rearmWith(ItemRepository repo) => RearmItemReminders(
        items: repo,
        scheduler: scheduler,
        clock: clock,
        leadTimeMinutes: 0,
        deferSurfaceMinutes: 540,
      );

  test('a row deleted after the snapshot is not revived', () async {
    await items.upsert(
        mk('x', status: ItemStatus.nextAction, deferUntil: DateTime(2026, 5, 20, 8)));
    // 'x' is in the snapshot, then deleted before the re-read.
    final raceRepo = _RaceRepo(db, clock, (repo) => repo.delete('x'));
    await rearmWith(raceRepo).call();
    // Vanished at getById → skipped: no resurrected alarm, nothing touched.
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelled, isEmpty);
  });

  test('a concurrent edit wins over the snapshot', () async {
    await items.upsert(
        mk('y', status: ItemStatus.nextAction, deferUntil: DateTime(2026, 5, 20, 8)));
    // After the snapshot (deferUntil set) but before the re-read, the user
    // clears the date. The stale snapshot would re-schedule "Ready:" at the
    // old time; acting on current truth must instead tear it down.
    final raceRepo = _RaceRepo(
      db,
      clock,
      (repo) => repo.upsert(Item(
        id: 'y',
        title: 'T-y',
        status: ItemStatus.nextAction,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
      )),
    );
    await rearmWith(raceRepo).call();
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelled, contains(notificationIdFor('y', 2)));
  });
}
