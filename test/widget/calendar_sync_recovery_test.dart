import 'dart:async';

import 'package:cleartray/application/calendar_connection_controller.dart';
import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/calendar_connection.dart';
import 'package:cleartray/features/calendar_sync/calendar_sync_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class FailingCalendar extends FakeCalendarGateway {
  bool fail = true;
  int prompts = 0;
  @override
  Future<bool> requestPermissions() async {
    prompts++;
    return permissionGranted;
  }

  @override
  Future<List<CalendarInfo>> listCalendars() async {
    if (fail) throw StateError('provider unavailable');
    return super.listCalendars();
  }
}

class HeldPermissionCalendar extends FakeCalendarGateway {
  final permission = Completer<bool>();
  int prompts = 0;
  @override
  Future<bool> requestPermissions() {
    prompts++;
    return permission.future;
  }
}

class FailingPreferences implements CalendarConnectionPreferences {
  @override
  CalendarConnectionSettings load() => const CalendarConnectionSettings();
  @override
  Future<void> save(CalendarConnectionSettings settings) async =>
      throw StateError('disk unavailable');
}

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create(now: DateTime(2026, 11, 5)));
  tearDown(() => env.dispose());

  Future<void> open(
    WidgetTester tester, {
    CalendarGateway? gateway,
    TextScaler? textScaler,
  }) async {
    await pumpApp(
      tester,
      const CalendarSyncScreen(),
      env: env,
      textScaler: textScaler,
      extraOverrides: [
        if (gateway != null) calendarGatewayProvider.overrideWithValue(gateway),
      ],
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer container(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(CalendarSyncScreen)),
  );

  testWidgets('setup save errors are visible and announced while disconnected', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(
      tester,
      const CalendarSyncScreen(),
      env: env,
      extraOverrides: [
        calendarConnectionPreferencesProvider.overrideWithValue(
          FailingPreferences(),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await container(tester)
        .read(calendarConnectionProvider.notifier)
        .connect(env.calendar.calendars.first);
    await tester.pumpAndSettle();
    final error = find.textContaining('Could not save this change');
    expect(error, findsOneWidget);
    expect(
      tester.getSemantics(error),
      matchesSemantics(
        label:
            'Could not save this change. Check the connection settings and try again.',
        isLiveRegion: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('dialogs announce their title and status changes are live', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Connect calendar'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Choose your calendar')),
      matchesSemantics(
        label: 'Choose your calendar',
        namesRoute: true,
        isHeader: true,
      ),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await container(tester)
        .read(calendarConnectionProvider.notifier)
        .connect(env.calendar.calendars.first);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Connected')),
      matchesSemantics(label: 'Connected', isLiveRegion: true),
    );
    semantics.dispose();
  });

  testWidgets(
    'permission recovery disables repeat actions and survives leaving',
    (tester) async {
      final gateway = HeldPermissionCalendar();
      await open(tester, gateway: gateway);
      final controller = container(
        tester,
      ).read(calendarConnectionProvider.notifier);
      await controller.connect(gateway.calendars.first);
      gateway.permissionGranted = false;
      await controller.resume();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore access'));
      await tester.pump();
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Restore access'),
            )
            .onPressed,
        isNull,
      );
      expect(gateway.prompts, 1);
      await tester.pumpWidget(const SizedBox());
      gateway.permission.complete(true);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('connection controls meet accessibility guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await container(tester)
        .read(calendarConnectionProvider.notifier)
        .connect(env.calendar.calendars.first);
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('opening disconnected settings never prompts for permission', (
    tester,
  ) async {
    final gateway = FailingCalendar();
    await open(tester, gateway: gateway);
    expect(gateway.prompts, 0);
    expect(find.text('Connect calendar'), findsNWidgets(2));
  });

  testWidgets('lookup failure is actionable and setup retry recovers', (
    tester,
  ) async {
    final gateway = FailingCalendar();
    await open(tester, gateway: gateway);
    await tester.tap(find.widgetWithText(FilledButton, 'Connect calendar'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Could not load your device calendars'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    gateway.fail = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Connect calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your calendar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('setup excludes read-only calendars and requires selection', (
    tester,
  ) async {
    env.calendar.calendars = [
      const CalendarInfo(id: 'read', name: 'Holidays', writable: false),
      const CalendarInfo(
        id: 'cal-1',
        name: 'Personal',
        accountName: 'Home account',
      ),
    ];
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Connect calendar'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Connect and add events'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byType(DropdownButtonFormField<CalendarInfo>));
    await tester.pumpAndSettle();
    expect(find.text('Holidays'), findsNothing);
    await tester.tap(find.text('Personal · Home account').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect and add events'));
    await tester.pumpAndSettle();
    expect(find.text('Connected'), findsOneWidget);
    expect(
      container(tester).read(calendarConnectionProvider).settings.automatic,
      isTrue,
    );
  });

  testWidgets('pause is reversible and explains event retention', (
    tester,
  ) async {
    await open(tester);
    await container(tester)
        .read(calendarConnectionProvider.notifier)
        .connect(env.calendar.calendars.first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsOneWidget);
    expect(
      find.textContaining('Existing calendar events stay in place'),
      findsOneWidget,
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('disconnect defaults to keep and requires confirmation', (
    tester,
  ) async {
    await open(tester);
    final controller = container(
      tester,
    ).read(calendarConnectionProvider.notifier);
    await controller.connect(env.calendar.calendars.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage connection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disconnect calendar'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<RadioGroup<bool>>(find.byType(RadioGroup<bool>)).groupValue,
      isFalse,
    );
    expect(controller.state.settings.connected, isTrue);
    await tester.tap(find.widgetWithText(FilledButton, 'Disconnect calendar'));
    await tester.pumpAndSettle();
    expect(controller.state.settings.connected, isFalse);
  });

  testWidgets('denied setup provides settings recovery without connecting', (
    tester,
  ) async {
    env.calendar.permissionGranted = false;
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Connect calendar'));
    await tester.pumpAndSettle();
    expect(
      container(tester).read(calendarConnectionProvider).settings.connected,
      isFalse,
    );
    await tester.tap(find.text('Open app settings'));
    await tester.pumpAndSettle();
    expect(env.systemSettings.openCount, 1);
  });

  testWidgets('compact screen supports large text and scrolling to import', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 690);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester, textScaler: const TextScaler.linear(2));
    await container(tester)
        .read(calendarConnectionProvider.notifier)
        .connect(env.calendar.calendars.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Choose events'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Choose events'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose events'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a source calendar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('connection and disconnect fit at 3x text in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 690);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpApp(
        tester,
        const CalendarSyncScreen(),
        env: env,
        locale: locale,
        textScaler: const TextScaler.linear(3),
      );
      await tester.pumpAndSettle();
      final c = container(tester);
      await c
          .read(calendarConnectionProvider.notifier)
          .connect(env.calendar.calendars.first);
      await c.read(calendarConnectionProvider.notifier).setAutomatic(false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(CalendarSyncScreen)),
      );
      await tester.scrollUntilVisible(
        find.text(l10n.calendarManage),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l10n.calendarManage));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.calendarManage));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(l10n.calendarDisconnect),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.calendarDisconnect));
      await tester.pumpAndSettle();
      expect(find.text(l10n.calendarDisconnectQuestion), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
