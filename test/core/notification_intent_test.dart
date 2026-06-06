import 'package:cleartray/core/notification_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPayload codec', () {
    test('round-trips every kind, with and without an item id', () {
      for (final kind in NotificationKind.values) {
        final p = NotificationPayload(
          kind: kind,
          itemId: kind == NotificationKind.weeklyReview ? null : 'item-42',
          title: 'A title',
          body: 'Some body',
        );
        final back = NotificationPayload.tryDecode(p.encode())!;
        expect(back.kind, kind);
        expect(back.itemId, p.itemId);
        expect(back.title, 'A title');
        expect(back.body, 'Some body');
      }
    });

    test('null / empty / garbage / unknown-kind decode to null', () {
      expect(NotificationPayload.tryDecode(null), isNull);
      expect(NotificationPayload.tryDecode(''), isNull);
      expect(NotificationPayload.tryDecode('not json'), isNull);
      expect(NotificationPayload.tryDecode('[1,2,3]'), isNull);
      // A kind wire-id this build doesn't know (forward compat).
      expect(NotificationPayload.tryDecode('{"k":"future","t":"x","b":"y"}'),
          isNull);
    });

    test('missing title/body default to empty, not a throw', () {
      final p = NotificationPayload.tryDecode('{"k":"due","id":"i1"}')!;
      expect(p.kind, NotificationKind.due);
      expect(p.itemId, 'i1');
      expect(p.title, '');
      expect(p.body, '');
    });
  });

  group('actionsForKind', () {
    test('Due leads with Done then Snooze', () {
      expect(actionsForKind(NotificationKind.due),
          [NotificationAction.done, NotificationAction.snooze]);
    });

    // Soon deliberately ships Done only — snooze on an early warning
    // would re-post as a stale "upcoming" banner the next day, after
    // Due has already fired (the background isolate can't clamp).
    test('Soon ships Done only — no snooze', () {
      expect(
        actionsForKind(NotificationKind.soon),
        const [NotificationAction.done],
      );
    });

    test('Ready leads with triage; standing nudges with their CTA', () {
      expect(actionsForKind(NotificationKind.ready),
          [NotificationAction.moveToNextActions, NotificationAction.snooze]);
      expect(actionsForKind(NotificationKind.weeklyReview),
          [NotificationAction.startReview, NotificationAction.snooze]);
      expect(actionsForKind(NotificationKind.backup),
          [NotificationAction.backupNow, NotificationAction.snooze]);
    });

    test('every kind except Soon keeps Snooze as its last action', () {
      for (final kind in NotificationKind.values) {
        if (kind == NotificationKind.soon) continue;
        expect(actionsForKind(kind).last, NotificationAction.snooze);
      }
    });

    test(
        'mutation + snooze stay headless; only screen actions open the app',
        () {
      // Snooze re-arms in place; Done and Move-to-Next-Actions are
      // journaled when the app is dead and replayed on next launch
      // (see PendingNotificationIntents). None should bring the app
      // forward — that would interrupt the user for no payoff.
      expect(NotificationAction.snooze.foreground, isFalse,
          reason: 'snooze reschedules headlessly');
      expect(NotificationAction.done.foreground, isFalse,
          reason: 'Done has no follow-up screen');
      expect(NotificationAction.moveToNextActions.foreground, isFalse,
          reason: 'Move-to-Next-Actions has no follow-up screen');
      // Start review / Back up now exist to land the user on a screen,
      // so they must bring the app forward.
      expect(NotificationAction.startReview.foreground, isTrue,
          reason: 'Start review opens the review screen');
      expect(NotificationAction.backupNow.foreground, isTrue,
          reason: 'Back up now opens settings to share');
    });
  });

  group('snoozeTarget', () {
    test('is exactly one day later, same wall-clock time', () {
      final now = DateTime(2026, 5, 19, 14, 30);
      expect(snoozeTarget(now), DateTime(2026, 5, 20, 14, 30));
    });
  });

  group('routeForPayload', () {
    NotificationPayload p(NotificationKind k, {String? id}) =>
        NotificationPayload(kind: k, itemId: id, title: 't', body: 'b');

    test('item kinds route to the item, falling back to inbox', () {
      expect(routeForPayload(p(NotificationKind.due, id: 'x')), '/item/x');
      expect(routeForPayload(p(NotificationKind.soon, id: 'y')), '/item/y');
      expect(routeForPayload(p(NotificationKind.ready, id: 'z')), '/item/z');
      expect(routeForPayload(p(NotificationKind.due)), '/inbox');
    });

    test('standing reminders route to their screens', () {
      expect(routeForPayload(p(NotificationKind.weeklyReview)), '/review');
      expect(routeForPayload(p(NotificationKind.backup)), '/settings');
    });
  });

  group('decideNotificationResponse', () {
    final now = DateTime(2026, 5, 19, 9);
    const payload = NotificationPayload(
      kind: NotificationKind.due,
      itemId: 'i1',
      title: 'Due: Pay rent',
      body: '',
    );

    test('body tap (null action) opens the payload route', () {
      final d = decideNotificationResponse(
        payload: payload,
        actionId: null,
        now: now,
      );
      expect(d, isA<OpenScreen>());
      expect((d as OpenScreen).location, '/item/i1');
    });

    test('Snooze action reschedules one day out, same content', () {
      final d = decideNotificationResponse(
        payload: payload,
        actionId: NotificationAction.snooze.id,
        now: now,
      );
      expect(d, isA<RescheduleAt>());
      final r = d as RescheduleAt;
      expect(r.at, DateTime(2026, 5, 20, 9));
      expect(r.payload.title, 'Due: Pay rent');
      expect(r.payload.kind, NotificationKind.due);
    });

    test('an unknown action id is treated as a body tap (safe default)', () {
      final d = decideNotificationResponse(
        payload: payload,
        actionId: 'an-action-from-a-newer-build',
        now: now,
      );
      expect(d, isA<OpenScreen>());
    });

    // Defence in depth for the action-retirement case: an in-flight
    // notification scheduled by an older build can still carry a button
    // that the current build no longer offers (Snooze on Soon, as of
    // this branch). The body-tap fallback prevents the retired button
    // from re-opening the bug class the retirement closed.
    test(
        'a known action no longer offered for the kind falls back to body tap',
        () {
      final d = decideNotificationResponse(
        payload: const NotificationPayload(
          kind: NotificationKind.soon,
          itemId: 'i1',
          title: 'Soon: Pay rent',
          body: '',
        ),
        actionId: NotificationAction.snooze.id,
        now: now,
      );
      expect(d, isA<OpenScreen>());
      expect((d as OpenScreen).location, '/item/i1');
    });

    test('Done on an item-scoped payload completes that item', () {
      final d = decideNotificationResponse(
        payload: payload,
        actionId: NotificationAction.done.id,
        now: now,
      );
      expect(d, isA<CompleteItemDecision>());
      expect((d as CompleteItemDecision).itemId, 'i1');
    });

    test('Done with no item id falls back to opening (defensive)', () {
      final d = decideNotificationResponse(
        payload: const NotificationPayload(
          kind: NotificationKind.due,
          title: 'Due: orphan',
          body: '',
        ),
        actionId: NotificationAction.done.id,
        now: now,
      );
      expect(d, isA<OpenScreen>());
    });

    test('Move to Next Actions on a Ready item triages that item', () {
      final d = decideNotificationResponse(
        payload: const NotificationPayload(
          kind: NotificationKind.ready,
          itemId: 'r1',
          title: 'Ready: ship it',
          body: '',
        ),
        actionId: NotificationAction.moveToNextActions.id,
        now: now,
      );
      expect(d, isA<MoveToNextActionsDecision>());
      expect((d as MoveToNextActionsDecision).itemId, 'r1');
    });

    test('Start review / Back up now open their screens', () {
      final review = decideNotificationResponse(
        payload: const NotificationPayload(
          kind: NotificationKind.weeklyReview,
          title: 'Weekly review time',
          body: '',
        ),
        actionId: NotificationAction.startReview.id,
        now: now,
      );
      expect(review, isA<OpenScreen>());
      expect((review as OpenScreen).location, '/review');

      final backup = decideNotificationResponse(
        payload: const NotificationPayload(
          kind: NotificationKind.backup,
          title: 'Back up your data',
          body: '',
        ),
        actionId: NotificationAction.backupNow.id,
        now: now,
      );
      expect(backup, isA<OpenScreen>());
      expect((backup as OpenScreen).location, '/settings');
    });
  });
}
