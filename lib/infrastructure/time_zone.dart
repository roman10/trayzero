import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Loads the IANA timezone database and points `tz.local` at the device's
/// real timezone.
///
/// Must run before anything builds a `TZDateTime` — calendar mirror-out and
/// scheduled notifications both do. Without it `tz.local` defaults to UTC
/// and events/reminders are written at the wrong wall-clock hour.
///
/// Idempotent and best-effort: if the platform can't report a usable zone we
/// fall back to a fixed-offset zone matching the device's current UTC offset
/// (or, failing even that, UTC) rather than crash startup. The offset
/// fallback matters because the weekly review / backup nudges repeat via
/// `dayOfWeekAndTime`, which the plugin matches in `tz.local` — leaving it
/// at UTC would re-arm them at the wrong local hour.
Future<void> configureLocalTimeZone() async {
  tzdata.initializeTimeZones();
  String? attemptedId;
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    attemptedId = tzInfo.identifier;
    tz.setLocalLocation(tz.getLocation(attemptedId));
    return;
  } catch (e) {
    // FlutterTimezone failed or returned an id absent from the IANA db
    // (seen on some OPPO / Android 16 builds). Log the raw cause once so a
    // future device tells us whether to upgrade flutter_timezone, alias an
    // id, or ship a Kotlin fallback — the bare catch we had before swallowed
    // both possibilities. Then fall back to a fixed-offset zone matching the
    // device's current UTC offset.
    debugPrint(
      '[tz] FlutterTimezone fallback: '
      'attemptedId=${attemptedId ?? "<null>"} error=$e',
    );
  }
  final name = etcZoneNameForOffset(DateTime.now().timeZoneOffset);
  if (name != null) {
    try {
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Even the Etc zone is unavailable — keep the UTC default.
    }
  }
}

/// IANA `Etc/GMT` zones invert the sign of the offset: UTC+8 is `Etc/GMT-8`.
/// They are fixed-offset (no DST) — acceptable for a fallback that only
/// triggers when the device can't even name its own zone. Whole-hour
/// offsets only (the `Etc` set is hour-granular); a rare half-hour zone
/// returns null so the caller keeps the UTC default.
String? etcZoneNameForOffset(Duration offset) {
  if (offset.inMinutes % 60 != 0) return null;
  final hours = offset.inHours;
  return 'Etc/GMT${hours <= 0 ? '+' : '-'}${hours.abs()}';
}
