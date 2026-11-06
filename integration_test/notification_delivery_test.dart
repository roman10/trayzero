// On-device regression test for the Android reminder pipeline.
//
// WHY THIS EXISTS
// ---------------
// Reminders "didn't work on Android" because the RELEASE build (R8 enabled by
// Flutter's Gradle plugin, used by `flutter build appbundle --release` for the
// internal-testing track) stripped the Gson `Signature` attribute that
// flutter_local_notifications relies on. Every zonedSchedule / cancel /
// pendingNotificationRequests / boot-rearm then threw:
//
//     java.lang.RuntimeException: Missing type parameter.
//
// This is INVISIBLE to `flutter run` (debug) and to widget tests — neither
// runs R8 — which is why prior debugging attempts kept "seeing it work".
//
// HOW TO RUN SO IT ACTUALLY GUARDS THE BUG
// ----------------------------------------
//   Run bash tool/ci_android_native.sh on a disposable Android emulator. flutter test --release cannot attach to a release VM service.
//
// Release instrumentation is mandatory to exercise R8. Default `flutter test` builds the
// `.debug` variant (applicationId app.cleartray.debug) which co-installs
// safely alongside a Play `app.cleartray`; a `--release` run is signed
// with the release key (android/key.properties), a DIFFERENT signature than
// Play App Signing, so it cannot update a Play-signed install — uninstall the
// Play build first (wipes its data) or use a spare device.
//
// The "real delivery" test needs POST_NOTIFICATIONS. Grant it to whichever id
// the run actually installs — `app.cleartray.debug` for plain `flutter
// test`, `app.cleartray` for `--release`:
//
//   adb shell pm grant app.cleartray.debug android.permission.POST_NOTIFICATIONS
//
// CAVEAT: some OEM ROMs (confirmed: OPPO/ColorOS, Android 16) globally block
// `adb pm grant` (SecurityException: no GRANT_RUNTIME_PERMISSIONS) and ignore
// `appops set ... POST_NOTIFICATION`. There, grant it by hand in Settings →
// Apps → (Trayzero Debug) → Notifications, or the probe self-skips.
//
// In debug/profile the round-trip and delivery checks still validate the
// wiring, but the R8/Gson regression is NOT being exercised — the test prints
// a loud banner saying so.

import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/infrastructure/local_notification_scheduler.dart';
import 'package:cleartray/infrastructure/time_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final raw = FlutterLocalNotificationsPlugin();
  late LocalNotificationScheduler scheduler;
  const strict = bool.fromEnvironment('CI_NATIVE_TEST');

  setUpAll(() async {
    if (strict) {
      expect(
        kReleaseMode,
        isTrue,
        reason: 'Native Android CI must exercise R8.',
      );
    }
    if (!kReleaseMode) {
      debugPrint(
        '\n==================================================================\n'
        '  ⚠  NOT a --release build: R8 is OFF, so the flutter_local_\n'
        '     notifications "Missing type parameter" regression is NOT\n'
        '     being exercised. Use the release instrumentation runner in\n'
        '       tool/ci_android_native.sh\n'
        '==================================================================\n',
      );
    }
    await configureLocalTimeZone();
    scheduler = LocalNotificationScheduler();
    await scheduler.init();
    // Clean slate. NOTE: FLN's cancelAll DOES call loadScheduledNotifications
    // (FlutterLocalNotificationsPlugin.cancelAllNotifications), so under the
    // R8/Gson bug this deserialises too — but LocalNotificationScheduler.
    // cancelAll() swallows platform errors, so setUpAll never aborts the
    // suite. On a fresh install the store is empty (no fromJson) anyway. The
    // real R8 guard is the direct raw.pendingNotificationRequests() below,
    // which is NOT swallowed.
    await scheduler.cancelAll();
  });

  testWidgets('diagnostics: build mode / permission / tz / exact alarms', (
    tester,
  ) async {
    final perm = await scheduler.permissionStatus();
    final canExact = await scheduler.canScheduleExactAlarms();
    debugPrint(
      '[probe] releaseMode=$kReleaseMode  permission=$perm  '
      'canScheduleExactAlarms=$canExact',
    );
    // canExact must be true on Android 13+ ONLY because the manifest declares
    // USE_EXACT_ALARM. If this is false on a modern device, the exact-alarm
    // manifest regression is back and reminders fall to the 1-hour inexact
    // window (dumpsys windowLength=3600000).
    expect(perm, isA<NotificationPermission>());
    expect(canExact, isA<bool>());
    if (strict) {
      expect(perm, NotificationPermission.granted);
      expect(canExact, isTrue, reason: 'CI must verify exact-alarm delivery.');
    }
  });

  testWidgets(
    'R8/Gson round-trip: schedule twice, then read back pending requests',
    (tester) async {
      // The "Missing type parameter" crash only triggers once a persisted
      // JSON blob exists — i.e. on the SECOND schedule and on every
      // pendingNotificationRequests()/cancel() afterwards. One schedule is
      // not enough to reproduce it; two is.
      final base = DateTime.now();
      await scheduler.schedule(
        id: 991001,
        at: base.add(const Duration(minutes: 10)),
        title: 'Round-trip 1',
        body: 'first',
      );
      await scheduler.schedule(
        id: 991002,
        at: base.add(const Duration(minutes: 11)),
        title: 'Round-trip 2',
        body: 'second',
      );

      // Called directly (not via the production wrapper, which deliberately
      // swallows platform errors). Under the R8/Gson bug this throws
      // PlatformException(... "Missing type parameter").
      List<PendingNotificationRequest> pending;
      try {
        pending = await raw.pendingNotificationRequests();
      } on PlatformException catch (e) {
        fail(
          'pendingNotificationRequests() threw ${e.code}: ${e.message}\n'
          'This is the flutter_local_notifications R8/Gson "Missing type '
          'parameter" crash. android/app/proguard-rules.pro is missing or '
          'not being applied to this build.',
        );
      }

      final ids = pending.map((p) => p.id).toSet();
      expect(
        ids,
        containsAll(<int>[991001, 991002]),
        reason:
            'Scheduled ids did not survive the Gson round-trip — R8 stripped '
            'the Signature attribute (proguard-rules.pro missing/ineffective).',
      );

      // cancel() also routes through loadScheduledNotifications() → same bug.
      await scheduler.cancel(991001);
      await scheduler.cancel(991002);
      final after = await raw.pendingNotificationRequests();
      expect(
        after.map((p) => p.id),
        isNot(anyElement(isIn(<int>[991001, 991002]))),
        reason: 'cancel() did not remove the persisted entries.',
      );
    },
  );

  testWidgets('real delivery: a near-future reminder actually posts', (
    tester,
  ) async {
    final perm = await scheduler.permissionStatus();
    if (perm != NotificationPermission.granted) {
      if (strict) fail('Native CI did not grant POST_NOTIFICATIONS.');
      markTestSkipped(
        'POST_NOTIFICATIONS not granted — pre-grant with: adb shell pm grant '
        '<appId> android.permission.POST_NOTIFICATIONS, then re-run.',
      );
      return;
    }
    final android = raw
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      if (strict) fail('Android delivery probe requires an Android device.');
      markTestSkipped(
        'Not an Android device — delivery probe is Android-only.',
      );
      return;
    }

    const id = 991010;
    await scheduler.cancel(id);
    await scheduler.schedule(
      id: id,
      at: DateTime.now().add(const Duration(seconds: 8)),
      title: 'Delivery probe',
      body: 'If you can read this in the shade, reminders work.',
    );

    // Exact alarms land in ~8s. Allow generous slack: a failure here AFTER a
    // green round-trip points at exact-alarm/USE_EXACT_ALARM or OEM battery
    // management, not the Gson bug.
    var delivered = false;
    final deadline = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final active = await android.getActiveNotifications();
      if (active.any((n) => n.id == id)) {
        delivered = true;
        break;
      }
    }
    await scheduler.cancel(id);
    expect(
      delivered,
      isTrue,
      reason:
          'Scheduled notification never reached the shade within 90s. '
          'Round-trip passing + this failing ⇒ exact-alarm permission '
          '(USE_EXACT_ALARM) or OEM force-stop/battery management.',
    );
  });
}
