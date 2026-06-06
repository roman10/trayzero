import 'package:cleartray/application/reorder_project_actions.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late FakeClock clock;
  late ReorderProjectActions reorder;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 18, 9));
    items = ItemRepository(db, clock);
    reorder = ReorderProjectActions(items: items, clock: clock);
  });

  tearDown(() async => db.close());

  Future<void> seedThree() async {
    for (final (i, id) in ['a', 'b', 'c'].indexed) {
      await items.upsert(Item(
        id: id,
        title: 'Step $id',
        status: ItemStatus.nextAction,
        projectId: 'p1',
        createdAt: DateTime(2026, 5, 18, 9, i),
        updatedAt: DateTime(2026, 5, 18, 9, i),
      ));
    }
  }

  test('assigns dense 0..n order matching the given id sequence', () async {
    await seedThree();

    await reorder('p1', ['c', 'a', 'b']);

    expect((await items.getById('c'))!.projectSortOrder, 0);
    expect((await items.getById('a'))!.projectSortOrder, 1);
    expect((await items.getById('b'))!.projectSortOrder, 2);
    final order = (await items.watchForProject('p1').first)
        .map((e) => e.id)
        .toList();
    expect(order, ['c', 'a', 'b']);
  });

  test('stamps updatedAt from the clock', () async {
    await seedThree();

    await reorder('p1', ['b', 'c', 'a']);

    expect((await items.getById('b'))!.updatedAt, DateTime(2026, 5, 18, 9));
  });

  test('touches no other column (status/title/dueAt/createdAt preserved)',
      () async {
    await seedThree();
    final before = await items.getById('a');

    await reorder('p1', ['b', 'a', 'c']);

    final after = await items.getById('a');
    expect(after!.title, before!.title);
    expect(after.status, ItemStatus.nextAction);
    expect(after.projectId, 'p1');
    expect(after.createdAt, before.createdAt);
    expect(after.dueAt, isNull);
  });

  test('empty id list is a no-op', () async {
    await seedThree();
    await reorder('p1', const []);
    // Untouched: default 0, so still createdAt ASC.
    final order = (await items.watchForProject('p1').first)
        .map((e) => e.id)
        .toList();
    expect(order, ['a', 'b', 'c']);
  });
}
