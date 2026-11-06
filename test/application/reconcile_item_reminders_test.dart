import 'package:cleartray/application/reconcile_item_reminders.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// Locks the contract of the block extracted from `SaveItem` independently
/// of `SaveItem` — `RearmItemReminders` also depends on it. (The integrated
/// path stays covered by save_item_test.dart, deliberately untouched.)
void main() {
  late FakeNotificationScheduler scheduler;
  final now = DateTime(2026, 5, 14, 12);

  setUp(() => scheduler = FakeNotificationScheduler());

  Item item({
    String id = 'i1',
    DateTime? dueAt,
    DateTime? deferUntil,
  }) =>
      Item(
        id: id,
        title: 'Email Alice',
        status: ItemStatus.calendar,
        dueAt: dueAt,
        deferUntil: deferUntil,
        createdAt: DateTime(2026, 5, 14, 10),
        updatedAt: DateTime(2026, 5, 14, 10),
      );

  Future<void> reconcile(
    Item i, {
    int leadTimeMinutes = 0,
    int deferSurfaceMinutes = 540,
  }) =>
      reconcileItemReminders(
        i,
        scheduler: scheduler,
        now: now,
        leadTimeMinutes: leadTimeMinutes,
        deferSurfaceMinutes: deferSurfaceMinutes,
      );

  test('schedules a "Due" reminder at dueAt (salt 1)', () async {
    final due = DateTime(2026, 5, 20, 9);
    await reconcile(item(dueAt: due));
    expect(scheduler.scheduled.single.id, notificationIdFor('i1', 1));
    expect(scheduler.scheduled.single.at, due);
    expect(scheduler.scheduled.single.title, 'Due: Email Alice');
    // The two anchors that aren't set are torn down.
    expect(scheduler.cancelled, contains(notificationIdFor('i1', 2)));
    expect(scheduler.cancelled, contains(notificationIdFor('i1', 3)));
  });

  test('a past dueAt cancels the Due id instead of scheduling it', () async {
    // Editing a due date backward must tear down the previously-armed Due
    // reminder, not leave it alive. `schedule` would silently drop a past
    // `at` without replacing the old notification, so reconcile must route
    // a past dueAt through the cancel branch.
    await reconcile(item(dueAt: DateTime(2026, 5, 14, 11))); // before now (12)
    expect(scheduler.scheduled.any((s) => s.title.startsWith('Due')), isFalse);
    expect(scheduler.cancelled, contains(notificationIdFor('i1', 1)));
  });

  test('schedules a "Ready" reminder at an explicit-time deferUntil (salt 2)',
      () async {
    final defer = DateTime(2026, 5, 17, 8);
    await reconcile(item(deferUntil: defer));
    expect(scheduler.scheduled.single.id, notificationIdFor('i1', 2));
    expect(scheduler.scheduled.single.at, defer);
    expect(scheduler.scheduled.single.title, startsWith('Ready'));
  });

  test('elapsed Ready reminders are cancelled while the anchor is retained', () async {
    for (final anchor in [DateTime(2026, 5, 14), now]) {
      await reconcile(item(deferUntil: anchor));
    }
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelled, contains(notificationIdFor('i1', 2)));
  });

  test('a past midnight anchor still schedules a future surface hour', () async {
    await reconcile(item(deferUntil: DateTime(2026, 5, 14)),
      deferSurfaceMinutes: 13 * 60);
    expect(scheduler.scheduled.single.at, DateTime(2026, 5, 14, 13));
  });

  test('a start-of-day defer surfaces at the configured hour', () async {
    await reconcile(
      item(deferUntil: DateTime(2026, 5, 18)),
      deferSurfaceMinutes: 540, // 09:00
    );
    expect(scheduler.scheduled.single.at, DateTime(2026, 5, 18, 9));
  });

  test('a lead time schedules a "Soon" tickler before dueAt (salt 3)',
      () async {
    await reconcile(
      item(dueAt: DateTime(2026, 5, 20, 9)),
      leadTimeMinutes: 60,
    );
    final soon =
        scheduler.scheduled.firstWhere((s) => s.title.startsWith('Soon'));
    expect(soon.id, notificationIdFor('i1', 3));
    expect(soon.at, DateTime(2026, 5, 20, 8));
    expect(scheduler.scheduled.any((s) => s.title.startsWith('Due')), isTrue);
  });

  test('each reminder carries a decodable payload tying it to the item',
      () async {
    await reconcile(
      item(dueAt: DateTime(2026, 5, 20, 9), deferUntil: DateTime(2026, 5, 18)),
      leadTimeMinutes: 60,
    );
    final byKind = {
      for (final s in scheduler.scheduled)
        NotificationPayload.tryDecode(s.payload)!.kind:
            NotificationPayload.tryDecode(s.payload)!,
    };
    expect(byKind[NotificationKind.due]!.itemId, 'i1');
    expect(byKind[NotificationKind.due]!.title, 'Due: Email Alice');
    expect(byKind[NotificationKind.soon]!.itemId, 'i1');
    expect(byKind[NotificationKind.ready]!.itemId, 'i1');
  });

  test('no dates cancels all three ids and schedules nothing', () async {
    await reconcile(item());
    expect(scheduler.scheduled, isEmpty);
    expect(
      scheduler.cancelled,
      containsAll([
        notificationIdFor('i1', 1),
        notificationIdFor('i1', 2),
        notificationIdFor('i1', 3),
      ]),
    );
  });

  // The Soon banner auto-retires at dueAt so it never sits stale next to
  // the live Due notification — declarative via Android's timeoutAfter.
  // iOS ignores the field (the foreground sweep covers it).
  test('Soon carries timeoutAfter == leadTimeMinutes', () async {
    await reconcile(
      item(dueAt: DateTime(2026, 5, 20, 9)),
      leadTimeMinutes: 60,
    );
    final soon =
        scheduler.scheduled.firstWhere((s) => s.title.startsWith('Soon'));
    expect(soon.timeoutAfter, const Duration(minutes: 60));
  });

  test('Due carries no timeoutAfter (it IS the surviving banner)', () async {
    await reconcile(
      item(dueAt: DateTime(2026, 5, 20, 9)),
      leadTimeMinutes: 60,
    );
    final due =
        scheduler.scheduled.firstWhere((s) => s.title.startsWith('Due'));
    expect(due.timeoutAfter, isNull);
  });

  // A deferred item that also has a dueAt: Ready surfaces first, Due
  // fires later. Ready auto-retires exactly at dueAt.
  test('Ready carries timeoutAfter == dueAt - readyAt when both are set',
      () async {
    final defer = DateTime(2026, 5, 17, 8);
    final due = DateTime(2026, 5, 20, 9);
    await reconcile(item(dueAt: due, deferUntil: defer));
    final ready =
        scheduler.scheduled.firstWhere((s) => s.title.startsWith('Ready'));
    expect(ready.timeoutAfter, due.difference(defer));
  });

  test('Ready carries no timeoutAfter when the item has no dueAt', () async {
    await reconcile(item(deferUntil: DateTime(2026, 5, 17, 8)));
    final ready =
        scheduler.scheduled.firstWhere((s) => s.title.startsWith('Ready'));
    expect(ready.timeoutAfter, isNull);
  });
}
