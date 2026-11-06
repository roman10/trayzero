import 'dart:async';

import 'package:cleartray/application/calendar_connection_controller.dart';
import 'package:cleartray/application/calendar_sync_service.dart';
import 'package:cleartray/core/calendar_connection.dart';
import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/calendar_mirror_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

class MemoryCalendarPreferences implements CalendarConnectionPreferences {
  CalendarConnectionSettings value = const CalendarConnectionSettings();
  bool fail = false;
  @override
  CalendarConnectionSettings load() => value;
  @override
  Future<void> save(CalendarConnectionSettings settings) async {
    if (fail) throw StateError('disk unavailable');
    value = settings;
  }
}

class ControlledCalendar extends FakeCalendarGateway {
  int writes = 0;
  int prompts = 0;
  bool failWrites = false;
  bool failDeletes = false;
  Completer<void>? holdWrite;
  @override
  Future<bool> requestPermissions() async {
    prompts++;
    return permissionGranted;
  }

  @override
  Future<String?> upsertEvent(CalendarEventDraft draft) async {
    writes++;
    await holdWrite?.future;
    if (failWrites) return null;
    return super.upsertEvent(draft);
  }

  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    if (failDeletes) return false;
    if (!events.containsKey(eventId)) return true;
    return super.deleteEvent(calendarId: calendarId, eventId: eventId);
  }
}

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late CalendarMirrorRepository mirrors;
  late CalendarSyncService sync;
  late ControlledCalendar gateway;
  late MemoryCalendarPreferences preferences;
  late StreamController<String> changes;
  late FakeClock clock;
  late CalendarConnectionController controller;
  const calendar = CalendarInfo(id: 'cal-1', name: 'Personal');

  CalendarConnectionController create() => CalendarConnectionController(
    preferences: preferences,
    sync: sync,
    gateway: gateway,
    clock: clock,
    changes: changes.stream,
  );
  Item scheduled(String id) => Item(
    id: id,
    title: id,
    status: ItemStatus.calendar,
    dueAt: clock.now().add(const Duration(days: 1)),
    createdAt: clock.now(),
    updatedAt: clock.now(),
  );
  Future<void> changed() async {
    changes.add(calendarPublicationFingerprint(await items.allActive()));
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> drain() async {
    // Native/Drift calls span multiple event-loop turns.
    for (var i = 0; i < 35; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 11, 5, 9));
    items = ItemRepository(db, clock);
    mirrors = CalendarMirrorRepository(db);
    gateway = ControlledCalendar();
    preferences = MemoryCalendarPreferences();
    changes = StreamController<String>.broadcast(sync: true);
    sync = CalendarSyncService(items, clock, gateway, mirrors: mirrors);
    controller = create();
    await items.upsert(scheduled('one'));
    await changed();
  });
  tearDown(() async {
    controller.dispose();
    await changes.close();
    await db.close();
  });

  test('disconnected launch never prompts or writes', () async {
    await controller.resume();
    expect(gateway.prompts, 0);
    expect(gateway.writes, 0);
  });

  test(
    'connect, debounced edits, pause, resume and manual update reuse one event',
    () async {
      await controller.connect(calendar);
      expect(gateway.events, hasLength(1));
      await items.upsert(
        (await items.getById('one'))!.copyWith(title: 'Edited'),
      );
      await changed();
      clock.advance(const Duration(seconds: 1));
      await drain();
      expect(gateway.events.values.single.title, '[Trayzero] Edited');
      expect(controller.state.pending, isFalse);
      final writes = gateway.writes;
      await controller.setAutomatic(false);
      await items.upsert(
        (await items.getById('one'))!.copyWith(title: 'Paused edit'),
      );
      await changed();
      clock.advance(const Duration(seconds: 5));
      await controller.resume();
      expect(gateway.writes, writes);
      expect(controller.state.pending, isTrue);
      await controller.updateNow();
      expect(controller.state.settings.automatic, isFalse);
      expect(gateway.events.values.single.title, '[Trayzero] Paused edit');
      await controller.setAutomatic(true);
      expect(controller.state.pending, isFalse);
      expect(gateway.events, hasLength(1));
      expect(gateway.prompts, 0);
    },
  );

  test(
    'native ids and unrelated task edits do not change publication fingerprint',
    () {
      final original = scheduled('one');
      final signature = calendarPublicationFingerprint([original]);
      expect(
        calendarPublicationFingerprint([
          original.copyWith(
            calendarEventId: 'native',
            updatedAt: clock.now().add(const Duration(minutes: 1)),
          ),
        ]),
        signature,
      );
      expect(
        calendarPublicationFingerprint([
          original,
          scheduled('task').copyWith(status: ItemStatus.nextAction),
        ]),
        signature,
      );
    },
  );

  test('changing destination preserves pause and moves events once', () async {
    const other = CalendarInfo(id: 'cal-2', name: 'Work');
    gateway.calendars = [calendar, other];
    await controller.connect(calendar);
    await controller.setAutomatic(false);
    await controller.connect(other);
    expect(controller.state.settings.calendarId, other.id);
    expect(controller.state.settings.automatic, isFalse);
    expect(controller.state.pending, isFalse);
    expect(gateway.events, hasLength(1));
    expect(gateway.events.values.single.calendarId, other.id);
    final writes = gateway.writes;
    await items.upsert(
      (await items.getById('one'))!.copyWith(title: 'Still paused'),
    );
    await changed();
    clock.advance(const Duration(seconds: 1));
    await drain();
    await controller.resume();
    expect(gateway.writes, writes);
    expect(controller.state.pending, isTrue);
  });

  test('disconnect keep stops publishing and reconnect reuses links', () async {
    await controller.connect(calendar);
    final id = gateway.events.keys.single;
    await controller.disconnect(removeEvents: false);
    await items.upsert((await items.getById('one'))!.copyWith(title: 'Kept'));
    await changed();
    clock.advance(const Duration(seconds: 1));
    await controller.resume();
    expect(gateway.events.keys.single, id);
    expect(controller.state.settings.connected, isFalse);
    await controller.connect(calendar);
    expect(gateway.events.keys.single, id);
    expect(gateway.events.values.single.title, '[Trayzero] Kept');
  });

  test(
    'remove only deletes owned events and preserves Trayzero items',
    () async {
      await controller.connect(calendar);
      gateway.events['unrelated'] = CalendarEventDraft(
        calendarId: 'cal-1',
        title: 'Other event',
        start: clock.now(),
        end: clock.now(),
      );
      await controller.disconnect(removeEvents: true);
      expect(gateway.events.keys, ['unrelated']);
      expect(await items.getById('one'), isNotNull);
      expect(await mirrors.all(), isEmpty);
      expect((await items.getById('one'))!.calendarEventId, isNull);
      expect(controller.state.settings.connected, isFalse);
    },
  );

  test(
    'failed removal survives restart; resume retries removal without recreating',
    () async {
      await controller.connect(calendar);
      gateway.failDeletes = true;
      await controller.disconnect(removeEvents: true);
      expect(preferences.value.removing, isTrue);
      expect(preferences.value.automatic, isFalse);
      expect(controller.state.issue, CalendarConnectionIssue.removalFailed);
      expect(await mirrors.all(), hasLength(1));
      final writes = gateway.writes;
      controller.dispose();
      controller = create();
      gateway.failDeletes = false;
      await controller.resume();
      expect(gateway.events, isEmpty);
      expect(gateway.writes, writes);
      expect(preferences.value.connected, isFalse);
    },
  );

  test(
    'permission loss does not prompt or advance last success; explicit retry recovers',
    () async {
      await controller.connect(calendar);
      final last = controller.state.settings.lastSuccess;
      gateway.permissionGranted = false;
      clock.advance(const Duration(hours: 1));
      await controller.resume();
      expect(controller.state.issue, CalendarConnectionIssue.permission);
      expect(controller.state.settings.lastSuccess, last);
      expect(gateway.prompts, 0);
      gateway.permissionGranted = true;
      await controller.updateNow();
      expect(controller.state.issue, isNull);
      expect(controller.state.settings.lastSuccess, clock.now());
    },
  );

  test(
    'write failures remain pending and never report a successful update',
    () async {
      gateway.failWrites = true;
      await controller.connect(calendar);
      expect(controller.state.issue, CalendarConnectionIssue.updateFailed);
      expect(controller.state.settings.lastSuccess, isNull);
      expect(controller.state.pending, isTrue);
      gateway.failWrites = false;
      await controller.updateNow();
      expect(controller.state.issue, isNull);
      expect(controller.state.pending, isFalse);
    },
  );

  test('missing or read-only target never receives automatic writes', () async {
    gateway.calendars = [
      const CalendarInfo(id: 'cal-1', name: 'Read only', writable: false),
    ];
    await controller.connect(calendar);
    expect(gateway.writes, 0);
    expect(controller.state.issue, CalendarConnectionIssue.calendarMissing);
  });

  test(
    'pause during a slow write prevents remaining writes and cleanup',
    () async {
      await items.upsert(scheduled('two'));
      gateway.holdWrite = Completer<void>();
      final connecting = controller.connect(calendar);
      await drain();
      expect(gateway.writes, 1);
      final pausing = controller.setAutomatic(false);
      gateway.holdWrite!.complete();
      await connecting;
      await pausing;
      expect(gateway.writes, 1);
      expect(controller.state.settings.automatic, isFalse);
      expect(controller.state.pending, isTrue);
    },
  );

  test(
    'persisting removal intent must succeed before native deletion',
    () async {
      await controller.connect(calendar);
      preferences.fail = true;
      await controller.disconnect(removeEvents: true);
      expect(gateway.deleted, isEmpty);
      expect(controller.state.issue, CalendarConnectionIssue.storage);
    },
  );

  test(
    'foreground changes during a write are reconciled by another run',
    () async {
      await controller.connect(calendar);
      gateway.holdWrite = Completer<void>();
      await items.upsert(
        (await items.getById('one'))!.copyWith(title: 'First edit'),
      );
      await changed();
      clock.advance(const Duration(seconds: 1));
      await drain();
      await items.upsert(
        (await items.getById('one'))!.copyWith(title: 'Latest edit'),
      );
      await changed();
      gateway.holdWrite!.complete();
      await drain();
      gateway.holdWrite = null;
      clock.advance(const Duration(seconds: 1));
      await drain();
      expect(gateway.events.values.single.title, '[Trayzero] Latest edit');
      expect(controller.state.pending, isFalse);
    },
  );
  test(
    'disposing during a native write retains ownership without post-dispose updates',
    () async {
      gateway.holdWrite = Completer<void>();
      final connecting = controller.connect(calendar);
      await drain();
      expect(gateway.writes, 1);
      controller.dispose();
      gateway.holdWrite!.complete();
      await connecting;
      // A replacement controller can safely continue from the recorded native ID.
      controller = create();
      gateway.holdWrite = null;
      await controller.resume();
      expect(gateway.events, hasLength(1));
      expect(await mirrors.all(), hasLength(1));
    },
  );
  test('background edits wait for foreground reconciliation', () async {
    await controller.connect(calendar);
    final writes = gateway.writes;
    controller.background();
    await items.upsert(
      (await items.getById('one'))!.copyWith(title: 'While away'),
    );
    await changed();
    clock.advance(const Duration(minutes: 5));
    await drain();
    expect(gateway.writes, writes);
    expect(controller.state.pending, isTrue);
    await controller.resume();
    expect(gateway.events.values.single.title, '[Trayzero] While away');
    expect(controller.state.pending, isFalse);
  });
}
