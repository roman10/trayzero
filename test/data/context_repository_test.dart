import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

void main() {
  late AppDatabase db;
  late ContextRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ContextRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  GtdContext ctx(
    String id, {
    String name = 'Context',
    int sortOrder = 0,
  }) =>
      GtdContext(
        id: id,
        name: name,
        icon: 'phone',
        color: 0xFF2196F3,
        sortOrder: sortOrder,
      );

  test('upserting a context makes it visible to watchAll', () async {
    await repo.upsert(ctx('a', name: '@phone'));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.name, '@phone');
  });

  test('upsert with an existing id updates rather than duplicates', () async {
    await repo.upsert(ctx('a', name: '@phone'));
    await repo.upsert(ctx('a', name: '@calls'));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.name, '@calls');
  });

  test('watchAll orders by sortOrder then name', () async {
    await repo.upsert(ctx('z', name: '@zebra', sortOrder: 0));
    await repo.upsert(ctx('a', name: '@apple', sortOrder: 0));
    await repo.upsert(ctx('first', name: '@anything', sortOrder: -1));
    final all = await repo.watchAll().first;
    expect(all.map((c) => c.id), ['first', 'a', 'z']);
  });

  test('all() returns the same ordering as a Future', () async {
    await repo.upsert(ctx('b', name: '@b', sortOrder: 2));
    await repo.upsert(ctx('a', name: '@a', sortOrder: 1));
    final all = await repo.all();
    expect(all.map((c) => c.id), ['a', 'b']);
  });

  test('getById returns the context or null when missing', () async {
    await repo.upsert(ctx('a', name: '@find'));
    expect((await repo.getById('a'))?.name, '@find');
    expect(await repo.getById('missing'), isNull);
  });

  test('delete removes the context from watchAll', () async {
    await repo.upsert(ctx('a'));
    await repo.delete('a');
    expect(await repo.watchAll().first, isEmpty);
  });

  test('round-trips icon and color through persistence', () async {
    await repo.upsert(const GtdContext(
      id: 'a',
      name: '@computer',
      icon: 'computer',
      color: 0xFFAB47BC,
      sortOrder: 3,
    ));
    final fetched = await repo.getById('a');
    expect(fetched?.icon, 'computer');
    expect(fetched?.color, 0xFFAB47BC);
    expect(fetched?.sortOrder, 3);
  });
}
