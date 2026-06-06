import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/backfill_search_text.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

/// Exercises the exact code the v6→v7 migration runs: a pre-migration row
/// has an empty `searchText` (the column default) and is therefore
/// invisible to the folded search until backfilled.
void main() {
  late AppDatabase db;
  late ItemRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ItemRepository(db, FakeClock(DateTime(2026, 5, 14, 9)));
  });
  tearDown(() => db.close());

  test('backfill makes pre-migration rows searchable again', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Visit the Café',
      notes: 'near São Paulo',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));

    // Simulate the on-disk state of a row written before v7: column present
    // but holding the empty-string default rather than the folded text.
    await db.customStatement("UPDATE items SET search_text = ''");
    expect(await repo.search('cafe'), isEmpty,
        reason: 'pre-backfill, the unfolded query cannot match');

    await backfillSearchText(db);

    expect((await repo.search('cafe')).single.id, 'a');
    expect((await repo.search('sao paulo')).single.id, 'a',
        reason: 'notes are folded into searchText too');
  });

  test('backfill is idempotent and a no-op on an empty table', () async {
    await backfillSearchText(db); // empty table: must not throw
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Café',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    await backfillSearchText(db);
    await backfillSearchText(db); // running twice changes nothing
    expect((await repo.search('cafe')).single.id, 'a');

    final stored = await db
        .customSelect("SELECT search_text AS s FROM items WHERE id = 'a'")
        .getSingle();
    expect(stored.read<String>('s'), 'cafe\n');
  });

  // Guards the SQL column name the migration's raw simulation depends on.
  test('searchText maps to the search_text SQL column', () async {
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'X',
      status: ItemStatus.nextAction,
      createdAt: now,
      updatedAt: now,
    ));
    final rows = await db
        .customSelect(
          'SELECT count(*) AS c FROM items WHERE search_text = ?',
          variables: [const Variable<String>('x\n')],
        )
        .getSingle();
    expect(rows.read<int>('c'), 1);
  });
}
