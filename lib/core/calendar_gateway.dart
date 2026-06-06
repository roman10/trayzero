import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A calendar known to the device.
class CalendarInfo {
  const CalendarInfo({required this.id, required this.name});
  final String id;
  final String name;
}

enum CalendarFrequency { daily, weekly, monthly, yearly }

/// Platform-agnostic recurrence description attached to a mirrored event so
/// the system calendar generates the whole series natively (one repeating
/// event) instead of one dated event per occurrence. Kept free of
/// `device_calendar` types — the gateway impl translates it to an RRULE.
///
/// Mirrors the structure of the domain `RecurrenceRule` + end condition;
/// the [until]/[count] pair is mutually exclusive (the `Item` invariant
/// guarantees it, and iCalendar forbids UNTIL+COUNT together).
class CalendarRecurrence {
  const CalendarRecurrence({
    required this.frequency,
    this.interval = 1,
    this.byWeekdays = const [],
    this.monthlyWeek,
    this.monthlyWeekday,
    this.until,
    this.count,
  });

  final CalendarFrequency frequency;
  final int interval;

  /// Weekly: weekdays the event repeats on, `DateTime.monday`(1)..
  /// `DateTime.sunday`(7). Empty = the start date's own weekday.
  final List<int> byWeekdays;

  /// Monthly "Nth weekday": which week (1..4, or -1 = last) and which
  /// weekday (1..7). Both null = repeat on the start date's day-of-month.
  final int? monthlyWeek;
  final int? monthlyWeekday;

  /// End condition. At most one is non-null.
  final DateTime? until;
  final int? count;
}

/// An event to mirror out to a device calendar. [id] is the platform event
/// id when updating an existing event; null asks the gateway to create a
/// new one and report back the id it was assigned. [recurrence], when set,
/// makes the gateway write a single repeating event.
class CalendarEventDraft {
  const CalendarEventDraft({
    required this.calendarId,
    required this.title,
    required this.start,
    required this.end,
    this.id,
    this.description,
    this.recurrence,
  });
  final String calendarId;
  final String? id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final CalendarRecurrence? recurrence;
}

/// An event read back from a device calendar.
class CalendarEventView {
  const CalendarEventView({required this.id, required this.title, this.start});
  final String id;
  final String title;
  final DateTime? start;
}

/// Platform-agnostic system-calendar port.
///
/// The concrete impl lives in
/// `lib/infrastructure/device_calendar_gateway.dart` and wraps
/// `device_calendar` (including timezone conversion). Tests use an in-memory
/// fake. This indirection is what lets the sync service be unit-tested and
/// keeps `device_calendar`'s `TZDateTime` types out of the feature code.
abstract class CalendarGateway {
  Future<bool> requestPermissions();
  Future<List<CalendarInfo>> listCalendars();

  /// Create or update [draft]. Returns the platform event id (the existing
  /// one when [CalendarEventDraft.id] was supplied, or a freshly assigned
  /// one when it was null), or null if the write failed.
  Future<String?> upsertEvent(CalendarEventDraft draft);

  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  });

  Future<List<CalendarEventView>> eventsInRange({
    required String calendarId,
    required DateTime from,
    required DateTime to,
  });
}

final calendarGatewayProvider = Provider<CalendarGateway>((ref) {
  throw UnimplementedError('calendarGatewayProvider must be overridden');
});
