// Standalone App Store IAP review-screenshot harness.
//
// Apple requires a review screenshot per in-app purchase before they leave
// MISSING_METADATA. Live products don't vend until they're approved, so this
// test mocks `billingOfferingsProvider` with representative prices, drives the
// app to Settings → Support, scrolls the purchase tiles into view, and asks the
// integration_test binding to capture a single PNG ("iap-support").
//
// Kept SEPARATE from screenshots_test.dart on purpose: that harness has its own
// listing-flow assertions and is parameterised by --dart-define; this one is
// unconditional so it can't be silently skipped. Run from `mobile/`:
//
//   flutter drive \
//     --driver=test_driver/iap_screenshot_driver.dart \
//     --target=integration_test/iap_review_screenshot_test.dart \
//     -d "iPhone SE (3rd generation)"
//
// Output: docs/app-store-listing/iap-review/iap-support.png (750×1334 on the
// iPhone SE sim — an App Store Connect-accepted IAP review-screenshot size).
// The sim must already be Booted; profile mode is not allowed on the iOS sim,
// so this runs in the default debug mode.

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
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture IAP review screenshot', (tester) async {
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
        child: const _ScreenshotApp(),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(routerProvider);
    router.go('/settings');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Scroll the settings list down until the tip tile (a Support-only icon)
    // is on screen. Fixed-step drags tolerate layout changes.
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 15; i++) {
      if (find.byIcon(Icons.local_cafe_outlined).evaluate().isNotEmpty) break;
      await tester.drag(list, const Offset(0, -420));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();

    await binding.takeScreenshot('iap-support');
  });
}

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
