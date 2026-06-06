import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ItemRepository(db, FakeClock(DateTime(2026, 5, 14, 9)));
  });

  tearDown(() async {
    await db.close();
  });

  test('inserting an inbox item makes it visible to watchInbox', () async {
    final now = DateTime(2026, 5, 14, 9);
    await repo.upsert(Item(
      id: 'a',
      title: 'Buy milk',
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    ));
    final inbox = await repo.watchInbox().first;
    expect(inbox.length, 1);
    expect(inbox.single.title, 'Buy milk');
  });

  test('completed next-actions are filtered out of watchByStatus', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Open',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.upsert(Item(
      id: 'b',
      title: 'Closed',
      status: ItemStatus.nextAction,
      completedAt: now,
      createdAt: now,
      updatedAt: now,
    ));
    final open = await repo.watchByStatus(ItemStatus.nextAction).first;
    expect(open.length, 1);
    expect(open.single.id, 'a');
  });

  test('search matches title case-insensitively', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Call SARAH about budget',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.upsert(Item(
      id: 'b',
      title: 'Buy bread',
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    ));
    final results = await repo.search('sarah');
    expect(results.length, 1);
    expect(results.single.id, 'a');
  });

  group('accent/case-insensitive search', () {
    final now = DateTime(2026, 5, 14);
    Item item(String id, String title, {String? notes}) => Item(
          id: id,
          title: title,
          notes: notes,
          status: ItemStatus.nextAction,
          createdAt: now,
          updatedAt: now,
        );

    test('stored accented title is found by every fold of the query',
        () async {
      await repo.upsert(item('a', 'Visit the Café'));
      for (final q in ['Café', 'café', 'CAFE', 'cafe']) {
        final r = await repo.search(q);
        expect(r.single.id, 'a', reason: 'query "$q" should match "Café"');
      }
    });

    test('accented query finds an un-accented stored title', () async {
      await repo.upsert(item('a', 'visit the cafe'));
      final r = await repo.search('Café');
      expect(r.single.id, 'a');
    });

    test('CJK substring search is preserved (regression guard)', () async {
      await repo.upsert(item('a', '买牛奶'));
      await repo.upsert(item('b', 'Buy bread'));
      final r = await repo.search('牛奶');
      expect(r.single.id, 'a');
    });

    test('matches fold-insensitively in notes; null notes is safe',
        () async {
      await repo.upsert(item('a', 'Trip', notes: 'Fly to São Paulo'));
      await repo.upsert(item('b', 'Plain', notes: null));
      final r = await repo.search('sao paulo');
      expect(r.single.id, 'a');
    });

    test('searchText is recomputed on every upsert (stays in sync)',
        () async {
      await repo.upsert(item('a', 'Café'));
      expect((await repo.search('cafe')).single.id, 'a');

      await repo.upsert(item('a', 'Tea'));
      expect(await repo.search('cafe'), isEmpty,
          reason: 'old title must no longer match after edit');
      expect((await repo.search('tea')).single.id, 'a');
    });

    test('trashed excluded, done returned (invariants unchanged)', () async {
      await repo.upsert(item('keep', 'Café au lait'));
      await repo.upsert(Item(
        id: 'done',
        title: 'Café done',
        status: ItemStatus.done,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      ));
      await repo.upsert(Item(
        id: 'trash',
        title: 'Café trashed',
        status: ItemStatus.trashed,
        createdAt: now,
        updatedAt: now,
      ));
      final ids = (await repo.search('cafe')).map((i) => i.id).toSet();
      expect(ids, {'keep', 'done'});
    });
  });

  test('watchSearch re-emits when a matched item is deleted', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Call Sarah about budget',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    final stream = repo.watchSearch('sarah');
    final emissions = <List<Item>>[];
    final sub = stream.listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.last.map((i) => i.id), ['a']);

    // The reported bug: deleting from a detail screen opened on top of a
    // result must reflect in the still-mounted search list.
    await repo.delete('a');
    await pumpEventQueue();
    expect(emissions.last, isEmpty);
    await sub.cancel();
  });

  test('watchSearch re-emits when a matched item is edited', () async {
    final now = DateTime(2026, 5, 14);
    final item = Item(
      id: 'a',
      title: 'Call Sarah about budget',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    );
    await repo.upsert(item);
    final emissions = <List<Item>>[];
    final sub = repo.watchSearch('sarah').listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.last.single.title, 'Call Sarah about budget');

    await repo.upsert(item.copyWith(title: 'Call Sarah re: Q3 numbers'));
    await pumpEventQueue();
    expect(emissions.last.single.title, 'Call Sarah re: Q3 numbers');
    await sub.cancel();
  });

  test('deferred items are hidden until their defer date', () async {
    final now = DateTime(2026, 5, 14, 9);
    final tomorrow = now.add(const Duration(days: 1));
    await repo.upsert(Item(
      id: 'a',
      title: 'Future thing',
      status: ItemStatus.nextAction,
      deferUntil: tomorrow,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.upsert(Item(
      id: 'b',
      title: 'Available thing',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    final visible = await repo
        .watchByStatus(ItemStatus.nextAction, now: now)
        .first;
    expect(visible.length, 1);
    expect(visible.single.id, 'b');
    final later = await repo
        .watchByStatus(ItemStatus.nextAction,
            now: tomorrow.add(const Duration(minutes: 1)))
        .first;
    expect(later.length, 2);
  });

  test('a start-of-day defer is visible for the whole of that day',
      () async {
    final startOfDay = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'today-defer',
      title: 'Tickler for today',
      status: ItemStatus.nextAction,
      deferUntil: startOfDay,
      createdAt: startOfDay,
      updatedAt: startOfDay,
    ));
    // Early morning, before the configured nudge hour: already in the list.
    final morning = await repo
        .watchByStatus(ItemStatus.nextAction,
            now: startOfDay.add(const Duration(hours: 7)))
        .first;
    expect(morning.map((i) => i.id), contains('today-defer'));
  });

  test('markCompleted moves item to done', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Open',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.markCompleted('a', now);
    final fetched = await repo.getById('a');
    expect(fetched?.status, ItemStatus.done);
    expect(fetched?.completedAt, isNotNull);
  });

  test('markCompleted remembers the pre-completion status', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Delegated',
      status: ItemStatus.waiting,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.markCompleted('a', now);
    expect((await repo.getById('a'))?.previousStatus, ItemStatus.waiting);
  });

  test('reopen restores the prior status and clears previousStatus',
      () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Delegated',
      status: ItemStatus.waiting,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.markCompleted('a', now);
    await repo.reopen('a', now);
    final fetched = await repo.getById('a');
    expect(fetched?.status, ItemStatus.waiting);
    expect(fetched?.completedAt, isNull);
    expect(fetched?.previousStatus, isNull);
  });

  test('reopen falls back to nextAction when no prior status was captured',
      () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Legacy done row',
      status: ItemStatus.done,
      completedAt: now,
      createdAt: now,
      updatedAt: now,
    ));
    await repo.reopen('a', now);
    expect((await repo.getById('a'))?.status, ItemStatus.nextAction);
  });

  test('watchCompletedSince returns done items after the cutoff, newest first',
      () async {
    final cutoff = DateTime(2026, 5, 11);
    await repo.upsert(Item(
      id: 'old',
      title: 'Last week',
      status: ItemStatus.done,
      completedAt: DateTime(2026, 5, 10, 9),
      createdAt: cutoff,
      updatedAt: cutoff,
    ));
    await repo.upsert(Item(
      id: 'mon',
      title: 'Monday',
      status: ItemStatus.done,
      completedAt: DateTime(2026, 5, 12, 9),
      createdAt: cutoff,
      updatedAt: cutoff,
    ));
    await repo.upsert(Item(
      id: 'wed',
      title: 'Wednesday',
      status: ItemStatus.done,
      completedAt: DateTime(2026, 5, 14, 9),
      createdAt: cutoff,
      updatedAt: cutoff,
    ));
    await repo.upsert(Item(
      id: 'open',
      title: 'Still open',
      status: ItemStatus.nextAction,
      createdAt: cutoff,
      updatedAt: cutoff,
    ));
    final completed = await repo.watchCompletedSince(cutoff).first;
    expect(completed.map((i) => i.id), ['wed', 'mon']);
  });

  test(
      'watchCompletedForProject returns only this project\'s done items, '
      'newest completed first', () async {
    final ts = DateTime(2026, 5, 14, 9);
    // Two completed in p1, completed out of creation order.
    await repo.upsert(Item(
      id: 'p1-early',
      title: 'Booked venue',
      status: ItemStatus.done,
      projectId: 'p1',
      completedAt: DateTime(2026, 5, 12, 9),
      createdAt: ts,
      updatedAt: ts,
    ));
    await repo.upsert(Item(
      id: 'p1-late',
      title: 'Sent invites',
      status: ItemStatus.done,
      projectId: 'p1',
      completedAt: DateTime(2026, 5, 13, 9),
      createdAt: ts,
      updatedAt: ts,
    ));
    // Open item in p1 — excluded (not completed).
    await repo.upsert(Item(
      id: 'p1-open',
      title: 'Order cake',
      status: ItemStatus.nextAction,
      projectId: 'p1',
      createdAt: ts,
      updatedAt: ts,
    ));
    // Completed item in a different project — excluded (scoping).
    await repo.upsert(Item(
      id: 'p2-done',
      title: 'Other project task',
      status: ItemStatus.done,
      projectId: 'p2',
      completedAt: DateTime(2026, 5, 14, 9),
      createdAt: ts,
      updatedAt: ts,
    ));
    // Completed item with no project — excluded (scoping).
    await repo.upsert(Item(
      id: 'loose-done',
      title: 'Loose task',
      status: ItemStatus.done,
      completedAt: DateTime(2026, 5, 14, 9),
      createdAt: ts,
      updatedAt: ts,
    ));

    final completed = await repo.watchCompletedForProject('p1').first;
    expect(completed.map((i) => i.id), ['p1-late', 'p1-early']);
  });

  test('watchCompletedForProject excludes a project\'s open items entirely',
      () async {
    final ts = DateTime(2026, 5, 14, 9);
    await repo.upsert(Item(
      id: 'open',
      title: 'Still open',
      status: ItemStatus.nextAction,
      projectId: 'p1',
      createdAt: ts,
      updatedAt: ts,
    ));
    expect(await repo.watchCompletedForProject('p1').first, isEmpty);
  });

  test('completing a project item moves it out of watchForProject into '
      'watchCompletedForProject', () async {
    final ts = DateTime(2026, 5, 14, 9);
    await repo.upsert(Item(
      id: 'a',
      title: 'Buy domain',
      status: ItemStatus.nextAction,
      projectId: 'p1',
      createdAt: ts,
      updatedAt: ts,
    ));
    expect((await repo.watchForProject('p1').first).map((i) => i.id), ['a']);
    expect(await repo.watchCompletedForProject('p1').first, isEmpty);

    await repo.markCompleted('a', DateTime(2026, 5, 14, 10));

    expect(await repo.watchForProject('p1').first, isEmpty);
    expect((await repo.watchCompletedForProject('p1').first).map((i) => i.id),
        ['a']);
  });

  group('next-action dueAt invariant', () {
    final now = DateTime(2026, 5, 14, 9);

    test('upsert strips dueAt from a next action (clears, not converts)',
        () async {
      await repo.upsert(Item(
        id: 'na',
        title: 'Email Alice',
        status: ItemStatus.nextAction,
        dueAt: DateTime(2026, 5, 20, 9),
        createdAt: now,
        updatedAt: now,
      ));
      final stored = await repo.getById('na');
      expect(stored!.dueAt, isNull);
      expect(stored.deferUntil, isNull,
          reason: 'a live status switch clears the date — the v7→v8 '
              'migration is what moves it to deferUntil, not upsert');
    });

    test('upsert preserves dueAt for a calendar item', () async {
      await repo.upsert(Item(
        id: 'cal',
        title: 'Dentist',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 20, 9),
        createdAt: now,
        updatedAt: now,
      ));
      expect((await repo.getById('cal'))!.dueAt, DateTime(2026, 5, 20, 9));
    });

    test('upsertAll strips dueAt from next actions only', () async {
      await repo.upsertAll([
        Item(
          id: 'na',
          title: 'Email Alice',
          status: ItemStatus.nextAction,
          dueAt: DateTime(2026, 5, 20, 9),
          createdAt: now,
          updatedAt: now,
        ),
        Item(
          id: 'cal',
          title: 'Dentist',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 5, 21, 9),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      expect((await repo.getById('na'))!.dueAt, isNull);
      expect((await repo.getById('cal'))!.dueAt, DateTime(2026, 5, 21, 9));
    });
  });

  group('project action ordering (projectSortOrder)', () {
    final now = DateTime(2026, 5, 18, 9);

    Future<void> seed() async {
      // Created c, b, a (a newest) so a createdAt-only order would be c,b,a.
      await repo.upsert(Item(
        id: 'c',
        title: 'C',
        status: ItemStatus.nextAction,
        projectId: 'p1',
        createdAt: now,
        updatedAt: now,
      ));
      await repo.upsert(Item(
        id: 'b',
        title: 'B',
        status: ItemStatus.nextAction,
        projectId: 'p1',
        createdAt: now.add(const Duration(minutes: 1)),
        updatedAt: now,
      ));
      await repo.upsert(Item(
        id: 'a',
        title: 'A',
        status: ItemStatus.nextAction,
        projectId: 'p1',
        createdAt: now.add(const Duration(minutes: 2)),
        updatedAt: now,
      ));
    }

    test('all-zero projectSortOrder falls back to createdAt ASC', () async {
      await seed();
      final order =
          (await repo.watchForProject('p1').first).map((e) => e.id).toList();
      expect(order, ['c', 'b', 'a']);
    });

    test('orders by projectSortOrder ASC, then createdAt ASC', () async {
      await seed();
      // Give a=0, b=0 (tie → createdAt), c=1.
      await repo.upsert((await repo.getById('a'))!.copyWith(projectSortOrder: 0));
      await repo.upsert((await repo.getById('b'))!.copyWith(projectSortOrder: 0));
      await repo.upsert((await repo.getById('c'))!.copyWith(projectSortOrder: 1));

      final order =
          (await repo.watchForProject('p1').first).map((e) => e.id).toList();
      // a & b tie at 0 → createdAt ASC (b before a); c last at 1.
      expect(order, ['b', 'a', 'c']);
    });

    test(
        'projectSortOrder does NOT affect the Do/Engage list ordering',
        () async {
      await seed();
      await repo.upsert((await repo.getById('a'))!.copyWith(projectSortOrder: 0));
      await repo.upsert((await repo.getById('b'))!.copyWith(projectSortOrder: 9));
      await repo.upsert((await repo.getById('c'))!.copyWith(projectSortOrder: 5));

      // watchNextActions uses sortOrder/dueAt/createdAt — all sortOrder 0,
      // no dueAt, so order is createdAt DESC regardless of projectSortOrder.
      final order =
          (await repo.watchNextActions().first).map((e) => e.id).toList();
      expect(order, ['a', 'b', 'c']);
    });
  });
}
