import 'dart:io';

import 'package:cleartray/application/drain_pending_notification_intents.dart';
import 'package:cleartray/application/handle_notification_response.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/infrastructure/pending_notification_intents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../support/harness.dart';

/// End-to-end of the headless-action recovery path: a tap that fired
/// while the app was dead is journaled by the background isolate, and
/// the next foreground launch replays it through the normal use case.
///
/// These tests stand in for the foreground side of that handoff: they
/// pre-populate the journal (as if the background isolate had just
/// written to it), run the drain, and assert the state mutation
/// happened — same way an in-app tap would.
void main() {
  late TestEnv env;
  late Directory tmp;
  late PendingNotificationIntents store;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 19, 9));
    tmp = await Directory.systemTemp.createTemp('drain_test_');
    store = PendingNotificationIntents(
      file: File(p.join(tmp.path, 'journal.jsonl')),
    );
  });

  tearDown(() async {
    await env.dispose();
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  DrainPendingNotificationIntents build({List<String>? routes}) {
    final c = env.container();
    return DrainPendingNotificationIntents(
      store: store,
      handler: HandleNotificationResponse(
        scheduler: env.scheduler,
        completeItem: c.read(completeItemProvider),
        moveToNextActions: c.read(moveItemToNextActionsProvider),
        clock: env.clock,
        navigate: routes == null ? (_) {} : routes.add,
      ),
    );
  }

  NotificationActionEvent journaled({
    required NotificationKind kind,
    required String itemId,
    required NotificationAction action,
    int notifId = 555,
  }) =>
      (
        payload: NotificationPayload(
          kind: kind,
          itemId: itemId,
          title: 'A title',
          body: '',
        ).encode(),
        actionId: action.id,
        id: notifId,
      );

  test('drains a Done intent and completes the item via the use case',
      () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(
      id: 'i1',
      title: 'Pay rent',
      status: ItemStatus.nextAction,
    ));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'i1',
      action: NotificationAction.done,
    ));

    await build().call();

    final done = await items.getById('i1');
    expect(done!.status, ItemStatus.done,
        reason: 'replay must run through CompleteItem, not just a status flip');
    expect(done.completedAt, isNotNull);
  });

  test('drains a Move-to-Next-Actions intent and triages the item',
      () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(
      id: 'r1',
      title: 'Ship it',
      status: ItemStatus.someday,
      deferUntil: DateTime(2026, 5, 19, 8),
    ));
    await store.append(journaled(
      kind: NotificationKind.ready,
      itemId: 'r1',
      action: NotificationAction.moveToNextActions,
    ));

    await build().call();

    final moved = await items.getById('r1');
    expect(moved!.status, ItemStatus.nextAction);
    expect(moved.deferUntil, isNull,
        reason: 'SaveItem clears the defer when surfacing into Next Actions');
  });

  test('drains multiple intents in append order', () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await items.upsert(anItem(id: 'b', status: ItemStatus.someday));
    await items.upsert(anItem(id: 'c', status: ItemStatus.nextAction));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'a',
      action: NotificationAction.done,
    ));
    await store.append(journaled(
      kind: NotificationKind.ready,
      itemId: 'b',
      action: NotificationAction.moveToNextActions,
    ));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'c',
      action: NotificationAction.done,
    ));

    await build().call();

    expect((await items.getById('a'))!.status, ItemStatus.done);
    expect((await items.getById('b'))!.status, ItemStatus.nextAction);
    expect((await items.getById('c'))!.status, ItemStatus.done);
  });

  test('drain clears the journal so a second launch is a no-op', () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(id: 'i1', status: ItemStatus.nextAction));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'i1',
      action: NotificationAction.done,
    ));

    await build().call();
    // Re-open the item to simulate the user un-doing the completion
    // (or a recurrence having spawned a fresh one with the same id).
    await items.upsert(anItem(id: 'i1', status: ItemStatus.nextAction));

    await build().call(); // would re-complete if the journal weren't cleared

    expect((await items.getById('i1'))!.status, ItemStatus.nextAction,
        reason: 'a drained journal must never replay the same tap twice');
  });

  test('a throwing replay does not abort the rest of the drain', () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(id: 'survivor', status: ItemStatus.nextAction));
    // First entry exercises the navigate path with a callback that
    // throws (e.g. router torn down mid-launch); the second must still
    // complete its item or a single broken replay would strand every
    // following one in the journal.
    await store.append(journaled(
      kind: NotificationKind.weeklyReview,
      itemId: 'unused',
      action: NotificationAction.startReview,
    ));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'survivor',
      action: NotificationAction.done,
    ));

    final drain = DrainPendingNotificationIntents(
      store: store,
      handler: HandleNotificationResponse(
        scheduler: env.scheduler,
        completeItem: c.read(completeItemProvider),
        moveToNextActions: c.read(moveItemToNextActionsProvider),
        clock: env.clock,
        navigate: (_) => throw StateError('router gone'),
      ),
    );
    await drain.call();

    expect((await items.getById('survivor'))!.status, ItemStatus.done,
        reason: 'a thrown replay must not block the rest of the journal');
  });

  test(
      'two Done intents for the same recurring item spawn exactly one successor',
      () async {
    // Soon: and Due: reminders for the same item both carry Done and
    // are scheduled under different OS ids. If both fire while the app
    // is dead and the user taps each in turn, the journal accumulates
    // two Dones with the same itemId. The drain must produce exactly
    // one rollover successor — CompleteItem is the single owner of
    // that invariant.
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(
      id: 'rec',
      title: 'Water plants',
      status: ItemStatus.nextAction,
      recurrence: Recurrence.weekly,
      deferUntil: DateTime(2026, 5, 18),
    ));
    await store.append(journaled(
      kind: NotificationKind.soon,
      itemId: 'rec',
      action: NotificationAction.done,
      notifId: notificationIdFor('rec', 3),
    ));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'rec',
      action: NotificationAction.done,
      notifId: notificationIdFor('rec', 1),
    ));

    await build().call();

    expect((await items.getById('rec'))!.status, ItemStatus.done);
    final active = await items.allActive();
    expect(active, hasLength(1),
        reason: 'two Done taps must not spawn two siblings');
    expect(active.single.recurrence, Recurrence.weekly);
  });

  test('an empty journal is a silent no-op', () async {
    final routes = <String>[];

    await build(routes: routes).call();

    expect(routes, isEmpty);
    expect(env.scheduler.scheduled, isEmpty);
    expect(env.scheduler.cancelled, isEmpty);
  });

  test('an undecodable payload in the journal is skipped, not crashed',
      () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(anItem(id: 'i1', status: ItemStatus.nextAction));
    // A payload from a future build whose kind this build can't decode.
    await store.append((
      payload: '{"k":"future-kind","t":"x","b":"y"}',
      actionId: NotificationAction.done.id,
      id: 1,
    ));
    await store.append(journaled(
      kind: NotificationKind.due,
      itemId: 'i1',
      action: NotificationAction.done,
    ));

    await build().call();

    expect((await items.getById('i1'))!.status, ItemStatus.done);
  });
}
