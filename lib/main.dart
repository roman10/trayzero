import 'dart:async';

import 'core/calendar_connection.dart';
import 'infrastructure/shared_preferences_calendar_connection.dart';
import 'application/calendar_connection_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_links.dart';
import 'app/locale_resolution.dart';
import 'application/drain_pending_notification_intents.dart';
import 'application/automatic_folder_backup.dart';
import 'application/handle_notification_response.dart';
import 'application/providers.dart';
import 'application/today_widget_snapshot.dart';
import 'app/router.dart';
import 'core/app_review.dart';
import 'core/appearance_preferences.dart';
import 'core/clock.dart';
import 'core/folder_backup.dart';
import 'core/home_widget_bridge.dart';
import 'core/id_generator.dart';
import 'core/notification_intent.dart';
import 'core/notification_scheduler.dart';
import 'data/seed.dart';
import 'l10n/gen/app_localizations.dart';
import 'features/settings/settings_controller.dart';
import 'infrastructure/billing_providers.dart';
import 'infrastructure/pending_notification_intents.dart';
import 'infrastructure/providers.dart';
import 'infrastructure/shared_preferences_appearance_store.dart';
import 'infrastructure/shared_preferences_folder_backup.dart';
import 'infrastructure/shared_preferences_review_prompt_store.dart';
import 'infrastructure/time_zone.dart';

// Sentry DSN — pass via `--dart-define=SENTRY_DSN=...`. Empty means disabled.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

// App-lifetime handle to the resume listener. `WidgetsBinding` already
// keeps a strong ref via `addObserver` so this isn't needed for
// retention, but we keep it parallel to the `_listener` field in
// `NotificationPermissionRefresher` and so a future change can call
// `.dispose()` on it without hunting through closures.
// ignore: unused_element
AppLifecycleListener? _lifecycleListener;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use the platform's supported orientations. A portrait-only runtime lock
  // overrides the iOS manifest and prevents landscape on the outer display.

  final prefs = await SharedPreferences.getInstance();
  final crashReportingEnabled =
      prefs.getBool('crash_reporting_enabled') ?? false;
  final sentryActive = _sentryDsn.isNotEmpty && crashReportingEnabled;

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      calendarConnectionPreferencesProvider.overrideWithValue(
        SharedPreferencesCalendarConnection(prefs),
      ),
      folderBackupPreferencesProvider.overrideWithValue(
        SharedPreferencesFolderBackup(prefs),
      ),
      appearancePreferencesStoreProvider.overrideWithValue(
        SharedPreferencesAppearanceStore(prefs),
      ),
      reviewPromptStoreProvider.overrideWithValue(
        SharedPreferencesReviewPromptStore(prefs),
      ),
      ...defaultInfrastructureOverrides(),
    ],
  );

  // Count this launch for the store-rating prompt policy (ADR 0007). Best
  // effort: a preference write failure must never block launch.
  try {
    await container.read(recordAppSessionProvider).call();
  } catch (e) {
    debugPrint('[review-prompt] session record FAILED: $e');
  }

  // Bootstrap one-time defaults (idempotent). Resolve the UI locale the same
  // way MaterialApp will, and load its strings, so seeded context names match
  // the language the app renders in.
  final seedLocale = container.read(localeOverrideProvider) ??
      resolveAppLocale(WidgetsBinding.instance.platformDispatcher.locales);
  final seedL10n = await AppLocalizations.delegate.load(seedLocale);
  await seedDefaultContextsIfEmpty(
    container.read(contextRepositoryProvider),
    container.read(idGeneratorProvider),
    phoneLabel: seedL10n.seedContextPhone,
    computerLabel: seedL10n.seedContextComputer,
    errandsLabel: seedL10n.seedContextErrands,
    homeLabel: seedL10n.seedContextHome,
    officeLabel: seedL10n.seedContextOffice,
    anywhereLabel: seedL10n.seedContextAnywhere,
    waitingLabel: seedL10n.seedContextWaiting,
  );

  // Point tz.local at the real device timezone before anything builds a
  // TZDateTime (scheduled notifications, calendar mirror-out).
  await configureLocalTimeZone();

  // Initialise notifications + widget bridge (no permission prompt yet —
  // that happens on first scheduled reminder).
  final notifications = container.read(notificationSchedulerProvider);
  final homeWidget = container.read(homeWidgetBridgeProvider);
  await notifications.init();
  await homeWidget.init();

  // Initialise billing (RevenueCat). No-op unless a platform key is supplied
  // via --dart-define; guarded so an unreachable store never blocks launch.
  try {
    await container.read(billingGatewayProvider).configure();
  } catch (e, st) {
    debugPrint('[billing] configure FAILED: $e\n$st');
  }

  // Re-arm the standing reminders (weekly review / backup) whose Settings
  // toggle is enabled. Heals the default-ON nudge that was never scheduled
  // and any pending alarms an OEM force-stop wiped; idempotent on fixed ids.
  // Guarded: reminder delivery is best-effort — an OEM scheduler/permission
  // quirk must never keep the app from launching.
  try {
    await container.read(rearmStandingRemindersProvider).call();
  } catch (e, st) {
    debugPrint('[notif] startup re-arm FAILED: $e\n$st');
  }

  // Finish deletes whose Undo window was cut short by the app being killed:
  // soft-deleted (trashed) rows are invisible everywhere, so this only frees
  // their rows and attachment files. Best-effort and off the critical path.
  unawaited(() async {
    try {
      await container.read(purgeTrashProvider).call();
    } catch (e, st) {
      debugPrint('[trash] startup purge FAILED: $e\n$st');
    }
  }());

  // Mirror inbox count to any installed home-screen widget.
  container.listen<AsyncValue<int>>(
    inboxCountProvider,
    (prev, next) {
      final n = next.valueOrNull;
      if (n != null) {
        homeWidget.publishInboxCount(n);
      }
    },
    fireImmediately: true,
  );

  // Mirror Today's focused Items to the Today widget (ADR 0009).
  container.listen<TodayWidgetSnapshot?>(
    todayWidgetSnapshotProvider,
    (prev, next) {
      if (next != null) unawaited(homeWidget.publishToday(next));
    },
    fireImmediately: true,
  );

  // Route links from widgets, the Quick Settings tile, launcher shortcuts,
  // and App Intents (cleartray://capture, cleartray://today, …) once the
  // router is alive. Unknown links open the Inbox.
  homeWidget.widgetTaps.listen((uri) => openAppLink(container, uri));

  // Apply widget checkbox taps and Siri captures queued outside the app:
  // at startup, on resume (below), and when native code signals new work
  // while the app is alive.
  Future<void> drainExternalQueue() async {
    try {
      await container.read(drainExternalQueueProvider).call();
    } catch (e, st) {
      debugPrint('[widget] external queue drain FAILED: $e\n$st');
    }
  }
  homeWidget.queueChanged.listen((_) => unawaited(drainExternalQueue()));
  unawaited(drainExternalQueue());

  // Notification taps / action buttons. Body taps and screen actions
  // (Start review / Back up now) arrive here as foreground responses
  // and route. Snooze re-arms in place. Done / Move-to-Next-Actions
  // taps that fired while the app was dead are journaled by the
  // background isolate (see LocalNotificationScheduler) and replayed
  // by the drain below; ones that arrive while the app is alive land
  // on this stream and run through the use case immediately.
  final notificationHandler = HandleNotificationResponse(
    scheduler: notifications,
    completeItem: container.read(completeItemProvider),
    moveToNextActions: container.read(moveItemToNextActionsProvider),
    clock: container.read(clockProvider),
    navigate: (location) =>
        openDeepLink(container.read(routerProvider), location),
  );
  notifications.responses.listen((e) {
    unawaited(notificationHandler.call(e));
  });

  // Replay any Done / Move-to-Next-Actions taps that fired while the
  // app was dead or backgrounded. The background isolate (see
  // notificationTapBackground) journaled them; here we drain through
  // the same use case an in-app tap would hit. Failures stay
  // best-effort — a notification mutation must never keep the app
  // from launching.
  Future<void> drainPendingIntents() async {
    try {
      final store = await PendingNotificationIntents.defaultLocation();
      await DrainPendingNotificationIntents(
        store: store,
        handler: notificationHandler,
      ).call();
    } catch (e, st) {
      debugPrint('[notif] pending-intent drain FAILED: $e\n$st');
    }
  }
  // Initial drain — unawaited so first frame isn't blocked by file IO
  // + N completions on a slow disk.
  unawaited(drainPendingIntents());
  // Cancel any "Soon:" / "Ready:" notification that's been outlived by
  // its item — the iOS counterpart of Android's `timeoutAfter`-based
  // auto-dismiss (see [SweepStaleItemNotifications]). Best-effort and
  // unawaited; a stale banner is annoying but never blocks UI.
  Future<void> sweepStaleNotifications() async {
    try {
      await container.read(sweepStaleItemNotificationsProvider).call();
    } catch (e, st) {
      debugPrint('[notif] stale-notification sweep FAILED: $e\n$st');
    }
  }
  unawaited(sweepStaleNotifications());
  // The headless ActionBroadcastReceiver writes the journal in its own
  // isolate, so a tap that fires while THIS process is alive
  // (foreground or backgrounded-but-not-killed) doesn't reach the
  // main isolate at all — it can only be picked up on the next
  // resume. Without this listener, Done taps would silently sit in
  // the journal until the user fully killed and relaunched the app.
  // The same resume is also where the stale-notification sweep
  // catches up on iOS: the user is about to look at the tray, so
  // "best-effort eventually" is fine.
  final folderBackups = container.read(automaticFolderBackupProvider.notifier);
  unawaited(folderBackups.resume());
  final calendars = container.read(calendarConnectionProvider.notifier);
  unawaited(calendars.resume());
  _lifecycleListener = AppLifecycleListener(
    onPause: () {
      unawaited(folderBackups.pause());
      calendars.background();
    },
    onResume: () {
      unawaited(calendars.resume());
      unawaited(folderBackups.resume());
      unawaited(drainPendingIntents());
      unawaited(sweepStaleNotifications());
      unawaited(drainExternalQueue());
      unawaited(homeWidget.checkPendingLaunch());
    },
  );

  // Cold-launched by tapping a notification body / screen action from
  // a terminated state: replay it once. Mutation actions never get
  // here — they have `showsUserInterface: false`, so they were
  // journaled above instead. Navigation must wait for the first frame
  // so the router exists.
  final launch = await notifications.takeLaunchResponse();
  if (launch != null) {
    final payload = NotificationPayload.tryDecode(launch.payload);
    final decision = payload == null
        ? null
        : decideNotificationResponse(
            payload: payload,
            actionId: launch.actionId,
            now: DateTime.now(),
          );
    if (decision is OpenScreen) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => openDeepLink(container.read(routerProvider), decision.location),
      );
    } else if (decision != null) {
      unawaited(notificationHandler.call(launch));
    }
  }

  // Best-effort, off the critical path: re-arm every active dated item's
  // reminder so a restored backup / Google Tasks import and any OEM-wiped
  // alarms aren't silent until each item is hand-edited. Unawaited — these
  // alarms fire days out; first frame must not wait on N platform calls.
  unawaited(() async {
    try {
      await container.read(rearmItemRemindersProvider).call();
    } catch (e, st) {
      debugPrint('[notif] startup item re-arm FAILED: $e\n$st');
    }
  }());

  final app = UncontrolledProviderScope(
    container: container,
    child: const TrayzeroApp(),
  );

  if (sentryActive) {
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        // Conservative defaults — no PII, no screenshots.
        options.sendDefaultPii = false;
        options.tracesSampleRate = 0.1;
        options.attachScreenshot = false;
      },
      appRunner: () => runApp(SentryWidget(child: app)),
    );
  } else {
    runApp(app);
  }
}
