import 'package:cleartray/application/providers.dart';
import 'package:cleartray/application/sweep_stale_item_notifications.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// The foreground counterpart of Android's `timeoutAfter`-based
/// auto-dismiss: cancels every "Soon:" / "Ready:" notification whose
/// underlying item has moved on (Due already fired, item completed, or
/// item deleted). This is iOS's only path — Android also runs it as a
/// belt-and-braces safety net.
void main() {
  late TestEnv env;

  ActiveNotification active({
    required String itemId,
    required NotificationKind kind,
    required int salt,
  }) =>
      (
        id: notificationIdFor(itemId, salt),
        payload: NotificationPayload(
          kind: kind,
          itemId: itemId,
          title: '${kind.name}: t',
          body: 'b',
        ).encode(),
      );

  setUp(() async => env = await TestEnv.create(now: DateTime(2026, 5, 20, 12)));
  tearDown(() => env.dispose());

  Future<SweepStaleItemNotifications> build() async {
    final c = env.container();
    return c.read(sweepStaleItemNotificationsProvider);
  }

  Future<void> upsert(Item item) async {
    final c = env.container();
    await c.read(itemRepositoryProvider).upsert(item);
  }

  test('cancels a "Soon" whose dueAt is now in the past', () async {
    await upsert(anItem(id: 'i1', dueAt: DateTime(2026, 5, 20, 11)));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.soon, salt: 3),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, [notificationIdFor('i1', 3)]);
  });

  test('keeps a "Soon" whose dueAt is still in the future', () async {
    await upsert(anItem(id: 'i1', dueAt: DateTime(2026, 5, 20, 14)));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.soon, salt: 3),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, isEmpty);
  });

  test('cancels a "Soon" for an item that lost its dueAt entirely', () async {
    await upsert(anItem(id: 'i1'));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.soon, salt: 3),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, [notificationIdFor('i1', 3)]);
  });

  test('cancels a "Ready" whose dueAt is now in the past', () async {
    await upsert(anItem(
      id: 'i1',
      deferUntil: DateTime(2026, 5, 17, 9),
      dueAt: DateTime(2026, 5, 20, 9),
    ));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.ready, salt: 2),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, [notificationIdFor('i1', 2)]);
  });

  // No dueAt means Ready isn't an "early warning" — there's no Due
  // coming, so the surfaced banner stays until the user touches it.
  test('keeps a "Ready" whose item has no dueAt', () async {
    await upsert(anItem(id: 'i1', deferUntil: DateTime(2026, 5, 17, 9)));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.ready, salt: 2),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, isEmpty);
  });

  test('cancels notifications for a deleted item', () async {
    // No upsert — the item simply doesn't exist in the repo.
    env.scheduler.active = [
      active(itemId: 'ghost', kind: NotificationKind.soon, salt: 3),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, [notificationIdFor('ghost', 3)]);
  });

  test('cancels notifications for a completed item', () async {
    await upsert(anItem(
      id: 'i1',
      dueAt: DateTime(2026, 5, 20, 14), // still in future
      completedAt: DateTime(2026, 5, 20, 11),
    ));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.soon, salt: 3),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, [notificationIdFor('i1', 3)]);
  });

  // Due IS the surviving banner. Standing reminders aren't item-scoped.
  // Neither should ever be cancelled by the sweep.
  test('leaves Due, weekly review, and backup notifications alone', () async {
    await upsert(anItem(id: 'i1', dueAt: DateTime(2026, 5, 20, 11)));
    env.scheduler.active = [
      active(itemId: 'i1', kind: NotificationKind.due, salt: 1),
      (
        id: 42,
        payload: const NotificationPayload(
          kind: NotificationKind.weeklyReview,
          title: 'Weekly review',
          body: 'b',
        ).encode(),
      ),
      (
        id: 43,
        payload: const NotificationPayload(
          kind: NotificationKind.backup,
          title: 'Back up',
          body: 'b',
        ).encode(),
      ),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, isEmpty);
  });

  test('an empty tray is a silent no-op (no repository reads)', () async {
    env.scheduler.active = const [];

    await (await build()).call();

    expect(env.scheduler.cancelled, isEmpty);
  });

  test('skips notifications with an undecodable or absent payload', () async {
    env.scheduler.active = [
      (id: 1, payload: null),
      (id: 2, payload: 'not-json'),
    ];

    await (await build()).call();

    expect(env.scheduler.cancelled, isEmpty);
  });
}
