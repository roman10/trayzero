import 'dart:async';
import 'package:cleartray/application/appearance_controller.dart';
import 'package:cleartray/core/app_icon.dart';
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/features/settings/app_icon_picker.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

class FakeIconGateway implements AppIconGateway {
  AppIconState state = const AppIconState(supported: true);
  bool fail = false;
  Completer<AppIconState>? pending;
  @override
  Future<AppIconState> load() async => state;
  @override
  Future<AppIconState> setIcon(AppPalette palette) async {
    if (fail) throw StateError('denied');
    if (pending != null) return pending!.future;
    return state = AppIconState(supported: true, palette: palette);
  }
}

void main() {
  late TestEnv env;
  late FakeIconGateway gateway;
  setUp(() async {
    env = await TestEnv.create();
    gateway = FakeIconGateway();
  });
  tearDown(() => env.dispose());
  testWidgets(
    'selection is separate from app palette; failures are visible and retryable',
    (tester) async {
      await pumpApp(
        tester,
        const AppIconPicker(),
        env: env,
        extraOverrides: [appIconGatewayProvider.overrideWithValue(gateway)],
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('app_icon_cyan')));
      await tester.tap(find.byKey(const ValueKey('app_icon_cyan')));
      await tester.pumpAndSettle();
      expect(gateway.state.palette, AppPalette.cyan);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppIconPicker)),
      );
      expect(container.read(appearanceProvider).palette, AppPalette.amber);
      gateway.fail = true;
      await tester.ensureVisible(find.byKey(const ValueKey('app_icon_violet')));
      await tester.tap(find.byKey(const ValueKey('app_icon_violet')));
      await tester.pumpAndSettle();
      expect(gateway.state.palette, AppPalette.cyan);
      expect(find.textContaining('Could not change'), findsOneWidget);
      gateway.fail = false;
      await tester.ensureVisible(find.byKey(const ValueKey('app_icon_amber')));
      await tester.tap(find.byKey(const ValueKey('app_icon_amber')));
      await tester.pumpAndSettle();
      expect(gateway.state.palette, AppPalette.amber);
      expect(find.textContaining('Could not change'), findsNothing);
    },
  );
  testWidgets(
    'all translations fit a narrow screen with large text and scroll to every choice',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locale in AppLocalizations.supportedLocales) {
        await pumpApp(
          tester,
          const AppIconPicker(),
          env: env,
          locale: locale,
          textScaler: const TextScaler.linear(2),
          extraOverrides: [appIconGatewayProvider.overrideWithValue(gateway)],
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(AppIconPicker)),
        );
        expect(
          find.text(l10n.appIconNotificationNote),
          defaultTargetPlatform == TargetPlatform.android
              ? findsOneWidget
              : findsNothing,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('app_icon_rose')));
        await tester.tap(find.byKey(const ValueKey('app_icon_rose')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, l10n.done),
        );
        expect(tester.takeException(), isNull, reason: '$locale');
      }
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
