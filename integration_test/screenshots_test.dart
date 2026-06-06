// Play Store screenshot harness.
//
// Boots a minimal version of the Trayzero UI (router + theme — without the
// share-intent / notification-refresher wrappers that would hit platform
// channels in a profile build), seeds realistic GTD data, drives the router
// to each storefront-worthy screen, and asks the integration_test binding to
// capture a PNG of the surface at each stop.
//
// Run via the matching driver so the PNG bytes actually land on disk:
//
//   cd mobile
//   flutter drive \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --profile \
//     -d <emulator-id>
//
// Recommended emulator: Android Studio's "Medium Phone API 36.1" profile
// (1080×2400, 9:20). The driver center-crops every capture down to Play's
// required 9:16 (1080×1920); see `test_driver/screenshot_driver.dart`.
// Output PNGs land in `docs/play-store-listing/screenshots/`.
//
// This test does NOT exercise any production logic — it's display-only.
// Provider wiring uses an in-memory database + fakes for every infrastructure
// port, so it won't touch the real reminder schedule, calendar, or
// SharedPreferences on the host device.

import 'dart:async';

import 'package:cleartray/app/router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/home_widget_bridge.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/core/system_settings.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/providers.dart';
import 'package:cleartray/data/seed.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/settings/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture Play Store screenshots', (tester) async {
    // --- Wiring ----------------------------------------------------------
    SharedPreferences.setMockInitialValues({
      // Skip the onboarding flow — we want to land straight on Inbox.
      // Key must match `_kOnboardingComplete` in settings_controller.dart.
      'onboarding_complete_v1': true,
      // Off so the privacy section of Settings shows the default-off state.
      'crash_reporting_enabled': false,
      // Standing reminders ON so the Settings screen surface includes them.
      'weekly_review_reminder_enabled': true,
      'backup_reminder_enabled': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final ids = _CounterIdGenerator();
    addTearDown(db.close);

    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
      clockProvider.overrideWithValue(const SystemClock()),
      idGeneratorProvider.overrideWithValue(ids),
      notificationSchedulerProvider
          .overrideWithValue(_NullNotificationScheduler()),
      homeWidgetBridgeProvider.overrideWithValue(_NullHomeWidgetBridge()),
      calendarGatewayProvider.overrideWithValue(_NullCalendarGateway()),
      systemSettingsProvider.overrideWithValue(_NullSystemSettings()),
    ]);
    addTearDown(container.dispose);

    // Seed the standard 7 GTD contexts and then the showcase data.
    await seedDefaultContextsIfEmpty(
      container.read(contextRepositoryProvider),
      container.read(idGeneratorProvider),
    );
    await _seedShowcaseData(container);

    // --- Boot ------------------------------------------------------------
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _ScreenshotApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Some Android emulator builds need this before takeScreenshot can
    // actually grab the GPU surface. Cheap to call even when not needed.
    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    final router = container.read(routerProvider);

    Future<void> settle() async {
      // pumpAndSettle finishes once frames are scheduled, but the Drift
      // streams powering each screen emit on a separate microtask cycle —
      // tester.pump(timeAmount) gives them a chance to land and rebuild.
      // Mirrors the pattern in test/widget/inbox_screen_test.dart.
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    }

    // 01 — Inbox: capture-zero flow visible.
    router.go('/inbox');
    await settle();
    await binding.takeScreenshot('01-inbox');

    // 02 — Engage / Do: context + energy + time filters.
    router.go('/do');
    await settle();
    await binding.takeScreenshot('02-engage');

    // 03 — Projects: outcomes + statuses.
    router.go('/projects');
    await settle();
    await binding.takeScreenshot('03-projects');

    // 04 — Project detail: outcome, next actions, waiting-for.
    final showcaseProjectId =
        container.read(_showcaseProjectIdProvider);
    if (showcaseProjectId != null) {
      unawaited(router.push('/project/$showcaseProjectId'));
      await settle();
      await binding.takeScreenshot('04-project-detail');
      router.pop();
      await settle();
    }

    // 05 — Process inbox: the card-stack decision tree.
    unawaited(router.push('/process'));
    await settle();
    await binding.takeScreenshot('05-process');
    router.pop();
    await settle();

    // 06 — Review: weekly review wizard entry + buckets.
    router.go('/review');
    await settle();
    await binding.takeScreenshot('06-review');

    // 07 — Capture sheet.
    unawaited(router.push('/capture'));
    await settle();
    await binding.takeScreenshot('07-capture');
    router.pop();
    await settle();

    // 08 — Settings: GTD primer + backup + privacy + theme.
    router.go('/settings');
    await settle();
    await binding.takeScreenshot('08-settings');
  });
}

// ---------------------------------------------------------------------------
// Minimal app shell — same router + theme as TrayzeroApp, but no
// ShareIntentListener / NotificationPermissionRefresher (those reach into
// platform channels that aren't wired in a screenshot run).
// ---------------------------------------------------------------------------

class _ScreenshotApp extends ConsumerWidget {
  const _ScreenshotApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

// ---------------------------------------------------------------------------
// Showcase data. Dates are relative to the real clock so labels read
// "Today / Tomorrow / In 3 days" no matter when the harness is run.
// ---------------------------------------------------------------------------

/// Holds the id of the showcase project we want to deep-link into (#04).
/// Populated by [_seedShowcaseData].
final _showcaseProjectIdProvider = StateProvider<String?>((_) => null);

Future<void> _seedShowcaseData(ProviderContainer container) async {
  final items = container.read(itemRepositoryProvider);
  final projects = container.read(projectRepositoryProvider);
  final ctxs = await container.read(contextRepositoryProvider).all();
  final ids = container.read(idGeneratorProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 17);
  final tomorrowAt9 = DateTime(now.year, now.month, now.day + 1, 9);
  final inThreeDays = DateTime(now.year, now.month, now.day + 3, 14);

  String ctxId(String name) =>
      ctxs.firstWhere((c) => c.name == name, orElse: () => ctxs.first).id;

  // --- Inbox -----------------------------------------------------------
  final inbox = [
    'Birthday gift idea for Mira',
    'Insurance renewal — compare 3 quotes',
    "Article: 'Deep work in the AI era'",
    'Find a dentist with weekend hours',
    'Replace bathroom light bulb',
    'Reach out to old mentor about coffee',
  ];
  for (var i = 0; i < inbox.length; i++) {
    final ts = now.subtract(Duration(hours: i));
    await items.upsert(Item(
      id: ids.newId(),
      title: inbox[i],
      status: ItemStatus.inbox,
      createdAt: ts,
      updatedAt: ts,
    ));
  }

  // --- Projects --------------------------------------------------------
  final anniversaryProjectId = ids.newId();
  await projects.upsert(Project(
    id: anniversaryProjectId,
    title: "Plan parents' 40th anniversary trip",
    outcome:
        'Surprise weekend booked, gifts wrapped, siblings briefed by month-end.',
    status: ProjectStatus.active,
    createdAt: now.subtract(const Duration(days: 5)),
    updatedAt: now,
  ));
  container.read(_showcaseProjectIdProvider.notifier).state =
      anniversaryProjectId;

  await items.upsert(Item(
    id: ids.newId(),
    title: 'Email travel agent for resort options',
    status: ItemStatus.nextAction,
    projectId: anniversaryProjectId,
    contextId: ctxId('@computer'),
    energy: Energy.low,
    timeEstimateMinutes: 15,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Pick a weekend with siblings (text group)',
    status: ItemStatus.nextAction,
    projectId: anniversaryProjectId,
    contextId: ctxId('@phone'),
    energy: Energy.low,
    timeEstimateMinutes: 5,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Mum to send passport scans',
    status: ItemStatus.waiting,
    projectId: anniversaryProjectId,
    waitingOn: 'Mum',
    createdAt: now.subtract(const Duration(days: 3)),
    updatedAt: now.subtract(const Duration(days: 3)),
  ));

  final okrProjectId = ids.newId();
  await projects.upsert(Project(
    id: okrProjectId,
    title: 'Q3 OKR review draft',
    outcome: 'Three key results, two-page brief, circulated by Friday.',
    status: ProjectStatus.active,
    createdAt: now.subtract(const Duration(days: 2)),
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Outline the three key results',
    status: ItemStatus.nextAction,
    projectId: okrProjectId,
    contextId: ctxId('@computer'),
    energy: Energy.high,
    timeEstimateMinutes: 30,
    dueAt: today,
    createdAt: now,
    updatedAt: now,
  ));

  final marathonProjectId = ids.newId();
  await projects.upsert(Project(
    id: marathonProjectId,
    title: 'Run a half marathon in October',
    outcome: '21 km finished without injury at race pace.',
    status: ProjectStatus.active,
    createdAt: now.subtract(const Duration(days: 14)),
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Book Saturday long run on calendar',
    status: ItemStatus.nextAction,
    projectId: marathonProjectId,
    contextId: ctxId('@anywhere'),
    energy: Energy.low,
    timeEstimateMinutes: 5,
    createdAt: now,
    updatedAt: now,
  ));

  await projects.upsert(Project(
    id: ids.newId(),
    title: 'Refactor the auth module',
    outcome: 'Token storage migrated off Gson, mapped to compliance review.',
    status: ProjectStatus.onHold,
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now,
  ));
  await projects.upsert(Project(
    id: ids.newId(),
    title: 'Learn enough Korean for the Seoul trip',
    outcome: 'Read a menu and order coffee without falling back to English.',
    status: ProjectStatus.someday,
    createdAt: now.subtract(const Duration(days: 60)),
    updatedAt: now,
  ));

  // --- Standalone Next Actions ----------------------------------------
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Call Mum',
    status: ItemStatus.nextAction,
    contextId: ctxId('@phone'),
    energy: Energy.low,
    timeEstimateMinutes: 10,
    dueAt: today,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Submit Q2 expense report',
    status: ItemStatus.nextAction,
    contextId: ctxId('@computer'),
    energy: Energy.low,
    timeEstimateMinutes: 15,
    dueAt: tomorrowAt9,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Pick up dry cleaning',
    status: ItemStatus.nextAction,
    contextId: ctxId('@errands'),
    energy: Energy.low,
    timeEstimateMinutes: 10,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Update résumé with last role',
    status: ItemStatus.nextAction,
    contextId: ctxId('@computer'),
    energy: Energy.medium,
    timeEstimateMinutes: 30,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Review pull request #142',
    status: ItemStatus.nextAction,
    contextId: ctxId('@computer'),
    energy: Energy.high,
    timeEstimateMinutes: 30,
    dueAt: inThreeDays,
    createdAt: now,
    updatedAt: now,
  ));

  // --- Waiting For (standalone) ---------------------------------------
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Reply from landlord re: lease renewal terms',
    status: ItemStatus.waiting,
    waitingOn: 'Landlord',
    createdAt: now.subtract(const Duration(days: 4)),
    updatedAt: now.subtract(const Duration(days: 4)),
  ));

  // --- Someday / Maybe ------------------------------------------------
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Take a sabbatical month',
    status: ItemStatus.someday,
    createdAt: now,
    updatedAt: now,
  ));
  await items.upsert(Item(
    id: ids.newId(),
    title: 'Try sourdough baking',
    status: ItemStatus.someday,
    createdAt: now,
    updatedAt: now,
  ));

  // --- Reference -------------------------------------------------------
  await items.upsert(Item(
    id: ids.newId(),
    title: 'WiFi backup codes',
    notes: 'Stored in 1Password — vault: Personal/Network.',
    status: ItemStatus.reference,
    createdAt: now,
    updatedAt: now,
  ));
}

// ---------------------------------------------------------------------------
// Minimal no-op fakes for every infrastructure port. These mirror just
// enough of the interfaces to keep providers happy — the screenshot test
// never exercises their behaviour.
// ---------------------------------------------------------------------------

class _NullHomeWidgetBridge implements HomeWidgetBridge {
  @override
  Future<void> init() async {}
  @override
  Future<void> publishInboxCount(int count) async {}
  @override
  Stream<Uri> get widgetTaps => const Stream.empty();
}

class _CounterIdGenerator extends IdGenerator {
  int _n = 0;
  @override
  String newId() => 'seed-${++_n}';
}

class _NullNotificationScheduler implements NotificationScheduler {
  final _responses = StreamController<NotificationActionEvent>.broadcast();

  @override
  Future<void> init() async {}

  @override
  Future<NotificationPermission> permissionStatus() async =>
      NotificationPermission.granted;
  @override
  Future<NotificationPermission> requestPermission() async =>
      NotificationPermission.granted;

  @override
  Future<bool> canScheduleExactAlarms() async => true;
  @override
  Future<bool> requestExactAlarmsPermission() async => true;

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
  }) async {}

  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => const [];
  @override
  Future<NotificationActionEvent?> takeLaunchResponse() async => null;

  @override
  Stream<NotificationActionEvent> get responses => _responses.stream;
}

class _NullCalendarGateway implements CalendarGateway {
  @override
  Future<bool> requestPermissions() async => false;
  @override
  Future<List<CalendarInfo>> listCalendars() async => const [];
  @override
  Future<String?> upsertEvent(CalendarEventDraft draft) async => null;
  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async => true;
  @override
  Future<List<CalendarEventView>> eventsInRange({
    required String calendarId,
    required DateTime from,
    required DateTime to,
  }) async => const [];
}

class _NullSystemSettings implements SystemSettings {
  @override
  Future<bool> openAppSettings() async => true;
}
