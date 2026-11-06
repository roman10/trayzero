import 'package:cleartray/application/batch_delete_items.dart';
import 'package:cleartray/application/calendar_sync_service.dart';
import 'package:cleartray/application/delete_item.dart';
import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/calendar_mirror_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/recurrence/recurrence_policy.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../support/fakes.dart';

class RetryCalendar extends FakeCalendarGateway {
  bool failDeletes = false;
  bool failUpserts = false;
  Future<void> Function()? beforeWrite;
  final List<({String calendarId, String eventId})> attempts = [];
  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    attempts.add((calendarId: calendarId, eventId: eventId));
    if (failDeletes) return false;
    if (!events.containsKey(eventId)) return true;
    return super.deleteEvent(calendarId: calendarId, eventId: eventId);
  }

  @override
  Future<String?> upsertEvent(CalendarEventDraft draft) async {
    await beforeWrite?.call();
    return failUpserts ? null : super.upsertEvent(draft);
  }
}

void main() {
  final clock = FakeClock(DateTime(2026, 10, 13));
  late AppDatabase db;
  late ItemRepository items;
  late CalendarMirrorRepository mirrors;
  late RetryCalendar gateway;
  late CalendarSyncService sync;
  late AttachmentRepository attachments;
  late FakeNotificationScheduler scheduler;
  Item dated(String id, {bool recurring = false}) => Item(
    id: id,
    title: id,
    status: ItemStatus.calendar,
    dueAt: clock.now().add(const Duration(days: 1)),
    recurrence: recurring ? Recurrence.weekly : null,
    createdAt: clock.now(),
    updatedAt: clock.now(),
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    items = ItemRepository(db, clock);
    mirrors = CalendarMirrorRepository(db);
    gateway = RetryCalendar();
    sync = CalendarSyncService(items, clock, gateway, mirrors: mirrors);
    attachments = AttachmentRepository(db, clock, FixedIdGenerator([]));
    scheduler = FakeNotificationScheduler();
  });
  tearDown(() => db.close());

  test(
    'single deletion preserves ownership and cleanup survives a new sync instance',
    () async {
      await items.upsert(dated('one'));
      await sync.mirrorOut(calendarId: 'original');
      final eventId = (await items.getById('one'))!.calendarEventId!;
      await DeleteItem(
        items: items,
        attachments: attachments,
        scheduler: scheduler,
      )('one');
      expect(await items.getById('one'), isNull);
      expect(await mirrors.all(), hasLength(1));
      final restarted = CalendarSyncService(
        items,
        clock,
        gateway,
        mirrors: CalendarMirrorRepository(db),
      );
      final result = await restarted.mirrorOut(calendarId: 'different');
      expect(result.removed, 1);
      expect(gateway.attempts.single, (
        calendarId: 'original',
        eventId: eventId,
      ));
      expect(await mirrors.all(), isEmpty);
      expect(gateway.events, isEmpty);
    },
  );

  test(
    'batch deletion cleans all mirrored events while retaining unselected Items',
    () async {
      for (final id in ['a', 'b', 'c']) {
        await items.upsert(dated(id));
      }
      await sync.mirrorOut(calendarId: 'original');
      await BatchDeleteItems(
        items: items,
        attachments: attachments,
        scheduler: scheduler,
      )(['a', 'b']);
      final result = await sync.mirrorOut(calendarId: 'original');
      expect(result.removed, 2);
      expect(gateway.events, hasLength(1));
      expect(await mirrors.all(), hasLength(1));
      expect(
        (await items.getById('c'))!.calendarEventId,
        gateway.events.keys.single,
      );
    },
  );

  test(
    'failed native deletion keeps ownership and is retried in the original calendar',
    () async {
      await items.upsert(dated('one'));
      await sync.mirrorOut(calendarId: 'original');
      final eventId = (await items.getById('one'))!.calendarEventId!;
      await items.markCompleted('one', clock.now());
      gateway.failDeletes = true;
      final failed = await sync.mirrorOut(calendarId: 'different');
      expect(failed.pendingRemovals, 1);
      expect(failed.removed, 0);
      expect((await items.getById('one'))!.calendarEventId, eventId);
      expect(await mirrors.all(), hasLength(1));
      gateway.failDeletes = false;
      final retried = await sync.mirrorOut(calendarId: 'different');
      expect(retried.removed, 1);
      expect(retried.pendingRemovals, 0);
      expect(gateway.attempts.every((a) => a.calendarId == 'original'), isTrue);
      expect((await items.getById('one'))!.calendarEventId, isNull);
    },
  );

  test(
    'switching calendars creates a new event and retries cleanup of the old one',
    () async {
      await items.upsert(dated('one'));
      await sync.mirrorOut(calendarId: 'original');
      final oldId = (await items.getById('one'))!.calendarEventId!;
      gateway.failDeletes = true;
      final switched = await sync.mirrorOut(calendarId: 'new-calendar');
      final newId = (await items.getById('one'))!.calendarEventId!;
      expect(newId, isNot(oldId));
      expect(gateway.events[newId]!.calendarId, 'new-calendar');
      expect(switched.pendingRemovals, 1);
      expect(await mirrors.all(), hasLength(2));
      gateway.failDeletes = false;
      await sync.mirrorOut(calendarId: 'new-calendar');
      expect(gateway.events.keys, [newId]);
      expect((await mirrors.all()).single.calendarId, 'new-calendar');
      expect(gateway.attempts.last, (calendarId: 'original', eventId: oldId));
    },
  );

  test(
    'failed replacement write retains the old event until a new write succeeds',
    () async {
      await items.upsert(dated('one'));
      await sync.mirrorOut(calendarId: 'original');
      final eventId = (await items.getById('one'))!.calendarEventId!;
      gateway.failUpserts = true;
      await sync.mirrorOut(calendarId: 'new-calendar');
      expect(gateway.deleted, isEmpty);
      expect((await items.getById('one'))!.calendarEventId, eventId);
      expect((await mirrors.all()).single.calendarId, 'original');
    },
  );

  test(
    'deleting a completed recurrence predecessor preserves its live successor event',
    () async {
      await items.upsert(dated('first', recurring: true));
      await sync.mirrorOut(calendarId: 'original');
      final original = (await items.getById('first'))!;
      await items.markCompleted('first', clock.now());
      await items.upsert(
        nextRecurrenceOf(original, completedAt: clock.now(), newId: 'second')!,
      );
      await DeleteItem(
        items: items,
        attachments: attachments,
        scheduler: scheduler,
      )('first');
      final result = await sync.mirrorOut(calendarId: 'original');
      expect(result.removed, 0);
      expect(gateway.deleted, isEmpty);
      expect(gateway.events.keys.single, original.calendarEventId);
      expect((await mirrors.all()).single.itemId, 'second');
    },
  );

  test(
    'overlapping mirror requests serialize instead of creating duplicate events',
    () async {
      await items.upsert(dated('one'));
      await Future.wait([
        sync.mirrorOut(calendarId: 'original'),
        sync.mirrorOut(calendarId: 'original'),
      ]);
      expect(gateway.events, hasLength(1));
      expect(await mirrors.all(), hasLength(1));
    },
  );

  test(
    'calendar switching writes a shared recurring series only once',
    () async {
      await items.upsert(dated('first', recurring: true));
      await sync.mirrorOut(calendarId: 'original');
      final first = (await items.getById('first'))!;
      await items.upsert(
        nextRecurrenceOf(first, completedAt: clock.now(), newId: 'second')!,
      );
      final result = await sync.mirrorOut(calendarId: 'new-calendar');
      expect(result.written, 1);
      expect(
        (await items.getById('second'))!.calendarEventId,
        (await items.getById('first'))!.calendarEventId,
      );
      expect(gateway.deleted, [first.calendarEventId]);
      expect(gateway.events, hasLength(1));
      expect(gateway.events.values.single.calendarId, 'new-calendar');
    },
  );

  test(
    'completion overlapping a calendar switch preserves the successor series',
    () async {
      await items.upsert(dated('first', recurring: true));
      await sync.mirrorOut(calendarId: 'original');
      final first = (await items.getById('first'))!;
      gateway.beforeWrite = () async {
        gateway.beforeWrite = null;
        await items.markCompleted('first', clock.now());
        await items.upsert(
          nextRecurrenceOf(first, completedAt: clock.now(), newId: 'second')!,
        );
      };
      await sync.mirrorOut(calendarId: 'new-calendar');
      expect(gateway.events, hasLength(1));
      expect(gateway.events.values.single.calendarId, 'new-calendar');
      expect((await mirrors.all()).single.itemId, 'second');
      expect(
        (await items.getById('second'))!.calendarEventId,
        gateway.events.keys.single,
      );
      await sync.mirrorOut(calendarId: 'new-calendar');
      expect(gateway.events, hasLength(1));
      expect(gateway.events.values.single.calendarId, 'new-calendar');
      expect((await mirrors.all()).single.itemId, 'second');
    },
  );

  test(
    'v9 upgrade preserves legacy ownership even if Item is deleted before first sync',
    () async {
      final raw = sqlite3.openInMemory();
      final initial = AppDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      await ItemRepository(
        initial,
        clock,
      ).upsert(dated('legacy').copyWith(calendarEventId: 'old-native'));
      await initial.close();
      raw.execute('DROP TABLE calendar_mirrors');
      raw.execute('ALTER TABLE items DROP COLUMN focused_at');
      raw.execute('ALTER TABLE projects DROP COLUMN last_reviewed_at');
      raw.execute('ALTER TABLE reviews DROP COLUMN current_step');
      raw.execute('DROP TABLE item_tags');
      raw.execute('DROP TABLE tags');
      raw.execute('DROP TABLE import_batches');
      raw.execute('PRAGMA user_version = 9');
      final upgraded = AppDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      try {
        final repository = ItemRepository(upgraded, clock);
        await repository.delete('legacy');
        final ownership = CalendarMirrorRepository(upgraded);
        expect((await ownership.all()).single.calendarId, '');
        gateway.events['old-native'] = CalendarEventDraft(
          calendarId: 'previous-selection',
          title: 'Legacy event',
          start: clock.now(),
          end: clock.now(),
        );
        final legacySync = CalendarSyncService(
          repository,
          clock,
          gateway,
          mirrors: ownership,
        );
        await legacySync.bindLegacyOwnership(calendarId: 'previous-selection');
        await legacySync.mirrorOut(calendarId: 'new-selection');
        expect(gateway.attempts.single, (
          calendarId: 'previous-selection',
          eventId: 'old-native',
        ));
        expect(await ownership.all(), isEmpty);
      } finally {
        await upgraded.close();
        raw.dispose();
      }
    },
  );
}
