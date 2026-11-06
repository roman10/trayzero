import 'dart:async';

import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/infrastructure/local_notification_scheduler.dart';
import 'package:cleartray/infrastructure/method_channel_app_icon_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

int argb(Map details) =>
    (details['colorAlpha'] as int) << 24 |
    (details['colorRed'] as int) << 16 |
    (details['colorGreen'] as int) << 8 |
    (details['colorBlue'] as int);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const iconChannel = MethodChannel('app.cleartray/app_icon');
  var selectedIcon = 'cyan';
  var headless = false;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final scheduled = <Map<dynamic, dynamic>>[];
  final pending = <Map<String, dynamic>>[];
  Completer<void>? posted;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    tz.initializeTimeZones();
    SharedPreferences.setMockInitialValues({
      'app_palette': 'green',
      androidNotificationIconPaletteKey: 'cyan',
    });
    selectedIcon = 'cyan';
    headless = false;
    messenger.setMockMethodCallHandler(iconChannel, (call) async {
      if (headless) throw MissingPluginException();
      expect(call.method, 'getState');
      return {'supported': true, 'icon': selectedIcon};
    });
    scheduled.clear();
    pending.clear();
    posted = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'pendingNotificationRequests') return pending;
      if (call.method == 'zonedSchedule') {
        scheduled.add(call.arguments as Map);
        posted?.complete();
        return null;
      }
      return true;
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(iconChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'scheduling follows OS icon selection independently of app color',
    () async {
      // The foreground must prefer the OS selection over a stale cache.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(androidNotificationIconPaletteKey, 'amber');
      final scheduler = LocalNotificationScheduler();
      final at = DateTime.now().add(const Duration(days: 2));
      final payload = const NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'item',
        title: 'Due',
        body: 'Task',
      ).encode();
      await scheduler.schedule(
        id: 1,
        at: at,
        title: 'Due',
        body: 'Task',
        payload: payload,
        timeoutAfter: const Duration(minutes: 1),
      );
      final details = scheduled.single['platformSpecifics'] as Map;
      expect(details['icon'], 'ic_stat_trayzero');
      expect(details['largeIcon'], isNull);
      expect(argb(details), AppPalette.cyan.seedArgb);
      expect(details['timeoutAfter'], 60000);
      expect(details['actions'], isNotEmpty);
      expect(scheduled.single['payload'], payload);
      expect(
        scheduled.single['scheduledDateTime'],
        contains(at.year.toString()),
      );

      await prefs.setString('app_palette', 'violet');
      await scheduler.schedule(id: 2, at: at, title: 'Due', body: 'Task');
      expect(
        argb(scheduled.last['platformSpecifics'] as Map),
        AppPalette.cyan.seedArgb,
      );
      selectedIcon = 'rose';
      await scheduler.schedule(id: 3, at: at, title: 'Due', body: 'Task');
      expect(
        argb(scheduled.last['platformSpecifics'] as Map),
        AppPalette.rose.seedArgb,
      );
      expect(prefs.getString(androidNotificationIconPaletteKey), 'rose');
    },
  );

  test(
    'headless snooze uses confirmed icon fallback and preserves identity and actions',
    () async {
      final payload = const NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'item',
        title: 'Due',
        body: 'Task',
      ).encode();
      headless = true;
      posted = Completer<void>();
      notificationTapBackground(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          id: 42,
          actionId: 'snooze',
          payload: payload,
        ),
      );
      await posted!.future.timeout(const Duration(seconds: 5));
      final details = scheduled.single['platformSpecifics'] as Map;
      expect(details['icon'], 'ic_stat_trayzero');
      expect(details['largeIcon'], isNull);
      expect(argb(details), AppPalette.cyan.seedArgb);
      expect(details['actions'], isNotEmpty);
      expect(scheduled.single['id'], 42);
      final snoozed = NotificationPayload.tryDecode(
        scheduled.single['payload'] as String?,
      )!;
      final original = NotificationPayload.tryDecode(payload)!;
      expect(snoozed.kind, original.kind);
      expect(snoozed.itemId, original.itemId);
      expect(snoozed.title, original.title);
      expect(snoozed.body, original.body);
      expect(snoozed.snoozedUntil!.isAfter(DateTime.now()), isTrue);
    },
  );
  test(
    'pending OS requests preserve Snooze metadata for startup healing',
    () async {
      final payload = NotificationPayload(
        kind: NotificationKind.due,
        itemId: 'snoozed',
        title: 'Due',
        body: '',
        snoozedUntil: DateTime.now().add(const Duration(days: 1)),
      ).encode();
      pending.add({'id': 42, 'title': 'Due', 'body': '', 'payload': payload});
      expect(await LocalNotificationScheduler().getPendingNotifications(), [
        (id: 42, payload: payload),
      ]);
    },
  );
  for (final fallback in <String?>[null, 'unknown', 'amber']) {
    test('headless icon fallback $fallback safely uses amber', () async {
      headless = true;
      SharedPreferences.setMockInitialValues({
        'app_palette': 'green',
        androidNotificationIconPaletteKey: ?fallback,
      });
      await LocalNotificationScheduler().schedule(
        id: 9,
        at: DateTime.now().add(const Duration(days: 1)),
        title: 'Due',
        body: 'Task',
      );
      expect(
        argb(scheduled.single['platformSpecifics'] as Map),
        AppPalette.amber.seedArgb,
      );
    });
  }
}
