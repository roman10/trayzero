import 'package:cleartray/application/delete_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late AttachmentRepository attachments;
  late FakeNotificationScheduler scheduler;
  late FakeClock clock;
  late DeleteItem deleteItem;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    items = ItemRepository(db, clock);
    attachments =
        AttachmentRepository(db, clock, FixedIdGenerator(const []));
    scheduler = FakeNotificationScheduler();
    deleteItem = DeleteItem(
      items: items,
      attachments: attachments,
      scheduler: scheduler,
    );
  });

  tearDown(() async => db.close());

  Future<void> seed(String id) => items.upsert(Item(
        id: id,
        title: 'Doomed task',
        status: ItemStatus.nextAction,
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ));

  test('removes the item row', () async {
    await seed('i1');
    expect(await items.getById('i1'), isNotNull);

    await deleteItem('i1');

    expect(await items.getById('i1'), isNull);
  });

  test('cancels both reminder ids derived from the item id', () async {
    await seed('i1');
    await deleteItem('i1');

    expect(scheduler.cancelled, [
      notificationIdFor('i1', 1),
      notificationIdFor('i1', 2),
      notificationIdFor('i1', 3),
    ]);
  });

  test('is a no-op on the row when the id does not exist', () async {
    await deleteItem('missing');

    // Still cancels the reminders defensively for the (absent) id.
    expect(scheduler.cancelled, [
      notificationIdFor('missing', 1),
      notificationIdFor('missing', 2),
      notificationIdFor('missing', 3),
    ]);
    expect(await items.allActive(), isEmpty);
  });

  test('leaves unrelated items untouched', () async {
    await seed('keep');
    await seed('drop');

    await deleteItem('drop');

    expect(await items.getById('keep'), isNotNull);
    expect(await items.getById('drop'), isNull);
  });
}
