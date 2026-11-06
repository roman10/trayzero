import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/recurrence/recurrence_policy.dart';
import 'package:cleartray/application/calendar_sync_service.dart';
import 'package:cleartray/data/repositories/calendar_mirror_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;
  late FakeCalendarGateway gateway;
  late CalendarSyncService svc;

  final now = DateTime(2026, 5, 14, 9);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ItemRepository(db, FakeClock(now));
    gateway = FakeCalendarGateway();
    svc = CalendarSyncService(repo, FakeClock(now), gateway,
      mirrors: CalendarMirrorRepository(db));
  });

  tearDown(() async => db.close());

  Future<void> seed(Item item) => repo.upsert(item);

  // Only hard-landscape (status == calendar) items mirror to the OS calendar,
  // so the default status here is calendar.
  Item dated(String id,
          {DateTime? due, ItemStatus status = ItemStatus.calendar}) =>
      Item(
        id: id,
        title: 'Task $id',
        status: status,
        dueAt: due ?? now.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      );

  group('mirrorOut', () {
    test('creates an event and stores the assigned id on the item',
        () async {
      await seed(dated('a'));

      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.written, 1);
      expect(r.removed, 0);
      expect(gateway.events, hasLength(1));
      final stored = (await repo.getById('a'))!.calendarEventId;
      expect(stored, isNotNull);
      expect(gateway.events.containsKey(stored), isTrue);
      expect(gateway.events[stored]!.title, '[Trayzero] Task a');
    });

    test('is idempotent: a second run updates the same event, no duplicate',
        () async {
      await seed(dated('a'));
      await svc.mirrorOut(calendarId: 'cal-1');
      final firstId = (await repo.getById('a'))!.calendarEventId;

      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.written, 1);
      expect(gateway.events, hasLength(1));
      expect((await repo.getById('a'))!.calendarEventId, firstId);
      expect(gateway.events.keys.single, firstId);
    });

    test('a dated next-action is not mirrored (only calendar items are)',
        () async {
      await seed(dated('soft', status: ItemStatus.nextAction));

      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.written, 0);
      expect(gateway.events, isEmpty);
      expect((await repo.getById('soft'))!.calendarEventId, isNull);
    });

    test('items without a due date are not mirrored', () async {
      await seed(Item(
        id: 'a',
        title: 'No due',
        status: ItemStatus.nextAction,
        createdAt: now,
        updatedAt: now,
      ));

      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.written, 0);
      expect(gateway.events, isEmpty);
    });

    test('deletes the event and clears the id when the item is completed',
        () async {
      await seed(dated('a'));
      await svc.mirrorOut(calendarId: 'cal-1');
      final eventId = (await repo.getById('a'))!.calendarEventId!;

      await repo.markCompleted('a', now);
      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.written, 0);
      expect(r.removed, 1);
      expect(gateway.deleted, contains(eventId));
      expect(gateway.events, isEmpty);
      expect((await repo.getById('a'))!.calendarEventId, isNull);
    });

    test('does not mirror items that were imported from the calendar',
        () async {
      gateway.importable = [
        CalendarEventView(
            id: 'e1',
            title: 'Dentist #gtd',
            start: now.add(const Duration(days: 2))),
      ];
      await svc.importIn(calendarId: 'cal-1');

      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.written, 0);
      expect(gateway.events, isEmpty);
      expect((await repo.getById('cal-e1'))!.calendarEventId, isNull);
    });

    test('deletes the event when the due date is cleared', () async {
      await seed(dated('a'));
      await svc.mirrorOut(calendarId: 'cal-1');

      final item = await repo.getById('a');
      await repo.upsert(item!.copyWith(clearDueAt: true));
      final r = await svc.mirrorOut(calendarId: 'cal-1');

      expect(r.removed, 1);
      expect(gateway.events, isEmpty);
      expect((await repo.getById('a'))!.calendarEventId, isNull);
    });
  });

  group('importIn', () {
    test('imports only #gtd-tagged events, stripping the tag', () async {
      gateway.importable = [
        CalendarEventView(
            id: 'e1',
            title: 'Dentist #gtd',
            start: now.add(const Duration(days: 2))),
        const CalendarEventView(id: 'e2', title: 'Lunch with Sam'),
      ];

      final n = await svc.importIn(calendarId: 'cal-1');

      expect(n, 1);
      final imported = await repo.getById('cal-e1');
      expect(imported, isNotNull);
      expect(imported!.title, 'Dentist');
      expect(imported.status, ItemStatus.calendar);
    });

    test('is idempotent on the event id', () async {
      gateway.importable = [
        const CalendarEventView(id: 'e1', title: '#gtd Review'),
      ];

      expect(await svc.importIn(calendarId: 'cal-1'), 1);
      expect(await svc.importIn(calendarId: 'cal-1'), 0);
    });
  });

  group('recurring mirror', () {
    Item recurring(String id) => Item(
          id: id,
          title: 'Standup',
          status: ItemStatus.calendar,
          dueAt: now.add(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
          recurrence: Recurrence.weekly,
          recurrenceByWeekdays: const [1, 3, 5],
        );

    test('mirrors a recurring item as one event carrying the rule',
        () async {
      await seed(recurring('r'));

      final res = await svc.mirrorOut(calendarId: 'cal-1');

      expect(res.written, 1);
      expect(gateway.events, hasLength(1));
      final rec = gateway.events.values.single.recurrence;
      expect(rec, isNotNull);
      expect(rec!.frequency, CalendarFrequency.weekly);
      expect(rec.byWeekdays, const [1, 3, 5]);
    });

    test('completing an instance keeps the same series, not a duplicate',
        () async {
      await seed(recurring('r'));
      await svc.mirrorOut(calendarId: 'cal-1');
      final eventId = (await repo.getById('r'))!.calendarEventId;
      expect(eventId, isNotNull);

      // Simulate CompleteItem: mark done + spawn the successor, which
      // carries the calendar series id forward.
      final original = (await repo.getById('r'))!;
      await repo.markCompleted('r', now);
      final next =
          nextRecurrenceOf(original, completedAt: now, newId: 'r2')!;
      expect(next.calendarEventId, eventId);
      await repo.upsert(next);

      final res = await svc.mirrorOut(calendarId: 'cal-1');

      expect(res.removed, 0, reason: 'the live series must survive');
      expect(gateway.deleted, isEmpty);
      expect(gateway.events, hasLength(1));
      expect(gateway.events.containsKey(eventId), isTrue);
      // Ownership moved from the completed instance to its successor.
      expect((await repo.getById('r'))!.calendarEventId, isNull);
      expect((await repo.getById('r2'))!.calendarEventId, eventId);
    });

    test('a non-recurring completed item still has its event removed',
        () async {
      await seed(dated('one-off'));
      await svc.mirrorOut(calendarId: 'cal-1');
      final eventId = (await repo.getById('one-off'))!.calendarEventId!;
      await repo.markCompleted('one-off', now);

      final res = await svc.mirrorOut(calendarId: 'cal-1');

      expect(res.removed, 1);
      expect(gateway.deleted, contains(eventId));
      expect(gateway.events, isEmpty);
    });
  });

  test('requestPermissions delegates to the gateway', () async {
    gateway.permissionGranted = false;
    expect(await svc.requestPermissions(), isFalse);
    gateway.permissionGranted = true;
    expect(await svc.requestPermissions(), isTrue);
  });
  test(
    'selected imports are scoped by source and occurrence, and never republished',
    () async {
      final first = CalendarEventView(
        id: 'series',
        title: 'Appointment',
        start: now,
      );
      final next = CalendarEventView(
        id: 'series',
        title: 'Appointment',
        start: now.add(const Duration(days: 7)),
      );
      gateway.importable = [first, next];
      expect(
        await svc.importSelected(
          calendarId: 'source-a',
          events: [first],
          toInbox: true,
        ),
        1,
      );
      expect(
        await svc.importSelected(
          calendarId: 'source-a',
          events: [first],
          toInbox: true,
        ),
        0,
      );
      expect(
        (await svc.importCandidates(calendarId: 'source-a')).single.start,
        next.start,
      );
      expect(
        await svc.importSelected(
          calendarId: 'source-b',
          events: [first],
          toInbox: false,
        ),
        1,
      );
      expect(
        (await repo.allActive()).map((i) => i.status),
        containsAll([ItemStatus.inbox, ItemStatus.calendar]),
      );
      expect((await svc.mirrorOut(calendarId: 'cal-1')).written, 0);
    },
  );

  test(
    'import picker excludes events owned by the publishing connection',
    () async {
      await seed(dated('owned'));
      await svc.mirrorOut(calendarId: 'cal-1');
      gateway.importable = [
        CalendarEventView(id: gateway.events.keys.single, title: 'Owned'),
        CalendarEventView(id: 'external', title: 'Other', start: now),
      ];
      expect(
        (await svc.importCandidates(calendarId: 'cal-1')).single.id,
        'external',
      );
    },
  );
}
