import 'dart:async';
import 'dart:ui' show Tristate, SemanticsAction, SemanticsActionEvent;

import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/application/appearance_controller.dart';
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/features/settings/appearance_screen.dart';
import 'package:cleartray/features/settings/settings_controller.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/harness.dart';

class FailingAppearanceStore implements AppearancePreferencesStore {
  @override
  AppearancePreferences load() => const AppearancePreferences();
  @override
  Future<void> saveMode(AppearanceMode mode) async => throw StateError('disk');
  @override
  Future<void> savePalette(AppPalette palette) async =>
      throw StateError('disk');
}

void main() {
  late TestEnv env;

  setUp(() async {
    ReceiveSharingIntent.setMockValues(
      initialMedia: [],
      mediaStream: const Stream.empty(),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Trayzero',
      packageName: 'app.cleartray',
      version: '1.0.5',
      buildNumber: '41',
      buildSignature: '',
    );
    env = await TestEnv.create(prefsValues: {'onboarding_complete_v1': true});
  });
  tearDown(() => env.dispose());

  Future<ProviderContainer> boot(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    final container = env.container(overrides);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TrayzeroApp(),
      ),
    );
    container.read(routerProvider).go('/settings/appearance');
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> pickPalette(WidgetTester tester, AppPalette palette) async {
    final finder = find.byKey(ValueKey('palette_${palette.id}'));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets(
      '$platform: selecting a palette updates the screen and persists',
      (tester) async {
        final container = await boot(tester);
        final router = container.read(routerProvider);
        expect(find.byType(AppearanceScreen), findsOneWidget);
        await pickPalette(tester, AppPalette.cyan);
        expect(container.read(appearanceProvider).palette, AppPalette.cyan);
        expect(env.prefs.getString('app_palette'), 'cyan');
        final context = tester.element(find.byType(AppearanceScreen));
        expect(
          Theme.of(context).colorScheme.primary,
          AppTheme.light(palette: AppPalette.cyan).colorScheme.primary,
        );
        expect(find.byType(AppearanceScreen), findsOneWidget);
        expect(container.read(routerProvider), same(router));
        // Amber is a reset.
        await pickPalette(tester, AppPalette.amber);
        expect(env.prefs.getString('app_palette'), 'amber');
        expect(container.read(appearanceProvider).mode, AppearanceMode.system);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(platform),
    );
  }

  testWidgets('theme mode selector preserves the selected palette', (
    tester,
  ) async {
    final container = await boot(tester);
    await container
        .read(appearanceProvider.notifier)
        .setPalette(AppPalette.blue);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(appearanceProvider).mode, AppearanceMode.dark);
    expect(container.read(appearanceProvider).palette, AppPalette.blue);
    expect(env.prefs.getString('theme_mode'), 'dark');
    final context = tester.element(find.byType(AppearanceScreen));
    expect(
      Theme.of(context).colorScheme,
      AppTheme.dark(palette: AppPalette.blue).colorScheme,
    );
  });

  testWidgets('mode save failure rolls back and shows a snackbar', (
    tester,
  ) async {
    final container = await boot(
      tester,
      overrides: [
        appearancePreferencesStoreProvider.overrideWithValue(
          FailingAppearanceStore(),
        ),
      ],
    );
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(appearanceProvider).mode, AppearanceMode.system);
    expect(
      find.textContaining('Could not save your appearance'),
      findsOneWidget,
    );
  });

  testWidgets(
    'saved dark palette is used on the first frame; System follows brightness',
    (tester) async {
      await env.prefs.setString('theme_mode', 'dark');
      await env.prefs.setString('app_palette', 'rose');
      final container = env.container();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TrayzeroApp(),
        ),
      );
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
      expect(
        tester
            .widget<MaterialApp>(find.byType(MaterialApp))
            .darkTheme!
            .colorScheme,
        AppTheme.dark(palette: AppPalette.rose).colorScheme,
      );
      await tester.pumpAndSettle();
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await container
          .read(appearanceProvider.notifier)
          .setMode(AppearanceMode.system);
      await tester.pumpAndSettle();
      final scaffold = tester.element(find.byType(Scaffold).first);
      expect(Theme.of(scaffold).brightness, Brightness.dark);
      expect(container.read(appearanceProvider).palette, AppPalette.rose);
    },
  );

  testWidgets('palette changes preserve the edit route, draft and controller', (
    tester,
  ) async {
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(anItem(id: 'draft', title: 'Original task'));
    final container = await boot(tester);
    final router = container.read(routerProvider);
    unawaited(router.push<void>('/item/draft'));
    await tester.pumpAndSettle();
    final field = find.widgetWithText(TextField, 'Original task');
    final textController = tester.widget<TextField>(field).controller!;
    await tester.enterText(field, 'My unsaved draft');
    await container
        .read(appearanceProvider.notifier)
        .setPalette(AppPalette.violet);
    await tester.pump(const Duration(milliseconds: 300));
    final edited = tester.widget<TextField>(
      find.widgetWithText(TextField, 'My unsaved draft'),
    );
    expect(edited.controller, same(textController));
    expect(container.read(routerProvider), same(router));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/item/draft',
    );
    expect((await items.getById('draft'))!.title, 'Original task');
    await tester.pump(const Duration(milliseconds: 700));
    expect((await items.getById('draft'))!.title, 'My unsaved draft');
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('palette save failure rolls back and is explained inline', (
    tester,
  ) async {
    final container = await boot(
      tester,
      overrides: [
        appearancePreferencesStoreProvider.overrideWithValue(
          FailingAppearanceStore(),
        ),
      ],
    );
    await pickPalette(tester, AppPalette.blue);
    expect(container.read(appearanceProvider).palette, AppPalette.amber);
    expect(
      find.textContaining('Could not save your appearance'),
      findsOneWidget,
    );
    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'swatches expose labels, selected state and adequate touch targets',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await boot(tester);
      for (final palette in AppPalette.values) {
        final finder = find.byKey(ValueKey('palette_${palette.id}'));
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        final size = tester.getSize(finder);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
        final node = tester.getSemantics(
          find.byKey(ValueKey('palette_semantics_${palette.id}')),
        );
        expect(node.label, isNotEmpty);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
        expect(
          node.getSemanticsData().flagsCollection.isSelected,
          palette == AppPalette.amber ? Tristate.isTrue : Tristate.isFalse,
        );
      }
      await tester.ensureVisible(
        find.byKey(const ValueKey('palette_semantics_blue')),
      );
      await tester.pumpAndSettle();
      final blue = tester.getSemantics(
        find.byKey(const ValueKey('palette_semantics_blue')),
      );
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          nodeId: blue.id,
          viewId: tester.view.viewId,
          type: SemanticsAction.tap,
        ),
      );
      await tester.pumpAndSettle();
      expect(env.prefs.getString('app_palette'), 'blue');
      semantics.dispose();
    },
  );

  testWidgets(
    'translated appearance screen remains scrollable at large text on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = await boot(tester);
      // Reuse the actual root's language preference for all supported locales.
      for (final locale in AppLocalizations.supportedLocales) {
        final tag = locale.scriptCode == 'Hant'
            ? 'zh-Hant'
            : locale.languageCode;
        await env.prefs.setString('app_locale', tag);
        // The persisted language controller is explicitly invalidated to emulate
        // a fresh load, while appearance/navigation remain live.
        // Locale changes are unrelated to palette persistence.
        container.invalidate(localeOverrideProvider);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale');
        await tester.ensureVisible(find.byKey(const ValueKey('palette_rose')));
        await tester.tap(find.byKey(const ValueKey('palette_rose')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale');
      }
    },
  );
}
