import 'package:cleartray/application/handle_notification_response.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// End-to-end mapping from a raw OS notification interaction to its effect:
/// navigate, re-arm, or complete. The decision itself is unit-tested in
/// notification_intent_test; this locks the wiring against real
/// repositories + the fake scheduler.
void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create(
        now: DateTime(2026, 5, 19, 9),
        idQueue: ['spawn-1'],
      ));
  tearDown(() => env.dispose());

  ({HandleNotificationResponse handler, List<String> routes}) build() {
    final c = env.container();
    final routes = <String>[];
    return (
      handler: HandleNotificationResponse(
        scheduler: env.scheduler,
        completeItem: c.read(completeItemProvider),
        moveToNextActions: c.read(moveItemToNextActionsProvider),
        clock: env.clock,
        navigate: routes.add,
      ),
      routes: routes,
    );
  }

  NotificationActionEvent event(NotificationPayload p, {String? actionId}) =>
      (payload: p.encode(), actionId: actionId, id: 555);

  test('body tap navigates to the item', () async {
    final b = build();
    await b.handler.call(event(
      const NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'i1',
        title: 'Due: Pay rent',
        body: '',
      ),
    ));
    expect(b.routes, ['/item/i1']);
  });

  test('Snooze re-arms the same OS id one day out with the same payload',
      () async {
    final b = build();
    await b.handler.call(event(
      const NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'i1',
        title: 'Due: Pay rent',
        body: 'note',
      ),
      actionId: NotificationAction.snooze.id,
    ));
    final s = env.scheduler.scheduled.single;
    expect(s.id, 555);
    expect(s.at, DateTime(2026, 5, 20, 9));
    final back = NotificationPayload.tryDecode(s.payload)!;
    expect(back.title, 'Due: Pay rent');
    expect(back.kind, NotificationKind.due);
    expect(b.routes, isEmpty);
  });

  test('Done completes the item through the use case', () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(
      anItem(id: 'i1', title: 'Pay rent', status: ItemStatus.nextAction),
    );
    final handler = HandleNotificationResponse(
      scheduler: env.scheduler,
      completeItem: c.read(completeItemProvider),
      moveToNextActions: c.read(moveItemToNextActionsProvider),
      clock: env.clock,
      navigate: (_) {},
    );

    await handler.call(event(
      const NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'i1',
        title: 'Due: Pay rent',
        body: '',
      ),
      actionId: NotificationAction.done.id,
    ));

    final done = await items.getById('i1');
    expect(done!.status, ItemStatus.done);
    expect(done.completedAt, isNotNull);
  });

  test(
    'Ready activation preserves a repeating action through completion and undo',
    () async {
      final c = env.container();
      final repo = c.read(itemRepositoryProvider);
      final anchor = DateTime(2026, 5, 19);
      await repo.upsert(
        anItem(
          id: 'rec',
          status: ItemStatus.nextAction,
          recurrence: Recurrence.weekly,
          recurrenceCount: 3,
          deferUntil: anchor,
        ),
      );
      final handler = HandleNotificationResponse(
        scheduler: env.scheduler,
        completeItem: c.read(completeItemProvider),
        moveToNextActions: c.read(moveItemToNextActionsProvider),
        clock: env.clock,
        navigate: (_) {},
      );
      await handler.call(
        event(
          const NotificationPayload(
            kind: NotificationKind.ready,
            itemId: 'rec',
            title: 'Ready',
            body: '',
          ),
          actionId: NotificationAction.moveToNextActions.id,
        ),
      );
      expect((await repo.getById('rec'))!.deferUntil, anchor);
      expect((await repo.watchNextActions().first).single.id, 'rec');
      final successor = await c.read(completeItemProvider).call('rec');
      expect(successor, isNotNull);
      final next = (await repo.allActive()).single;
      expect(next.deferUntil, DateTime(2026, 5, 26));
      expect(next.recurrenceCount, 3);
      expect(next.recurrenceDoneCount, 1);
      await c
          .read(undoCompleteProvider)
          .call('rec', spawnedRecurrenceId: successor);
      expect((await repo.allActive()).single.id, 'rec');
      expect((await repo.getById('rec'))!.deferUntil, anchor);
    },
  );

  test('Move to Next Actions triages a Ready item and clears its defer',
      () async {
    final c = env.container();
    final items = c.read(itemRepositoryProvider);
    await items.upsert(
      anItem(
        id: 'r1',
        title: 'Ship it',
        status: ItemStatus.someday,
        deferUntil: DateTime(2026, 5, 19, 8),
      ),
    );
    final handler = HandleNotificationResponse(
      scheduler: env.scheduler,
      completeItem: c.read(completeItemProvider),
      moveToNextActions: c.read(moveItemToNextActionsProvider),
      clock: env.clock,
      navigate: (_) {},
    );

    await handler.call(event(
      const NotificationPayload(
        kind: NotificationKind.ready,
        itemId: 'r1',
        title: 'Ready: Ship it',
        body: '',
      ),
      actionId: NotificationAction.moveToNextActions.id,
    ));

    final moved = await items.getById('r1');
    expect(moved!.status, ItemStatus.nextAction);
    expect(moved.deferUntil, isNull);
    // The now-spent Ready: reminder is reconciled away by SaveItem.
    expect(env.scheduler.cancelled, contains(notificationIdFor('r1', 2)));
  });

  test('an undecodable payload is a no-op', () async {
    final b = build();
    await b.handler.call((payload: 'garbage', actionId: null, id: 1));
    expect(b.routes, isEmpty);
    expect(env.scheduler.scheduled, isEmpty);
  });
}
