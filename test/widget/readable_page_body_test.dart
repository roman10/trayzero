import 'dart:math' as math;

import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/features/app_import/app_import_screen.dart';
import 'package:cleartray/features/app_import/app_import_source_screen.dart';
import 'package:cleartray/features/onboarding/onboarding_screen.dart';
import 'package:cleartray/features/settings/backup_screen.dart';
import 'package:cleartray/features/settings/restore_from_folder_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  final pages = <(String, Widget, Type, Finder Function(AppLocalizations))>[
    (
      'Onboarding',
      const OnboardingScreen(),
      PageView,
      (l) => find.text(l.next),
    ),
    (
      'Import',
      const AppImportScreen(),
      ListView,
      (l) => find.text(l.importListIntro),
    ),
    (
      'Import source',
      const AppImportSourceScreen(source: ImportSourceApp.todoist),
      ListView,
      (l) => find.text(l.importChooseFile),
    ),
    (
      'Backup',
      const BackupScreen(),
      ListView,
      (_) => find.byKey(const ValueKey('automatic_folder_backup')),
    ),
    (
      'Restore from folder',
      const RestoreFromFolderScreen(),
      ListView,
      (_) => find.byKey(const ValueKey('restore_choose_folder')),
    ),
  ];

  for (final (label, screen, viewportType, findControl) in pages) {
    testWidgets('$label centers its viewport inside the safe area', (
      tester,
    ) async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await pumpApp(
        tester,
        screen,
        env: env,
        textScaler: const TextScaler.linear(2),
      );
      final l = AppLocalizations.of(
        tester.element(find.byType(screen.runtimeType)),
      );

      for (final (size, insets) in [
        (const Size(390, 844), const FakeViewPadding()),
        (const Size(466, 678), const FakeViewPadding(right: 84)),
        (const Size(669, 951), const FakeViewPadding()),
        (const Size(951, 669), const FakeViewPadding(left: 84)),
        (const Size(1032, 1376), const FakeViewPadding()),
      ]) {
        tester.view.physicalSize = size;
        tester.view.padding = insets;
        tester.view.viewPadding = insets;
        await tester.pumpAndSettle();

        final availableWidth = size.width - insets.left - insets.right;
        final viewport = tester.getRect(find.byType(viewportType));
        expect(viewport.width, math.min(640.0, availableWidth));
        expect(viewport.center.dx, insets.left + availableWidth / 2);
        final control = findControl(l);
        if (control.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            control,
            120,
            scrollable: find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          );
        }
        await tester.ensureVisible(control);
        await tester.pumpAndSettle();
        expect(control.hitTestable(), findsOneWidget, reason: 'window $size');
        expect(tester.takeException(), isNull, reason: 'window $size');
      }
    });
  }
}
