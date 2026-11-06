import 'package:cleartray/application/restore_item_reminders.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late ItemRepository items;
  late RestoreItemReminders restore;
  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 10, 13, 7));
    items = ItemRepository(env.db, env.clock);
    restore = RestoreItemReminders(
      items: items,
      scheduler: env.scheduler,
      clock: env.clock,
      leadTimeMinutes: 30,
      deferSurfaceMinutes: 9 * 60,
    );
  });
  tearDown(() => env.dispose());

  test('restored calendar task immediately schedules Due and Soon', () async {
    final due = DateTime(2026, 10, 13, 11);
    await items.upsert(
      anItem(id: 'dated', status: ItemStatus.calendar, dueAt: due),
    );
    await restore(['dated', 'dated']);
    expect(env.scheduler.scheduled.map((r) => r.at), [
      due,
      due.subtract(const Duration(minutes: 30)),
    ]);
    expect(env.scheduler.cancelled, [notificationIdFor('dated', 2)]);
  });

  test(
    'same-day date-only defer keeps the configured morning reminder',
    () async {
      final anchor = DateTime(2026, 10, 13);
      await items.upsert(
        anItem(id: 'ready', status: ItemStatus.nextAction, deferUntil: anchor),
      );
      await restore(['ready']);
      expect(env.scheduler.scheduled.single.at, DateTime(2026, 10, 13, 9));
      expect((await items.getById('ready'))!.deferUntil, anchor);
    },
  );

  test('expired anchors retire alarms without changing stored dates', () async {
    final anchor = DateTime(2026, 10, 12);
    await items.upsert(
      anItem(
        id: 'expired',
        status: ItemStatus.calendar,
        dueAt: anchor,
        deferUntil: anchor,
      ),
    );
    await restore(['expired']);
    expect(env.scheduler.scheduled, isEmpty);
    expect(
      env.scheduler.cancelled,
      containsAll([
        for (final salt in [1, 2, 3]) notificationIdFor('expired', salt),
      ]),
    );
    expect((await items.getById('expired'))!.deferUntil, anchor);
  });

  test(
    'overwritten completed, undated, missing and imported Items cancel all alarms',
    () async {
      for (final id in ['done', 'undated', 'cal-native']) {
        await items.upsert(
          anItem(
            id: id,
            status: id == 'done' ? ItemStatus.done : ItemStatus.calendar,
            dueAt: id == 'undated' ? null : DateTime(2026, 10, 14),
          ),
        );
      }
      await restore(['done', 'undated', 'cal-native', 'missing']);
      expect(env.scheduler.scheduled, isEmpty);
      expect(
        env.scheduler.cancelled,
        unorderedEquals([
          for (final id in ['done', 'undated', 'cal-native', 'missing'])
            for (final salt in [1, 2, 3]) notificationIdFor(id, salt),
        ]),
      );
    },
  );
}
