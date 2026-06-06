import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';
import 'pending_notification_intents.dart';

/// Default impl. `flutter_local_notifications` owns scheduling + iOS init;
/// `permission_handler` owns authorization on BOTH platforms (single code
/// path, and the only source that can report `permanentlyDenied` on iOS —
/// iOS maps an already-answered "Don't allow" to that state because it will
/// never re-prompt).
class LocalNotificationScheduler implements NotificationScheduler {
  final _plugin = fln.FlutterLocalNotificationsPlugin();
  final _responses = StreamController<NotificationActionEvent>.broadcast();
  bool _ready = false;

  @override
  Stream<NotificationActionEvent> get responses => _responses.stream;

  @override
  Future<void> init() async {
    if (_ready) return;
    // configureLocalTimeZone() (called first in main) already loads the db
    // AND points tz.local at the device zone. initializeTimeZones()
    // unconditionally resets tz.local back to UTC (timezone pkg env.dart
    // `_local = _UTC`), so calling it again here would clobber the real zone
    // and every reminder / calendar TZDateTime would then be built against
    // UTC. Only initialize when the db isn't loaded yet (e.g. tests, or a
    // path that reaches the scheduler before configureLocalTimeZone).
    if (!tz.timeZoneDatabase.isInitialized) {
      tzdata.initializeTimeZones();
    }
    // requestAlertPermission:false only stops the FLN plugin from
    // self-requesting during initialize(); permission_handler issues the
    // real UNUserNotificationCenter.requestAuthorization on iOS.
    final init = fln.InitializationSettings(
      android: const fln.AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: fln.DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        // iOS only surfaces action buttons for notifications whose
        // categoryIdentifier was registered here at init time, so every
        // kind that carries actions needs its category up front.
        notificationCategories: _iosCategories(),
      ),
    );
    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _ready = true;
  }

  void _onForegroundResponse(fln.NotificationResponse r) {
    _responses.add((payload: r.payload, actionId: r.actionId, id: r.id));
  }

  @override
  Future<NotificationActionEvent?> takeLaunchResponse() async {
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final r = details.notificationResponse;
    if (r == null) return null;
    return (payload: r.payload, actionId: r.actionId, id: r.id);
  }

  NotificationPermission _map(ph.PermissionStatus s) {
    if (s.isGranted || s.isLimited || s.isProvisional) {
      return NotificationPermission.granted;
    }
    if (s.isPermanentlyDenied || s.isRestricted) {
      return NotificationPermission.permanentlyDenied;
    }
    // .denied — pre-prompt on Android, and on iOS before the one-time ask.
    return NotificationPermission.denied;
  }

  @override
  Future<NotificationPermission> permissionStatus() async =>
      _map(await ph.Permission.notification.status);

  @override
  Future<NotificationPermission> requestPermission() async =>
      _map(await ph.Permission.notification.request());

  @override
  Future<bool> canScheduleExactAlarms() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();
    return android == null ||
        (await android.canScheduleExactNotifications() ?? false);
  }

  @override
  Future<bool> requestExactAlarmsPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();
    return android == null ||
        (await android.requestExactAlarmsPermission() ?? false);
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
    await init();
    final now = DateTime.now();
    if (at.isBefore(now)) {
      // One-shot diagnostic: scheduling in the past is a silent no-op
      // otherwise, which is exactly the kind of "reminder never fired"
      // footgun that the R8/Gson saga taught us to leave a breadcrumb for.
      debugPrint(
        '[notif] DROP id=$id: fire time $at is already '
        'in the past (now=$now). Nothing scheduled.',
      );
      return;
    }
    final scheduled = tz.TZDateTime.from(at, tz.local);
    // Weekly reminders (review nudge, backup nudge) use the plugin's
    // day-of-week match so FLN itself re-arms the next occurrence after each
    // fire — without this they delivered exactly once. Null = one-shot.
    final matchComponents = repeat == ScheduleRepeat.weekly
        ? fln.DateTimeComponents.dayOfWeekAndTime
        : null;
    // Reminders are a core feature → exact alarms. `exactAllowWhileIdle`
    // fires at the precise time AND survives Doze. With the requestable
    // SCHEDULE_EXACT_ALARM path, `canScheduleExactNotifications()` may be
    // false until the user enables exact alarms in system settings; when
    // that happens we degrade to inexact rather than throw — a late
    // reminder beats none. Never prompt here (see the
    // no-permission-request rationale below).
    final canExact = await canScheduleExactAlarms();
    final mode = canExact
        ? fln.AndroidScheduleMode.exactAllowWhileIdle
        : fln.AndroidScheduleMode.inexactAllowWhileIdle;
    // Deliberately NO permission request here. Prompting must be an explicit,
    // user-initiated action (the Settings tile / item-edit warning), never a
    // surprise dialog popped from a data write. Reminder delivery is a
    // best-effort side effect: a platform failure (denied permission, OEM
    // scheduler quirks, plugin exceptions) must never propagate into the use
    // case that triggered it, or it would abort the data operation. Against a
    // denied permission the OS simply drops the notification — no exception.
    // Log and swallow.
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _detailsFor(payload, channelId, channelName, timeoutAfter),
        androidScheduleMode: mode,
        matchDateTimeComponents: matchComponents,
        uiLocalNotificationDateInterpretation:
            fln.UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('[notif] schedule FAILED id=$id: $e\n$st');
    }
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    try {
      await _plugin.cancel(id);
    } catch (e, st) {
      debugPrint('Notification cancel failed for id $id: $e\n$st');
    }
  }

  @override
  Future<void> cancelAll() async {
    await init();
    try {
      await _plugin.cancelAll();
    } catch (e, st) {
      debugPrint('Notification cancelAll failed: $e\n$st');
    }
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    await init();
    try {
      final active = await _plugin.getActiveNotifications();
      // FLN gives us nullable ids (a system-summary notification on Android
      // can show up with no id we own); drop those — we can't cancel what
      // we didn't schedule.
      return [
        for (final n in active)
          if (n.id != null) (id: n.id!, payload: n.payload),
      ];
    } catch (e, st) {
      debugPrint('Notification getActiveNotifications failed: $e\n$st');
      return const [];
    }
  }
}

/// iOS notification id for a kind — the categoryIdentifier that ties a
/// scheduled notification to the action buttons registered at init.
String _iosCategoryId(NotificationKind kind) => 'cleartray.${kind.name}';

List<fln.DarwinNotificationCategory> _iosCategories() {
  final cats = <fln.DarwinNotificationCategory>[];
  for (final kind in NotificationKind.values) {
    final actions = actionsForKind(kind);
    if (actions.isEmpty) continue;
    cats.add(
      fln.DarwinNotificationCategory(
        _iosCategoryId(kind),
        actions: [
          for (final a in actions)
            fln.DarwinNotificationAction.plain(
              a.id,
              a.label,
              // Snooze is headless (no option); Done opens the app so
              // completion runs through the normal use case.
              options: a.foreground
                  ? const {fln.DarwinNotificationActionOption.foreground}
                  : const {},
            ),
        ],
      ),
    );
  }
  return cats;
}

/// Builds the platform notification details, attaching the action buttons
/// for the payload's kind. Shared by [LocalNotificationScheduler.schedule]
/// and the background Snooze handler so a snoozed notification keeps its
/// buttons. A null/undecodable payload yields a plain notification.
///
/// [timeoutAfter] sets Android's `Notification.Builder.setTimeoutAfter` —
/// the OS auto-cancels the delivered notification this long after it posts.
/// Used to retire stale early-warning kinds (Soon, Ready) the moment Due
/// fires. iOS has no equivalent property; the field is silently ignored
/// there and the foreground sweep covers it instead.
fln.NotificationDetails _detailsFor(
  String? payload,
  String channelId,
  String channelName,
  Duration? timeoutAfter,
) {
  final decoded = NotificationPayload.tryDecode(payload);
  final actions = decoded == null
      ? const <NotificationAction>[]
      : actionsForKind(decoded.kind);
  return fln.NotificationDetails(
    android: fln.AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Trayzero reminders for tasks and reviews',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      timeoutAfter: timeoutAfter?.inMilliseconds,
      actions: [
        for (final a in actions)
          fln.AndroidNotificationAction(
            a.id,
            a.label,
            // Mutation/snooze actions stay headless; only screen actions
            // (Start review / Back up now) open the app. Either way the
            // original notification clears once the button is tapped.
            showsUserInterface: a.foreground,
            cancelNotification: true,
          ),
      ],
    ),
    iOS: fln.DarwinNotificationDetails(
      categoryIdentifier:
          decoded == null ? null : _iosCategoryId(decoded.kind),
      // Group an item's Soon:/Due:/Ready: under one thread so iOS stacks
      // them as a single tray entry instead of separate banners. iOS can't
      // auto-expire a delivered Soon: when Due: fires (no timeoutAfter
      // equivalent), so during that overlap window the thread keeps the
      // clutter to one collapsed group; the foreground sweep
      // ([SweepStaleItemNotifications]) still clears the stale Soon: on the
      // next resume. Null itemId (standing reminders) → no grouping.
      threadIdentifier: decoded?.itemId,
      // Item deadlines are the textbook Time Sensitive case — user-set,
      // time-anchored, actionable now — so they break through Focus and
      // Sleep without per-app allow-listing. Standing nudges (weekly
      // review, backup) intentionally stay `active`: they're recurring
      // reminders, not deadlines, and Apple's HIG explicitly warns against
      // claiming Time Sensitive for those. Requires the
      // `com.apple.developer.usernotifications.time-sensitive` entitlement
      // in Runner.entitlements; the user can still revoke it per-app in
      // iOS Settings → Trayzero → Notifications.
      interruptionLevel: switch (decoded?.kind) {
        NotificationKind.due ||
        NotificationKind.soon ||
        NotificationKind.ready =>
          fln.InterruptionLevel.timeSensitive,
        NotificationKind.weeklyReview ||
        NotificationKind.backup ||
        null =>
          fln.InterruptionLevel.active,
      },
    ),
  );
}

/// Background-isolate handler for action taps that arrive while the app
/// is dead.
///
/// Runs in its own isolate with NOTHING wired up — no Riverpod, no
/// database. Two paths:
///
/// - Snooze ([RescheduleAt]) is self-contained: the payload carries its
///   own title/body, so we re-init a bare plugin and re-post the same
///   notification one day out.
/// - Mutation actions (Done / Move to Next Actions) can't run safely
///   without DI and DB, so we append the raw event to a journal file;
///   [DrainPendingNotificationIntents] replays it on the next launch.
///
/// [OpenScreen] decisions never land here — those actions have
/// `showsUserInterface: true`, which routes the tap to the foreground /
/// launch path instead.
///
/// Must stay top-level and `@pragma('vm:entry-point')` or release
/// tree-shaking drops the entry.
@pragma('vm:entry-point')
void notificationTapBackground(fln.NotificationResponse response) {
  final payload = NotificationPayload.tryDecode(response.payload);
  if (payload == null) return;
  final decision = decideNotificationResponse(
    payload: payload,
    actionId: response.actionId,
    now: DateTime.now(),
  );
  // Fire-and-forget: a background isolate may be killed the instant
  // this returns, so don't await past the durable write itself.
  switch (decision) {
    case RescheduleAt():
      unawaited(_rescheduleHeadless(response.id, decision));
    case CompleteItemDecision():
    case MoveToNextActionsDecision():
      unawaited(_journalHeadless(response));
    case OpenScreen():
      // Should not arrive here — foreground actions don't invoke this
      // callback. Treat as a no-op so a future flag change can't crash.
      return;
  }
}

Future<void> _journalHeadless(fln.NotificationResponse r) async {
  try {
    final store = await PendingNotificationIntents.defaultLocation();
    await store.append((
      payload: r.payload,
      actionId: r.actionId,
      id: r.id,
    ));
  } catch (e, st) {
    debugPrint('[notif] background journal FAILED id=${r.id}: $e\n$st');
  }
}

Future<void> _rescheduleHeadless(int? id, RescheduleAt decision) async {
  if (id == null) return;
  try {
    tzdata.initializeTimeZones();
    final plugin = fln.FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const fln.InitializationSettings(
        android: fln.AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: fln.DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await plugin.zonedSchedule(
      id,
      decision.payload.title,
      decision.payload.body,
      tz.TZDateTime.from(decision.at, tz.local),
      // A snoozed re-post is a fresh user-requested ping: no auto-dismiss
      // (the snooze action itself only exists on Due/Ready/standing kinds,
      // never on Soon, so there's no early-warning to retire here).
      _detailsFor(
        decision.payload.encode(),
        'cleartray_reminders',
        'Reminders',
        null,
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      payload: decision.payload.encode(),
    );
  } catch (e, st) {
    debugPrint('[notif] background snooze FAILED id=$id: $e\n$st');
  }
}
