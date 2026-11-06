import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/calendar_gateway.dart';

/// Default [CalendarGateway] backed by `device_calendar`.
///
/// All `device_calendar` / `TZDateTime` types are confined to this file.
/// Times are converted using `tz.local`, which is configured at startup by
/// `configureLocalTimeZone()` (see `lib/infrastructure/time_zone.dart`);
/// without that, `tz.local` is UTC and mirrored events land at the wrong
/// wall-clock time.
class DeviceCalendarGateway implements CalendarGateway {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  @override
  Future<bool> hasPermissions() async {
    final result = await _plugin.hasPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  @override
  Future<bool> requestPermissions() async {
    // Trust an existing grant first: avoids a redundant prompt when the user
    // taps "Grant"/"Retry" again, and sidesteps the Android quirk where a
    // fresh requestPermissions() can report the pre-grant state.
    final has = await _plugin.hasPermissions();
    if (has.isSuccess && (has.data ?? false)) return true;
    final res = await _plugin.requestPermissions();
    if (res.isSuccess && (res.data ?? false)) return true;
    // The Android grant can land a tick after the dialog returns; re-check
    // before concluding it was denied.
    final recheck = await _plugin.hasPermissions();
    return recheck.isSuccess && (recheck.data ?? false);
  }

  @override
  Future<List<CalendarInfo>> listCalendars() async {
    var res = await _plugin.retrieveCalendars();
    // device_calendar on Android intermittently returns an empty list on the
    // first call right after the permission grant propagates to the system
    // CalendarProvider. A single retry after a short delay reliably picks the
    // calendars up. Only retry the genuinely-empty case — leave real errors
    // alone so they surface rather than masquerading as "no calendars".
    if (res.isSuccess && (res.data?.isEmpty ?? true)) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      res = await _plugin.retrieveCalendars();
    }
    if (!res.isSuccess) {
      throw StateError(
        'Device calendar lookup failed (codes: '
        '${res.errors.map((e) => e.errorCode).join(',')})',
      );
    }
    return (res.data ?? const <Calendar>[])
        .where((c) => (c.id ?? '').isNotEmpty)
        .map(
          (c) => CalendarInfo(
            id: c.id!,
            name: c.name ?? c.id ?? 'Unnamed',
            accountName: c.accountName,
            writable: c.isReadOnly != true,
          ),
        )
        .toList();
  }

  @override
  Future<String?> upsertEvent(CalendarEventDraft draft) async {
    final event = Event(
      draft.calendarId,
      eventId: draft.id,
      title: draft.title,
      description: draft.description,
      start: tz.TZDateTime.from(draft.start, tz.local),
      end: tz.TZDateTime.from(draft.end, tz.local),
      recurrenceRule: draft.recurrence == null
          ? null
          : _toDeviceRecurrence(draft.recurrence!, draft.start),
    );
    final res = await _plugin.createOrUpdateEvent(event);
    if (res?.isSuccess ?? false) return res!.data;
    return null;
  }

  /// Translate the platform-agnostic [CalendarRecurrence] into a
  /// `device_calendar` RRULE. [start] supplies the day-of-month / weekday
  /// anchor when the recurrence doesn't specify one explicitly.
  RecurrenceRule _toDeviceRecurrence(CalendarRecurrence r, DateTime start) {
    final freq = switch (r.frequency) {
      CalendarFrequency.daily => RecurrenceFrequency.Daily,
      CalendarFrequency.weekly => RecurrenceFrequency.Weekly,
      CalendarFrequency.monthly => RecurrenceFrequency.Monthly,
      CalendarFrequency.yearly => RecurrenceFrequency.Yearly,
    };
    // 1..7 (Mon..Sun) → DayOfWeek (Monday..Sunday, 0-indexed).
    DayOfWeek dow(int weekday) => DayOfWeek.values[weekday - 1];

    List<DayOfWeek>? daysOfWeek;
    int? dayOfMonth;
    WeekNumber? weekOfMonth;

    switch (r.frequency) {
      case CalendarFrequency.weekly:
        daysOfWeek = (r.byWeekdays.isEmpty ? [start.weekday] : r.byWeekdays)
            .map(dow)
            .toList();
      case CalendarFrequency.monthly:
        if (r.monthlyWeek != null && r.monthlyWeekday != null) {
          weekOfMonth = r.monthlyWeek == -1 || r.monthlyWeek! >= 5
              ? WeekNumber.Last
              : WeekNumber.values[r.monthlyWeek! - 1];
          daysOfWeek = [dow(r.monthlyWeekday!)];
        } else {
          dayOfMonth = start.day;
        }
      case CalendarFrequency.daily:
      case CalendarFrequency.yearly:
        break;
    }

    return RecurrenceRule(
      freq,
      interval: r.interval,
      endDate: r.until,
      totalOccurrences: r.count,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
      weekOfMonth: weekOfMonth,
    );
  }

  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    final res = await _plugin.deleteEvent(calendarId, eventId);
    if (res.isSuccess && (res.data ?? false)) return true;
    // Users can remove the event in their calendar app. Confirm absence;
    // unsuccessful lookups still retain ownership for a later retry.
    final remaining = await _plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(eventIds: [eventId]),
    );
    return remaining.isSuccess &&
        remaining.data != null &&
        remaining.data!.isEmpty;
  }

  @override
  Future<List<CalendarEventView>> eventsInRange({
    required String calendarId,
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await _plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: from, endDate: to),
    );
    if (!res.isSuccess) throw StateError('Calendar event lookup failed');
    return (res.data ?? const <Event>[])
        .where((e) => e.eventId != null)
        .map(
          (e) => CalendarEventView(
            id: e.eventId!,
            title: e.title ?? '',
            start: e.start?.toLocal(),
          ),
        )
        .toList();
  }
}
