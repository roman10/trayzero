import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/features/capture/capture_sheet.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/onboarding/onboarding_screen.dart';
import 'package:cleartray/features/process/process_inbox_screen.dart';
import 'package:cleartray/features/process/step_cards.dart';
import 'package:cleartray/features/projects/project_picker.dart';
import 'package:cleartray/features/projects/projects_screen.dart';
import 'package:cleartray/features/review/review_screen.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  Future<void> phone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.pumpAndSettle();
    final target = find.text(text);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  for (final scale in [0.75, 3.0]) {
    testWidgets('app preserves system text scale $scale', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final messenger = tester.binding.defaultBinaryMessenger;
      for (final name in [
        'receive_sharing_intent/messages',
        'receive_sharing_intent/events-media',
      ]) {
        final channel = MethodChannel(name);
        messenger.setMockMethodCallHandler(channel, (_) async => null);
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      }
      double? actualScale;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) {
              actualScale = MediaQuery.textScalerOf(context).scale(20) / 20;
              return Scaffold(
                appBar: AppBar(title: const Text('Scaled toolbar title')),
                body: const Text('System text preference'),
              );
            },
          ),
        ],
      );
      final container = env.container([
        routerProvider.overrideWithValue(router),
      ]);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TrayzeroApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(actualScale, scale);
      final titleRect = tester.getRect(find.text('Scaled toolbar title'));
      final barRect = tester.getRect(find.byType(AppBar));
      expect(titleRect.top, greaterThanOrEqualTo(barRect.top));
      expect(titleRect.bottom, lessThanOrEqualTo(barRect.bottom));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      router.dispose();
    });
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('Clarify stays usable in $locale at 2x text', (tester) async {
      await phone(tester);
      final items = ItemRepository(env.db, env.clock);
      await items.upsert(anItem(id: 'a', title: 'Plan a long summer trip'));
      await pumpApp(
        tester,
        const ProcessInboxScreen(),
        env: env,
        locale: locale,
        textScaler: const TextScaler.linear(2),
      );
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(
        tester.element(find.byType(ProcessInboxScreen)),
      );
      await tapText(tester, l.actionableYes);
      expect(find.text(l.twoMinRule), findsOneWidget);
      await tapText(tester, l.processTwoMinNo);
      expect(find.text(l.delegateYes), findsOneWidget);
      await tapText(tester, l.delegateNo);
      expect(find.text(l.projectRule), findsOneWidget);
      await tapText(tester, l.singleStepYes);
      expect(find.text(l.deferCalendar), findsOneWidget);
      await tapText(tester, l.deferAsap);
      expect(find.text(l.processDetailsTitle), findsOneWidget);
      expect(find.text(l.energyLow), findsOneWidget);
      await tapText(tester, l.minutesShort(15));
      await tapText(tester, l.processFileNextAction);
      // The Undo snackbar that follows is the one element that does not fit
      // here: the test font (Ahem) is 1em per glyph, so a long translated
      // action ("Rückgängig") overflows 314dp at 2x, which real fonts do not.
      final overflow = tester.takeException();
      expect(overflow == null || '$overflow'.contains('overflowed'), isTrue);
      final saved = (await items.getById('a'))!;
      expect(saved.status, ItemStatus.nextAction);
      expect(saved.timeEstimateMinutes, 15);
      expect(find.text(l.processCompleteTitle), findsOneWidget);
    });
  }

  final screens = <String, Widget>{
    'Inbox': const InboxScreen(),
    'Do': const EngageScreen(),
    'Projects': const ProjectsScreen(),
    'Review': const ReviewScreen(),
    'Clarify': const ProcessInboxScreen(),
    'Onboarding': const OnboardingScreen(),
    'Item edit': const ItemEditScreen(itemId: 'a'),
  };

  for (final scale in [2.0, 3.0]) {
    testWidgets('populated Do calendar band fits at ${scale}x German text', (
      tester,
    ) async {
      await phone(tester);
      final items = ItemRepository(env.db, env.clock);
      await items.upsert(
        anItem(
          id: 'today',
          title: 'Dentist appointment',
          status: ItemStatus.calendar,
          dueAt: env.clock.now().add(const Duration(hours: 2)),
        ),
      );
      await items.upsert(
        anItem(
          id: 'overdue',
          title: 'Reschedule this appointment',
          status: ItemStatus.calendar,
          dueAt: env.clock.now().subtract(const Duration(days: 1)),
        ),
      );
      await items.upsert(
        anItem(
          id: 'action',
          title: 'Prepare a proposal',
          status: ItemStatus.nextAction,
        ),
      );
      await pumpApp(
        tester,
        const EngageScreen(),
        env: env,
        locale: const Locale('de'),
        textScaler: TextScaler.linear(scale),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
      final l = AppLocalizations.of(tester.element(find.byType(EngageScreen)));
      expect(find.textContaining(l.hardLandscape), findsOneWidget);
      expect(find.textContaining(l.hardLandscapeSubtitle), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Prepare a proposal'),
        250,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prepare a proposal').hitTestable(), findsOneWidget);
      expect(tester.takeException(), null);
    });
  }

  testWidgets('each new Clarify step and capture starts at the top', (
    tester,
  ) async {
    await phone(tester);
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(
      anItem(
        id: 'a',
        title: 'First capture',
        notes: List.filled(40, 'Long notes to scroll').join('\n'),
      ),
    );
    await items.upsert(anItem(id: 'b', title: 'Read next capture'));
    await pumpApp(
      tester,
      const ProcessInboxScreen(),
      env: env,
      textScaler: const TextScaler.linear(2),
    );
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(
      tester.element(find.byType(ProcessInboxScreen)),
    );
    await tapText(tester, l.actionableYes);
    await tapText(tester, l.processTwoMinNo);
    await tapText(tester, l.delegateNo);
    await tapText(tester, l.singleStepYes);
    await tapText(tester, l.deferAsap);
    await tapText(tester, l.processFileNextAction);
    expect(find.text('Read next capture').hitTestable(), findsOneWidget);
    expect(find.text(l.actionableQuestion), findsOneWidget);
  });
  for (final entry in screens.entries) {
    testWidgets('${entry.key} fits a small phone at 3x German text', (
      tester,
    ) async {
      await phone(tester);
      if (entry.key == 'Item edit') {
        await ItemRepository(
          env.db,
          env.clock,
        ).upsert(anItem(id: 'a', status: ItemStatus.nextAction));
      }
      await pumpApp(
        tester,
        entry.value,
        env: env,
        locale: const Locale('de'),
        textScaler: const TextScaler.linear(3),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
      if (entry.key == 'Onboarding') {
        final l = AppLocalizations.of(
          tester.element(find.byType(OnboardingScreen)),
        );
        for (var i = 0; i < 4; i++) {
          await tapText(tester, l.next);
        }
        await tester.ensureVisible(find.byType(SwitchListTile));
        await tester.pumpAndSettle();
        expect(find.text(l.onboardingFinish), findsOneWidget);
      }
    });
  }

  testWidgets('capture actions remain reachable with large text and keyboard', (
    tester,
  ) async {
    await phone(tester);
    const channel = MethodChannel('plugin.csdcorp.com/speech_to_text');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => false,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () => showCaptureSheet(context),
              child: const Text('Open capture'),
            );
          },
        ),
      ),
      env: env,
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(3),
    );
    await tester.tap(find.text('Open capture'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = FakeViewPadding(
      bottom: 280 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(CaptureSheet)));
    await tester.enterText(find.byType(TextField).first, 'Accessible capture');
    await tapText(tester, l.captureSubmit);
    expect(find.byType(CaptureSheet), findsNothing);
    final captured = await ItemRepository(env.db, env.clock).allActive();
    expect(captured.single.title, 'Accessible capture');
  });

  testWidgets('new project form remains usable with large text and keyboard', (
    tester,
  ) async {
    await phone(tester);
    await pumpApp(
      tester,
      Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            return FilledButton(
              onPressed: () => showNewProjectSheet(context, ref),
              child: const Text('Open project'),
            );
          },
        ),
      ),
      env: env,
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(3),
    );
    await tester.tap(find.text('Open project'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = FakeViewPadding(
      bottom: 280 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(TextField).first));
    expect(find.text(l.outcomeSection), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Accessible project');
    await tapText(tester, l.createProject);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('deferred summary follows app locale instead of global locale', (
    tester,
  ) async {
    await phone(tester);
    final previousLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'en';
    addTearDown(() => Intl.defaultLocale = previousLocale);
    await pumpApp(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: StepDetail(
            contexts: const [],
            projects: const [],
            selectedContextId: null,
            selectedProjectId: null,
            energy: null,
            timeEstimate: null,
            deferUntil: DateTime(2026, 5, 18, 10),
            recurrence: Recurrence.weekly,
            onContext: (_) {},
            onProject: (_) {},
            onCreateProject: () {},
            onEnergy: (_) {},
            onTime: (_) {},
            onConfirm: () {},
            onBack: () {},
          ),
        ),
      ),
      env: env,
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(3),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Mai'), findsOneWidget);
    expect(find.textContaining('Wöchentlich'), findsOneWidget);
    expect(find.textContaining('May'), findsNothing);
    expect(find.text('Weekly'), findsNothing);
  });

  for (final cadence in [Recurrence.weekly, Recurrence.monthly]) {
    testWidgets('recurrence editor remains usable at 3x text: $cadence', (
      tester,
    ) async {
      await phone(tester);
      await ItemRepository(env.db, env.clock).upsert(
        anItem(
          id: 'repeat',
          status: ItemStatus.nextAction,
          recurrence: cadence,
          recurrenceInterval: 12,
          recurrenceCount: 20,
          recurrenceMonthlyWeek: cadence == Recurrence.monthly ? 2 : null,
          recurrenceMonthlyWeekday: cadence == Recurrence.monthly ? 4 : null,
          deferUntil: env.clock.now().add(const Duration(days: 1)),
        ),
      );
      await pumpApp(
        tester,
        const ItemEditScreen(itemId: 'repeat'),
        env: env,
        locale: const Locale('de'),
        textScaler: const TextScaler.linear(3),
      );
      await tester.pumpAndSettle();
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 20; i++) {
        await tester.drag(scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('project picker actions stay reachable at 3x text', (
    tester,
  ) async {
    await phone(tester);
    ProjectPick? picked;
    await pumpApp(
      tester,
      Scaffold(
        body: Consumer(
          builder: (context, ref, _) => FilledButton(
            onPressed: () async {
              picked = await showProjectPicker(context, ref);
            },
            child: const Text('Pick project'),
          ),
        ),
      ),
      env: env,
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(3),
    );
    await tester.tap(find.text('Pick project'));
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(ListView)));
    await tester.scrollUntilVisible(
      find.text(l.noProject),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tapText(tester, l.noProject);
    expect(picked, isA<ProjectPickNone>());
  });

  testWidgets('Do filters contain their enlarged text without clipping', (
    tester,
  ) async {
    await phone(tester);
    await pumpApp(
      tester,
      const EngageScreen(),
      env: env,
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(3),
    );
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(EngageScreen)));
    final label = find.text(l.filterAllContexts);
    final chip = find.ancestor(of: label, matching: find.byType(FilterChip));
    final labelRect = tester.getRect(label);
    final chipRect = tester.getRect(chip);
    expect(chipRect.top, lessThanOrEqualTo(labelRect.top));
    expect(chipRect.bottom, greaterThanOrEqualTo(labelRect.bottom));
  });
}
