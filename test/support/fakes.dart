import 'dart:async';

import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/core/system_settings.dart';

/// In-memory [NotificationScheduler] for tests. Records every scheduled +
/// cancelled id so assertions can check that orchestration touched the
/// right reminders.
class FakeNotificationScheduler implements NotificationScheduler {
  final List<
    ({
      int id,
      DateTime at,
      String title,
      String body,
      ScheduleRepeat repeat,
      String? payload,
      Duration? timeoutAfter,
    })
  >
  scheduled = [];
  final List<int> cancelled = [];
  bool ready = false;
  final Map<int, String?> pending = {};

  final _responses = StreamController<NotificationActionEvent>.broadcast();

  /// Set by a test to simulate the app being cold-launched from a tap.
  NotificationActionEvent? launchResponse;

  /// Push a tap/action as if the OS delivered it while the app is alive.
  void emitResponse(NotificationActionEvent event) => _responses.add(event);

  /// Snapshot returned by [getActiveNotifications] — set by tests that
  /// exercise the foreground stale-notification sweep.
  List<ActiveNotification> active = const [];

  /// Current state returned by [permissionStatus] and [requestPermission].
  /// Defaults to granted so scheduling-focused tests need no setup.
  NotificationPermission status = NotificationPermission.granted;
  int requestCount = 0;
  bool exactAlarmsAllowed = true;
  int exactAlarmRequestCount = 0;

  @override
  Future<void> init() async => ready = true;

  @override
  Future<NotificationPermission> permissionStatus() async => status;

  @override
  Future<NotificationPermission> requestPermission() async {
    requestCount++;
    return status;
  }

  @override
  Future<bool> canScheduleExactAlarms() async => exactAlarmsAllowed;

  @override
  Future<bool> requestExactAlarmsPermission() async {
    exactAlarmRequestCount++;
    return exactAlarmsAllowed;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    String channelId = 'cleartray_reminders',
    String channelName = 'Reminders',
    ScheduleRepeat repeat = ScheduleRepeat.once,
    String? payload,
    Duration? timeoutAfter,
  }) async {
    pending[id] = payload;
    scheduled.add((
      id: id,
      at: at,
      title: title,
      body: body,
      repeat: repeat,
      payload: payload,
      timeoutAfter: timeoutAfter,
    ));
  }

  @override
  Stream<NotificationActionEvent> get responses => _responses.stream;

  @override
  Future<NotificationActionEvent?> takeLaunchResponse() async {
    final r = launchResponse;
    launchResponse = null;
    return r;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pending.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelled.add(-1);
    pending.clear();
  }

  @override
  Future<List<PendingNotification>> getPendingNotifications() async => [
    for (final entry in pending.entries) (id: entry.key, payload: entry.value),
  ];

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => active;
}

/// In-memory [CalendarGateway] for tests. Stores upserted events keyed by
/// id, records deletions, and returns a configurable list from
/// [eventsInRange] so import-in can be exercised without a device.
class FakeCalendarGateway implements CalendarGateway {
  FakeCalendarGateway({this.permissionGranted = true});

  bool permissionGranted;
  List<CalendarInfo> calendars = const [
    CalendarInfo(id: 'cal-1', name: 'Personal'),
  ];

  /// Last-written draft per event id (the [eventsInRange] return is
  /// independent and set via [importable]).
  final Map<String, CalendarEventDraft> events = {};
  final List<String> deleted = [];
  List<CalendarEventView> importable = const [];
  int _seq = 0;

  @override
  Future<bool> requestPermissions() async => permissionGranted;

  @override
  Future<bool> hasPermissions() async => permissionGranted;

  @override
  Future<List<CalendarInfo>> listCalendars() async => calendars;

  @override
  Future<String?> upsertEvent(CalendarEventDraft draft) async {
    final id = draft.id ?? 'evt-${_seq++}';
    events[id] = draft;
    return id;
  }

  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    deleted.add(eventId);
    return events.remove(eventId) != null;
  }

  @override
  Future<List<CalendarEventView>> eventsInRange({
    required String calendarId,
    required DateTime from,
    required DateTime to,
  }) async => importable;
}

/// In-memory [SystemSettings] for tests. Records how often the OS settings
/// deep-link was invoked and returns a configurable launch result.
class FakeSystemSettings implements SystemSettings {
  int openCount = 0;
  bool result = true;

  @override
  Future<bool> openAppSettings() async {
    openCount++;
    return result;
  }
}
