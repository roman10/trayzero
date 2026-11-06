import 'package:cleartray/application/handle_notification_response.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/application/pending_snoozed_reminders.dart';
import 'package:cleartray/application/schedule_backup_reminder.dart';
import 'package:cleartray/application/schedule_weekly_review_reminder.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 11, 4, 16));
  });
  tearDown(() => env.dispose());

  Future<int> snooze(NotificationKind kind, {String? itemId}) async {
    final c = env.container();
    final id = switch (kind) {
      NotificationKind.due => notificationIdFor(itemId!, 1),
      NotificationKind.ready => notificationIdFor(itemId!, 2),
      NotificationKind.weeklyReview => weeklyReviewReminderId,
      NotificationKind.backup => backupReminderId,
      _ => throw ArgumentError('Kind has no Snooze'),
    };
    await HandleNotificationResponse(
      scheduler: env.scheduler,
      completeItem: c.read(completeItemProvider),
      moveToNextActions: c.read(moveItemToNextActionsProvider),
      clock: env.clock,
      navigate: (_) {},
    ).call((
      id: id,
      actionId: NotificationAction.snooze.id,
      payload: NotificationPayload(
        kind: kind,
        itemId: itemId,
        title: 'Reminder',
        body: '',
      ).encode(),
    ));
    return id;
  }

  test('startup re-arm preserves a snoozed overdue item reminder', () async {
    final container = env.container();
    final items = container.read(itemRepositoryProvider);
    final dueAt = env.clock.now().subtract(const Duration(minutes: 1));
    await items.upsert(
      anItem(
        id: 'snoozed',
        title: 'Pay rent',
        status: ItemStatus.calendar,
        dueAt: dueAt,
      ),
    );
    final id = notificationIdFor('snoozed', 1);
    final handler = HandleNotificationResponse(
      scheduler: env.scheduler,
      completeItem: container.read(completeItemProvider),
      moveToNextActions: container.read(moveItemToNextActionsProvider),
      clock: env.clock,
      navigate: (_) {},
    );
    await handler.call((
      id: id,
      actionId: NotificationAction.snooze.id,
      payload: const NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'snoozed',
        title: 'Due: Pay rent',
        body: '',
      ).encode(),
    ));
    final snooze = env.scheduler.scheduled.single;
    expect(snooze.id, id);
    expect(snooze.at, env.clock.now().add(const Duration(days: 1)));

    // main() runs this on every cold launch, after the headless action has
    // already placed its user-requested reminder back into the OS queue.
    await container.read(rearmItemRemindersProvider).call();

    expect((await items.getById('snoozed'))!.dueAt, dueAt);
    expect(env.scheduler.cancelled, isNot(contains(id)));
    expect(env.scheduler.pending[id], snooze.payload);
    expect(
      NotificationPayload.tryDecode(snooze.payload)!.snoozedUntil,
      snooze.at.toUtc(),
    );
  });

  test(
    'Ready Snooze survives startup without shifting recurrence anchors',
    () async {
      final c = env.container();
      final anchor = env.clock.now().subtract(const Duration(days: 1));
      await c
          .read(itemRepositoryProvider)
          .upsert(
            anItem(
              id: 'ready',
              status: ItemStatus.nextAction,
              deferUntil: anchor,
              recurrence: Recurrence.weekly,
            ),
          );
      final id = await snooze(NotificationKind.ready, itemId: 'ready');
      final payload = env.scheduler.pending[id];
      await c.read(rearmItemRemindersProvider).call();
      final item = (await c.read(itemRepositoryProvider).getById('ready'))!;
      expect(item.deferUntil, anchor);
      expect(item.recurrence, Recurrence.weekly);
      expect(env.scheduler.pending[id], payload);
      expect(env.scheduler.cancelled, isNot(contains(id)));
    },
  );

  test(
    'Due Snooze does not preserve a spent Ready request for the same item',
    () async {
      final c = env.container();
      final anchor = env.clock.now().subtract(const Duration(days: 1));
      await c
          .read(itemRepositoryProvider)
          .upsert(
            anItem(
              id: 'both',
              status: ItemStatus.calendar,
              dueAt: anchor,
              deferUntil: anchor,
            ),
          );
      final dueId = await snooze(NotificationKind.due, itemId: 'both');
      final readyId = notificationIdFor('both', 2);
      env.scheduler.pending[readyId] = const NotificationPayload(
        kind: NotificationKind.ready,
        itemId: 'both',
        title: 'Ready',
        body: '',
      ).encode();
      await c.read(rearmItemRemindersProvider).call();
      expect(env.scheduler.pending, contains(dueId));
      expect(env.scheduler.pending, isNot(contains(readyId)));
    },
  );

  test('expired Snooze follows normal startup reconciliation', () async {
    final c = env.container();
    await c
        .read(itemRepositoryProvider)
        .upsert(
          anItem(
            id: 'expired',
            status: ItemStatus.calendar,
            dueAt: env.clock.now().subtract(const Duration(days: 1)),
          ),
        );
    final id = await snooze(NotificationKind.due, itemId: 'expired');
    env.clock.advance(const Duration(days: 1));
    await c.read(rearmItemRemindersProvider).call();
    expect(env.scheduler.pending, isNot(contains(id)));
  });

  for (final action in ['edit', 'complete', 'delete']) {
    test('$action remains authoritative over a pending Snooze', () async {
      final c = env.container();
      final item = anItem(
        id: 'changed',
        status: ItemStatus.calendar,
        dueAt: env.clock.now().subtract(const Duration(days: 1)),
      );
      await c.read(itemRepositoryProvider).upsert(item);
      final id = await snooze(NotificationKind.due, itemId: item.id);
      switch (action) {
        case 'edit':
          final updated = item.copyWith(
            dueAt: env.clock.now().add(const Duration(days: 3)),
          );
          await c.read(saveItemProvider).call(updated);
          expect(
            NotificationPayload.tryDecode(
              env.scheduler.pending[id],
            )!.snoozedUntil,
            isNull,
          );
          expect(
            env.scheduler.scheduled.lastWhere((n) => n.id == id).at,
            updated.dueAt,
          );
        case 'complete':
          await c.read(completeItemProvider).call(item.id);
          expect(env.scheduler.pending, isNot(contains(id)));
        case 'delete':
          await c.read(deleteItemProvider).call(item.id);
          expect(env.scheduler.pending, isNot(contains(id)));
      }
      await c.read(rearmItemRemindersProvider).call();
      if (action != 'edit') expect(env.scheduler.pending, isNot(contains(id)));
    });
  }

  test(
    'enabled standing Snoozes survive startup, disabled ones cancel',
    () async {
      await env.prefs.setBool('weekly_review_reminder_enabled', true);
      await env.prefs.setBool('backup_reminder_enabled', true);
      final c = env.container();
      final reviewId = await snooze(NotificationKind.weeklyReview);
      final backupId = await snooze(NotificationKind.backup);
      final before = Map.of(env.scheduler.pending);
      await c.read(rearmStandingRemindersProvider).call();
      expect(env.scheduler.pending[reviewId], before[reviewId]);
      expect(env.scheduler.pending[backupId], before[backupId]);
      await env.prefs.setBool('weekly_review_reminder_enabled', false);
      await env.prefs.setBool('backup_reminder_enabled', false);
      await env.container().read(rearmStandingRemindersProvider).call();
      expect(env.scheduler.pending, isEmpty);
    },
  );

  test('expired standing Snoozes resume weekly scheduling', () async {
    await env.prefs.setBool('backup_reminder_enabled', true);
    final c = env.container();
    await snooze(NotificationKind.weeklyReview);
    await snooze(NotificationKind.backup);
    env.clock.advance(const Duration(days: 1));
    await c.read(rearmStandingRemindersProvider).call();
    for (final id in [weeklyReviewReminderId, backupReminderId]) {
      final request = env.scheduler.scheduled.lastWhere((n) => n.id == id);
      expect(request.repeat, ScheduleRepeat.weekly);
      expect(
        NotificationPayload.tryDecode(request.payload)!.snoozedUntil,
        isNull,
      );
    }
  });

  test('invalid metadata or mismatched ownership is not a Snooze override', () {
    final future = env.clock.now().add(const Duration(days: 1));
    String payload({
      String? owner = 'item',
      NotificationKind kind = NotificationKind.due,
    }) => NotificationPayload(
      kind: kind,
      itemId: owner,
      title: '',
      body: '',
      snoozedUntil: future,
    ).encode();
    final dueId = notificationIdFor('item', 1);
    expect(
      pendingSnoozedReminderIds(
        [
          (id: dueId, payload: payload(owner: 'other')),
          (id: dueId, payload: payload(kind: NotificationKind.ready)),
          (id: dueId + 5, payload: payload()),
          (id: dueId, payload: '{"k":"due","id":"item","snoozedUntil":123}'),
          (
            id: dueId,
            payload: '{"k":"due","id":"item","snoozedUntil":"invalid"}',
          ),
          (id: dueId, payload: '{"k":"due","id":"item"}'),
        ],
        now: env.clock.now(),
        itemId: 'item',
      ),
      isEmpty,
    );
  });

  test(
    'pending Snoozes are indexed by owner without normal or invalid requests',
    () {
      final future = env.clock.now().add(const Duration(days: 1));
      PendingNotification request(
        int id,
        String? owner,
        NotificationKind kind,
      ) => (
        id: id,
        payload: NotificationPayload(
          kind: kind,
          itemId: owner,
          title: '',
          body: '',
          snoozedUntil: future,
        ).encode(),
      );
      final first = request(
        notificationIdFor('a', 1),
        'a',
        NotificationKind.due,
      );
      final second = request(
        notificationIdFor('a', 2),
        'a',
        NotificationKind.ready,
      );
      final other = request(
        notificationIdFor('b', 1),
        'b',
        NotificationKind.due,
      );
      final standing = request(backupReminderId, null, NotificationKind.backup);
      final indexed = pendingSnoozesByOwner([
        first,
        other,
        second,
        standing,
        (id: 7, payload: 'invalid'),
        (
          id: 8,
          payload: const NotificationPayload(
            kind: NotificationKind.due,
            itemId: 'a',
            title: '',
            body: '',
          ).encode(),
        ),
      ]);
      expect(indexed.keys, unorderedEquals(['a', 'b', null]));
      expect(indexed['a'], [first, second]);
      expect(indexed['b'], [other]);
      expect(indexed[null], [standing]);
      expect(
        pendingSnoozedReminderIds(
          indexed['a']!,
          now: env.clock.now(),
          itemId: 'a',
        ),
        {first.id, second.id},
      );
    },
  );

  test('startup preserves Snoozes for multiple independent Items', () async {
    final c = env.container();
    for (final owner in ['a', 'b']) {
      await c
          .read(itemRepositoryProvider)
          .upsert(
            anItem(
              id: owner,
              status: ItemStatus.calendar,
              dueAt: env.clock.now().subtract(const Duration(days: 1)),
            ),
          );
      await snooze(NotificationKind.due, itemId: owner);
    }
    final pending = Map.of(env.scheduler.pending);
    await c.read(rearmItemRemindersProvider).call();
    expect(env.scheduler.pending, pending);
  });
}
