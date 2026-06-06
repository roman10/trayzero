import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/db/migrate_next_action_due_dates.dart';
import 'package:cleartray/data/mappers.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exercises the exact code the v7→v8 migration runs. Rows are inserted
/// straight through the drift mapper, NOT `repo.upsert` — upsert now enforces
/// the same invariant, so it would strip `dueAt` before the migration could
/// be observed. This reproduces the genuine pre-v8 on-disk shape.
void main() {
  late AppDatabase db;
  late ItemRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ItemRepository(db, FakeClock(DateTime(2026, 5, 14, 9)));
  });
  tearDown(() => db.close());

  final ts = DateTime(2026, 5, 14, 9);

  Future<void> insertRaw(Item item) =>
      db.into(db.items).insertOnConflictUpdate(item.toCompanion());

  test('moves a stray dueAt into an empty deferUntil', () async {
    await insertRaw(Item(
      id: 'na',
      title: 'Email Alice',
      status: ItemStatus.nextAction,
      dueAt: DateTime(2026, 5, 10, 9),
      createdAt: ts,
      updatedAt: ts,
    ));

    await migrateNextActionDueDates(db);

    final after = await repo.getById('na');
    expect(after!.dueAt, isNull);
    expect(after.deferUntil, DateTime(2026, 5, 10, 9));
  });

  test('clears dueAt but keeps an existing deferUntil', () async {
    await insertRaw(Item(
      id: 'na',
      title: 'Email Alice',
      status: ItemStatus.nextAction,
      dueAt: DateTime(2026, 5, 10, 9),
      deferUntil: DateTime(2026, 5, 12, 8),
      createdAt: ts,
      updatedAt: ts,
    ));

    await migrateNextActionDueDates(db);

    final after = await repo.getById('na');
    expect(after!.dueAt, isNull);
    expect(after.deferUntil, DateTime(2026, 5, 12, 8),
        reason: 'an existing tickler is not overwritten');
  });

  test('a recurring next action keeps a usable anchor', () async {
    await insertRaw(Item(
      id: 'rec',
      title: 'Water plants',
      status: ItemStatus.nextAction,
      dueAt: DateTime(2026, 5, 14),
      recurrence: Recurrence.weekly,
      createdAt: ts,
      updatedAt: ts,
    ));

    await migrateNextActionDueDates(db);

    final after = await repo.getById('rec');
    expect(after!.dueAt, isNull);
    expect(after.deferUntil, DateTime(2026, 5, 14),
        reason: 'recurrence advances dueAt ?? deferUntil — the anchor must '
            'survive the move or the series would silently die');
    expect(after.recurrence, Recurrence.weekly);
  });

  test('leaves calendar and waiting rows untouched', () async {
    await insertRaw(Item(
      id: 'cal',
      title: 'Dentist',
      status: ItemStatus.calendar,
      dueAt: DateTime(2026, 5, 20, 9),
      createdAt: ts,
      updatedAt: ts,
    ));
    await insertRaw(Item(
      id: 'wait',
      title: 'Refund',
      status: ItemStatus.waiting,
      dueAt: DateTime(2026, 5, 22, 9),
      createdAt: ts,
      updatedAt: ts,
    ));

    await migrateNextActionDueDates(db);

    expect((await repo.getById('cal'))!.dueAt, DateTime(2026, 5, 20, 9));
    expect((await repo.getById('wait'))!.dueAt, DateTime(2026, 5, 22, 9));
  });

  test('is idempotent and a no-op on an empty table', () async {
    await migrateNextActionDueDates(db); // empty table: must not throw

    await insertRaw(Item(
      id: 'na',
      title: 'Email Alice',
      status: ItemStatus.nextAction,
      dueAt: DateTime(2026, 5, 10, 9),
      createdAt: ts,
      updatedAt: ts,
    ));
    await migrateNextActionDueDates(db);
    await migrateNextActionDueDates(db); // second run changes nothing

    final after = await repo.getById('na');
    expect(after!.dueAt, isNull);
    expect(after.deferUntil, DateTime(2026, 5, 10, 9));
  });
}
