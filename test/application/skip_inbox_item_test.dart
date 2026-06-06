import 'package:cleartray/application/skip_inbox_item.dart';
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
  late SkipInboxItem skipInboxItem;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    items = ItemRepository(db, clock);
    skipInboxItem = SkipInboxItem(items: items, clock: clock);
  });

  tearDown(() async => db.close());

  Item inboxItem() => Item(
        id: 'i1',
        title: 'Stray thought',
        status: ItemStatus.inbox,
        sortOrder: 0,
        createdAt: DateTime(2026, 5, 14, 10),
        updatedAt: DateTime(2026, 5, 14, 10),
      );

  test('pushes the item to the back of the queue without changing status',
      () async {
    await items.upsert(inboxItem());
    await skipInboxItem(inboxItem());

    final fetched = await items.getById('i1');
    expect(fetched?.status, ItemStatus.inbox);
    expect(fetched?.sortOrder,
        DateTime(2026, 5, 14, 12).millisecondsSinceEpoch);
  });

  test('stamps updatedAt from the clock', () async {
    await items.upsert(inboxItem());
    await skipInboxItem(inboxItem());

    final fetched = await items.getById('i1');
    expect(fetched?.updatedAt, DateTime(2026, 5, 14, 12));
  });

  test('preserves the other fields of the item', () async {
    final withNotes = inboxItem().copyWith(notes: 'remember this');
    await items.upsert(withNotes);
    await skipInboxItem(withNotes);

    final fetched = await items.getById('i1');
    expect(fetched?.title, 'Stray thought');
    expect(fetched?.notes, 'remember this');
  });

  test('a later skip wins a higher sortOrder than an earlier one', () async {
    await items.upsert(inboxItem());
    await skipInboxItem(inboxItem());
    final first = (await items.getById('i1'))!.sortOrder;

    clock.advance(const Duration(hours: 1));
    await skipInboxItem(inboxItem());
    final second = (await items.getById('i1'))!.sortOrder;

    expect(second, greaterThan(first));
  });
}
