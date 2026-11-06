import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/calendar_connection.dart';

class SharedPreferencesCalendarConnection
    implements CalendarConnectionPreferences {
  SharedPreferencesCalendarConnection(this._prefs);
  final SharedPreferences _prefs;
  static const key = 'calendar_connection_v1';

  @override
  CalendarConnectionSettings load() {
    final stored = _prefs.getString(key);
    if (stored == null) {
      // The old switch only exposed manual actions. Never silently opt existing
      // users into automatic writes. Retain the old selection for cleanup.
      final id = _prefs.getString('calendar_sync_calendar_id');
      return CalendarConnectionSettings(
        calendarId: id == null || id.isEmpty ? null : id,
      );
    }
    try {
      final raw = jsonDecode(stored) as Map;
      final id = raw['calendarId'] as String?;
      return CalendarConnectionSettings(
        calendarId: id == null || id.isEmpty ? null : id,
        calendarName: raw['calendarName'] as String?,
        automatic: raw['automatic'] == true,
        removing: raw['removing'] == true,
        lastSuccess: DateTime.tryParse(raw['lastSuccess'] as String? ?? ''),
        fingerprint: raw['fingerprint'] as String?,
      );
    } catch (_) {
      // Malformed settings must never enable publishing or native deletion.
      return const CalendarConnectionSettings();
    }
  }

  @override
  Future<void> save(CalendarConnectionSettings settings) async {
    final ok = await _prefs.setString(
      key,
      jsonEncode({
        'calendarId': settings.calendarId,
        'calendarName': settings.calendarName,
        'automatic': settings.automatic,
        'removing': settings.removing,
        'lastSuccess': settings.lastSuccess?.toUtc().toIso8601String(),
        'fingerprint': settings.fingerprint,
      }),
    );
    if (!ok) throw StateError('Could not save calendar connection');
  }
}
