import 'package:cleartray/application/capture_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late CaptureItem capture;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final clock = FakeClock(DateTime(2026, 5, 14, 9));
    final ids = FixedIdGenerator(['cap-1']);
    items = ItemRepository(db, clock);
    capture = CaptureItem(items: items, clock: clock, ids: ids);
  });

  tearDown(() async => db.close());

  test('inserts an inbox item with the captured title', () async {
    final item = await capture(title: 'Read paper');
    expect(item.id, 'cap-1');
    expect(item.status, ItemStatus.inbox);
    expect(item.title, 'Read paper');
    expect(item.createdAt, DateTime(2026, 5, 14, 9));
    expect(item.updatedAt, DateTime(2026, 5, 14, 9));
    final inbox = await items.watchInbox().first;
    expect(inbox.single.title, 'Read paper');
  });

  test('persists optional notes', () async {
    final item = await capture(title: 't', notes: 'detail');
    expect(item.notes, 'detail');
  });

  test('keeps parsed fields on the Inbox Item, due at the reminder hour',
      () async {
    final reconciled = <Item>[];
    final dated = CaptureItem(
      items: items,
      clock: FakeClock(DateTime(2026, 5, 14, 9)),
      ids: FixedIdGenerator(['cap-2']),
      reconcileReminders: (item) async => reconciled.add(item),
      dueMinutesOfDay: 8 * 60 + 30,
    );
    final item = await dated(
      title: 'Submit report',
      contextId: 'c-office',
      projectId: 'p-q3',
      dueAt: DateTime(2026, 5, 15),
    );
    // Capture is not Clarify: parsed details never skip the Inbox.
    expect(item.status, ItemStatus.inbox);
    expect(item.contextId, 'c-office');
    expect(item.projectId, 'p-q3');
    expect(item.dueAt, DateTime(2026, 5, 15, 8, 30));
    expect(item.deferUntil, isNull);
    expect(reconciled.single.id, 'cap-2');
    expect((await items.getById('cap-2'))!.dueAt, DateTime(2026, 5, 15, 8, 30));
  });

  test('a failed reminder reconcile still returns the saved Item', () async {
    final dated = CaptureItem(
      items: items,
      clock: FakeClock(DateTime(2026, 5, 14, 9)),
      ids: FixedIdGenerator(['cap-3']),
      reconcileReminders: (_) async => throw StateError('no alarms'),
    );
    final item = await dated(
      title: 'Renew passport',
      deferUntil: DateTime(2026, 6, 1),
    );
    expect(item.deferUntil, DateTime(2026, 6, 1));
    expect(await items.getById('cap-3'), isNotNull);
  });
}
