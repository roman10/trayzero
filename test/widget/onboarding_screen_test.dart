import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/onboarding/onboarding_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';


/// Onboarding navigates with go_router on completion, so it needs a router.
Future<void> _pumpRouted(WidgetTester tester, TestEnv env) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/inbox',
        builder: (_, _) => const Scaffold(body: Text('inbox-page')),
      ),
    ],
  );
  addTearDown(router.dispose);
  final container = ProviderContainer(overrides: env.overrides());
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
}

/// Drift I/O completes on real time, not FakeAsync: let it run, then pump.
Future<void> _realDelay(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  for (final width in [360.0, 412.0]) {
    testWidgets('onboarding header aligns to phone edges at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpApp(tester, const OnboardingScreen(), env: env);
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(
        tester.element(find.byType(OnboardingScreen)),
      );
      final name = tester.getRect(find.text(l.appName));
      final skip = tester.getRect(find.widgetWithText(TextButton, l.skip));

      expect(name.left, 20);
      expect(skip.right, width - 20);
      expect(name.center.dy, closeTo(skip.center.dy, 0.1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Skip stays available until the final setup page', (
    tester,
  ) async {
    await pumpApp(tester, const OnboardingScreen(), env: env);
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );
    for (var page = 0; page < 4; page++) {
      expect(find.widgetWithText(TextButton, l.skip), findsOneWidget);
      await tester.tap(find.text(l.next));
      await tester.pumpAndSettle();
    }
    expect(find.widgetWithText(TextButton, l.skip), findsNothing);
    expect(find.text(l.onboardingFinish), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, l.skip), findsOneWidget);
  });

  testWidgets('Skip never seeds the sample project', (tester) async {
    await _pumpRouted(tester, env);
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );
    await tester.tap(find.widgetWithText(TextButton, l.skip));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(() => ProjectRepository(env.db).watchAll().first))!, isEmpty);
  });

  testWidgets('replay with existing projects defaults the sample off',
      (tester) async {
    final ts = DateTime(2026, 5, 14, 9);
    await ProjectRepository(env.db).upsert(Project(
      id: 'p1',
      title: 'Mine',
      status: ProjectStatus.active,
      createdAt: ts,
      updatedAt: ts,
    ));
    await _pumpRouted(tester, env);
    await _realDelay(tester);
    final l = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );
    for (var page = 0; page < 4; page++) {
      await tester.tap(find.text(l.next));
      await tester.pumpAndSettle();
    }
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse);
    expect(find.text('You already have 1 project.'), findsOneWidget);
    await tester.tap(find.text(l.onboardingFinish));
    await _realDelay(tester);
    expect((await tester.runAsync(() => ProjectRepository(env.db).watchAll().first))!, hasLength(1));
  });

  testWidgets('first run defaults the sample on and Finish seeds it',
      (tester) async {
    await _pumpRouted(tester, env);
    await _realDelay(tester);
    final l = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );
    for (var page = 0; page < 4; page++) {
      await tester.tap(find.text(l.next));
      await tester.pumpAndSettle();
    }
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue);
    await tester.tap(find.text(l.onboardingFinish));
    await _realDelay(tester);
    expect((await tester.runAsync(() => ProjectRepository(env.db).watchAll().first))!, hasLength(1));
  });
}
