import 'package:cleartray/application/batch_delete_items.dart';
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
  late BatchDeleteItems batchDelete;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    items = ItemRepository(db, clock);
    attachments =
        AttachmentRepository(db, clock, FixedIdGenerator(const []));
    scheduler = FakeNotificationScheduler();
    batchDelete = BatchDeleteItems(
      items: items,
      attachments: attachments,
      scheduler: scheduler,
    );
  });

  tearDown(() async => db.close());

  Future<void> seed(String id) => items.upsert(Item(
        id: id,
        title: 'Imported task $id',
        status: ItemStatus.inbox,
        createdAt: DateTime(2026, 5, 14),
        updatedAt: DateTime(2026, 5, 14),
      ));

  test('removes every selected row in one sweep', () async {
    await seed('a');
    await seed('b');
    await seed('c');

    await batchDelete(['a', 'b']);

    expect(await items.getById('a'), isNull);
    expect(await items.getById('b'), isNull);
    expect(await items.getById('c'), isNotNull);
  });

  test('cancels both reminder ids for each deleted item', () async {
    await seed('a');
    await seed('b');

    await batchDelete(['a', 'b']);

    expect(scheduler.cancelled, [
      notificationIdFor('a', 1),
      notificationIdFor('a', 2),
      notificationIdFor('a', 3),
      notificationIdFor('b', 1),
      notificationIdFor('b', 2),
      notificationIdFor('b', 3),
    ]);
  });

  test('empty selection is a no-op', () async {
    await seed('a');

    await batchDelete(const []);

    expect(await items.getById('a'), isNotNull);
    expect(scheduler.cancelled, isEmpty);
  });
}
