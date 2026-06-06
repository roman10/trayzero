// Screen-recording harness for the App Store subscription review (3.1.2c).
//
// Apple rejected 1.0.2(33) because the auto-renewable subscription purchase
// flow must show, in-app, the subscription title/length/price AND functional
// links to the Privacy Policy + Terms of Use (EULA). This test drives the app
// to More → Support Trayzero, shows the supporter rows (with prices) and the
// two legal link rows, then taps one link so it opens in Safari — proving the
// link is functional. An external `xcrun simctl io … recordVideo` captures it.
//
// Mirrors iap_review_screenshot_test.dart (same offering mocks + navigation)
// but adds real-time pauses and a tap, and takes no screenshot. Which link to
// tap is chosen with --dart-define=LINK=privacy|terms (default privacy).
//
// Run from `mobile/` against a BOOTED simulator (debug; profile is not allowed
// on the iOS sim):
//
//   flutter drive \
//     --driver=test_driver/iap_screenshot_driver.dart \
//     --target=integration_test/iap_review_recording_test.dart \
//     -d "iPhone 16 Pro Max" \
//     --dart-define=LINK=privacy

import 'dart:async';

import 'package:cleartray/app/router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/application/billing_controller.dart'
    show billingOfferingsProvider, supporterStatusProvider;
import 'package:cleartray/core/billing.dart';
import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/home_widget_bridge.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/core/system_settings.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/providers.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/features/settings/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _link = String.fromEnvironment('LINK', defaultValue: 'privacy');

/// Mocked offering with representative US prices matching the four products.
const _offerings = BillingOfferings(
  tips: [
    BillingProduct(
      id: BillingIds.tipSmall,
      title: 'Small Tip',
      priceString: r'$1.99',
      rawPrice: 1.99,
      currencyCode: 'USD',
    ),
    BillingProduct(
      id: BillingIds.tipLarge,
      title: 'Large Tip',
      priceString: r'$9.99',
      rawPrice: 9.99,
      currencyCode: 'USD',
    ),
  ],
  monthly: BillingProduct(
    id: BillingIds.supporterMonthly,
    title: 'Supporter (Monthly)',
    priceString: r'$0.99',
    rawPrice: 0.99,
    currencyCode: 'USD',
  ),
  yearly: BillingProduct(
    id: BillingIds.supporterYearly,
    title: 'Supporter (Yearly)',
    priceString: r'$7.99',
    rawPrice: 7.99,
    currencyCode: 'USD',
  ),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('record subscription info + functional legal links',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete_v1': true,
      'crash_reporting_enabled': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
      clockProvider.overrideWithValue(const SystemClock()),
      idGeneratorProvider.overrideWithValue(_CounterIdGenerator()),
      notificationSchedulerProvider
          .overrideWithValue(_NullNotificationScheduler()),
      homeWidgetBridgeProvider.overrideWithValue(_NullHomeWidgetBridge()),
      calendarGatewayProvider.overrideWithValue(_NullCalendarGateway()),
      systemSettingsProvider.overrideWithValue(_NullSystemSettings()),
      billingOfferingsProvider.overrideWith((ref) async => _offerings),
      supporterStatusProvider
          .overrideWith((ref) => Stream.value(const SupporterStatus.none())),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _RecordingApp(),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(routerProvider);
    router.go('/settings');
    await tester.pumpAndSettle();
    // Lead pause: gives the external recorder a window to start (after the
    // driver connects, before any scrolling) so the captured clip skips the
    // build/launch dead time and opens cleanly on the Settings screen.
    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;

    // 1. Reveal the supporter rows: title, length, price, auto-renew note.
    for (var i = 0; i < 25; i++) {
      if (find.byIcon(Icons.workspace_premium_outlined).evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(list, const Offset(0, -340));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3)); // hold on prices

    // 2. Reveal the legal link rows (Privacy Policy + Terms of Use).
    final label = _link == 'terms' ? 'Terms of Use' : 'Privacy Policy';
    for (var i = 0; i < 20; i++) {
      if (find.text(label).evaluate().isNotEmpty) break;
      await tester.drag(list, const Offset(0, -260));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3)); // hold on the link rows

    // 3. Tap the link → opens the page in Safari (proves it's functional).
    await tester.tap(find.text(label));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 6)); // Safari loads the page
  });
}

class _RecordingApp extends ConsumerWidget {
  const _RecordingApp();

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

class _CounterIdGenerator extends IdGenerator {
  int _n = 0;
  @override
  String newId() => 'seed-${++_n}';
}

class _NullHomeWidgetBridge implements HomeWidgetBridge {
  @override
  Future<void> init() async {}
  @override
  Future<void> publishInboxCount(int count) async {}
  @override
  Stream<Uri> get widgetTaps => const Stream.empty();
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
