import 'package:cleartray/core/calendar_connection.dart';
import 'package:cleartray/infrastructure/shared_preferences_calendar_connection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'old manual setting migrates paused without automatic consent',
    () async {
      SharedPreferences.setMockInitialValues({
        'calendar_sync_enabled': true,
        'calendar_sync_calendar_id': 'previous',
      });
      final prefs = SharedPreferencesCalendarConnection(
        await SharedPreferences.getInstance(),
      );
      expect(prefs.load().calendarId, 'previous');
      expect(prefs.load().automatic, isFalse);
      await prefs.save(const CalendarConnectionSettings());
      expect(
        prefs.load().connected,
        isFalse,
      ); // Legacy values must not resurrect.
    },
  );
  test('paused state, removal intent and timestamp survive reload', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPreferencesCalendarConnection(
      await SharedPreferences.getInstance(),
    );
    final now = DateTime.utc(2026, 11, 5);
    await prefs.save(
      CalendarConnectionSettings(
        calendarId: 'original',
        calendarName: 'Personal',
        removing: true,
        lastSuccess: now,
        fingerprint: 'snapshot',
      ),
    );
    final restored = prefs.load();
    expect(restored.removing, isTrue);
    expect(restored.automatic, isFalse);
    expect(restored.lastSuccess, now);
    expect(restored.fingerprint, 'snapshot');
  });
}
