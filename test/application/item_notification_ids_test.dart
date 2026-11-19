import 'dart:math';

import 'package:cleartray/application/rearm_item_reminders.dart';
import 'package:cleartray/application/schedule_backup_reminder.dart';
import 'package:cleartray/application/schedule_weekly_review_reminder.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// The pre-v1.0.7 id scheme: a 29-bit hash plus the salt, so Items whose
/// hashes differ by up to 2 shared OS ids. Kept here only to seed the
/// pending requests an upgraded install still holds.
int legacyNotificationIdFor(String s, int salt) {
  var h = 0;
  for (var i = 0; i < s.length; i++) {
    h = 0x1fffffff & (h + s.codeUnitAt(i));
    h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
    h ^= h >> 6;
  }
  h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
  h ^= h >> 11;
  h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
  return (h + salt).abs() % 0x7fffffff;
}

void main() {
  group('notificationIdFor', () {
    test('every Item gets its own block, inside positive int32', () {
      final random = Random(7);
      final ids = <int>{};
      for (var n = 0; n < 2000; n++) {
        final itemId = List.generate(
          36,
          (_) => '0123456789abcdef-'[random.nextInt(17)],
        ).join();
        final block = [
          for (final salt in [1, 2, 3]) notificationIdFor(itemId, salt),
        ];
        expect(block, [block[0], block[0] + 1, block[0] + 2]);
        for (final id in block) {
          expect(id, greaterThanOrEqualTo(itemNotificationIdBase));
          expect(id, lessThanOrEqualTo(0x7fffffff));
        }
        ids.addAll(block);
      }
      // Distinct Items never overlap (barring a full hash collision, which
      // this fixed sample does not contain): 2000 Items, 6000 distinct ids.
      expect(ids, hasLength(6000));
    });

    test('standing reminder ids sit below the Item range', () {
      for (final id in [
        weeklyReviewReminderId,
        backupReminderId,
        // Reserved for standing Snoozes (990003 / 990004).
        990003,
        990004,
      ]) {
        expect(id, lessThan(itemNotificationIdBase));
      }
    });
  });

  group('upgrade from legacy Item reminder ids', () {
    late AppDatabase db;
    late ItemRepository items;
    late FakeNotificationScheduler scheduler;
    final now = DateTime(2026, 5, 14, 12);

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      items = ItemRepository(db, FakeClock(now));
      scheduler = FakeNotificationScheduler();
    });
    tearDown(() => db.close());

    RearmItemReminders rearm() => RearmItemReminders(
      items: items,
      scheduler: scheduler,
      clock: FakeClock(now),
      leadTimeMinutes: 30,
      deferSurfaceMinutes: 540,
    );

    Future<void> add(
      String id, {
      ItemStatus status = ItemStatus.calendar,
      DateTime? dueAt,
      DateTime? completedAt,
    }) => items.upsert(
      Item(
        id: id,
        title: 'T-$id',
        status: status,
        dueAt: dueAt,
        completedAt: completedAt,
        createdAt: now,
        updatedAt: now,
      ),
    );

    String payload(
      NotificationKind kind,
      String? itemId, {
      DateTime? snoozedUntil,
    }) => NotificationPayload(
      kind: kind,
      itemId: itemId,
      title: 'Due: T-$itemId',
      body: '',
      snoozedUntil: snoozedUntil,
    ).encode();

    test('moves pending reminders and Snoozes to the new ids, leaving '
        'standing reminders alone', () async {
      final due = DateTime(2026, 5, 20, 9);
      final snoozedUntil = DateTime(2026, 5, 15, 8);
      await add('a', dueAt: due);
      await add('s', dueAt: DateTime(2026, 5, 14, 9)); // Due already fired
      // Pending under the legacy scheme on the upgraded install.
      scheduler.pending[legacyNotificationIdFor('a', 1)] = payload(
        NotificationKind.due,
        'a',
      );
      scheduler.pending[legacyNotificationIdFor('a', 3)] = payload(
        NotificationKind.soon,
        'a',
      );
      final snoozed = payload(
        NotificationKind.due,
        's',
        snoozedUntil: snoozedUntil,
      );
      scheduler.pending[legacyNotificationIdFor('s', 1)] = snoozed;
      final standing = {
        weeklyReviewReminderId: payload(NotificationKind.weeklyReview, null),
        backupReminderId: payload(NotificationKind.backup, null),
        990003: payload(
          NotificationKind.weeklyReview,
          null,
          snoozedUntil: snoozedUntil,
        ),
        990004: payload(
          NotificationKind.backup,
          null,
          snoozedUntil: snoozedUntil,
        ),
      };
      scheduler.pending.addAll(standing);

      await rearm().call();

      expect(scheduler.pending, {
        ...standing,
        notificationIdFor('a', 1): isNotNull,
        notificationIdFor('a', 3): isNotNull,
        notificationIdFor('s', 1): snoozed,
      });
      // The Snooze keeps its user-chosen time under the new id.
      final moved = scheduler.scheduled.singleWhere(
        (s) => s.id == notificationIdFor('s', 1),
      );
      expect(moved.at.isAtSameMomentAs(snoozedUntil), isTrue);
      expect(moved.payload, snoozed);
      expect(
        // Re-armed by the migration and again by the bulk pass: same request.
        scheduler.scheduled
            .lastWhere((s) => s.id == notificationIdFor('a', 1))
            .at,
        due,
      );
      // Standing reminders are neither cancelled nor rescheduled.
      for (final id in standing.keys) {
        expect(scheduler.cancelled, isNot(contains(id)));
        expect(scheduler.scheduled.map((s) => s.id), isNot(contains(id)));
      }

      // A second launch has nothing left to migrate.
      final before = Map.of(scheduler.pending);
      scheduler.cancelled.clear();
      await rearm().call();
      expect(scheduler.pending, before);
      expect(
        scheduler.cancelled.where((id) => id < itemNotificationIdBase),
        isEmpty,
      );
    });

    test('drops legacy reminders of completed, deleted and calendar-imported '
        'Items without reviving them, except an edited import', () async {
      await add(
        'done',
        dueAt: DateTime(2026, 5, 20, 9),
        completedAt: now,
        status: ItemStatus.done,
      );
      await add('cal-x', dueAt: DateTime(2026, 5, 21, 9));
      for (final id in ['done', 'gone', 'cal-x']) {
        scheduler.pending[legacyNotificationIdFor(id, 1)] = payload(
          NotificationKind.due,
          id,
          snoozedUntil: id == 'gone' ? DateTime(2026, 5, 15) : null,
        );
      }

      await rearm().call();

      // A user-saved reminder on an import is re-armed under its new id; the
      // rest are gone without a revived Snooze.
      expect(scheduler.pending.keys.toSet(), {
        notificationIdFor('cal-x', 1),
        notificationIdFor('cal-x', 3),
      });
    });

    test(
      'a run interrupted after re-posting a Snooze completes on rerun',
      () async {
        final snoozedUntil = DateTime(2026, 5, 15, 8);
        await add('s', dueAt: DateTime(2026, 5, 14, 9));
        final snoozed = payload(
          NotificationKind.due,
          's',
          snoozedUntil: snoozedUntil,
        );
        // State after a crash between "schedule new" and "cancel old".
        scheduler.pending[legacyNotificationIdFor('s', 1)] = snoozed;
        scheduler.pending[notificationIdFor('s', 1)] = snoozed;

        await rearm().call();

        expect(scheduler.pending, {notificationIdFor('s', 1): snoozed});
      },
    );
  });
}
