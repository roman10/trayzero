import 'package:cleartray/infrastructure/time_zone.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Unit-tests the pure offset→zone mapping that backs the fixed-offset
/// fallback in `configureLocalTimeZone`. The `FlutterTimezone` platform
/// channel itself stays device-verified (plan verification step 3).
void main() {
  group('etcZoneNameForOffset', () {
    test('inverts the sign (IANA Etc/GMT convention)', () {
      // Singapore UTC+8.
      expect(etcZoneNameForOffset(const Duration(hours: 8)), 'Etc/GMT-8');
      // US Eastern standard UTC-5.
      expect(etcZoneNameForOffset(const Duration(hours: -5)), 'Etc/GMT+5');
    });

    test('handles zero and the extremes', () {
      expect(etcZoneNameForOffset(Duration.zero), 'Etc/GMT+0');
      expect(etcZoneNameForOffset(const Duration(hours: 14)), 'Etc/GMT-14');
      expect(etcZoneNameForOffset(const Duration(hours: -12)), 'Etc/GMT+12');
    });

    test('returns null for sub-hour offsets (caller keeps UTC)', () {
      expect(
        etcZoneNameForOffset(const Duration(hours: 5, minutes: 30)),
        isNull,
      );
      expect(
        etcZoneNameForOffset(const Duration(hours: -9, minutes: -30)),
        isNull,
      );
    });
  });

  group('the produced names resolve to the right real offset', () {
    setUpAll(tzdata.initializeTimeZones);

    for (final off in const [
      Duration(hours: 8),
      Duration(hours: -5),
      Duration.zero,
    ]) {
      test('offset $off round-trips through the tz database', () {
        final name = etcZoneNameForOffset(off)!;
        final loc = tz.getLocation(name); // throws if absent — it must exist
        expect(tz.TZDateTime(loc, 2026).timeZoneOffset, off);
      });
    }
  });

  // Regression: a second `initializeTimeZones()` silently resets `tz.local`
  // back to UTC (timezone pkg `env.dart` does `_local = _UTC` on every db
  // load). `configureLocalTimeZone()` runs first and sets the real zone, then
  // `LocalNotificationScheduler.init()` used to re-init unconditionally and
  // clobber it — so every reminder/calendar TZDateTime was built against UTC.
  // The scheduler now guards re-init with `timeZoneDatabase.isInitialized`.
  group('initializeTimeZones resets tz.local; the isInitialized guard does not',
      () {
    test('bare re-init clobbers the configured zone, guarded re-init keeps it',
        () {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Singapore'));
      expect(tz.local.name, 'Asia/Singapore');

      // What the scheduler used to do — destroys the configured zone.
      tzdata.initializeTimeZones();
      expect(tz.local.name, 'UTC');

      // What the scheduler does now — no-op when already loaded.
      tz.setLocalLocation(tz.getLocation('Asia/Singapore'));
      if (!tz.timeZoneDatabase.isInitialized) {
        tzdata.initializeTimeZones();
      }
      expect(tz.local.name, 'Asia/Singapore');
    });
  });
}
