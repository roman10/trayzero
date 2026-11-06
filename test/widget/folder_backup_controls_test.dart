import 'package:cleartray/application/automatic_folder_backup.dart';
import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/features/settings/backup_status_card.dart';
import 'package:cleartray/features/settings/folder_backup_controls.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:cleartray/infrastructure/shared_preferences_folder_backup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../support/folder_backup_fake.dart';
import '../support/harness.dart';

void main() {
  testWidgets(
    'folder selection enables backups, reports success, and disable persists',
    (tester) async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final files = MemoryFolderBackupFiles()
        ..selection = const BackupFolder(
          handle: 'folder',
          label: 'Syncthing backups',
        );
      final container = env.container([
        automaticFolderBackupProvider.overrideWith(
          (ref) => AutomaticFolderBackup(
            preferences: SharedPreferencesFolderBackup(env.prefs),
            files: files,
            clock: env.clock,
            changes: const Stream.empty(),
            export: () async => {'version': 6, 'items': <Object>[]},
          ),
        ),
      ]);
      await pumpWithContainer(tester, container);
      await tester.tap(find.byKey(const ValueKey('automatic_folder_backup')));
      await tester.pumpAndSettle();
      expect(files.snapshots, hasLength(1));
      expect(find.text('Syncthing backups'), findsOneWidget);
      expect(find.textContaining('Backed up'), findsOneWidget);
      expect(
        container.read(automaticFolderBackupProvider).settings.lastSuccess,
        env.clock.now(),
      );
      await tester.tap(find.byKey(const ValueKey('automatic_folder_backup')));
      await tester.pumpAndSettle();
      expect(
        container.read(automaticFolderBackupProvider).settings.enabled,
        false,
      );
      expect(find.text('Automatic backups are off.'), findsOneWidget);
    },
  );

  testWidgets('compact translated controls preserve 3x text without overflow', (
    tester,
  ) async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final container = env.container();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in AppLocalizations.supportedLocales) {
      await pumpWithContainer(tester, container, locale: locale, scale: 3);
      expect(tester.takeException(), null, reason: locale.toLanguageTag());
    }
  });
}

Future<void> pumpWithContainer(
  WidgetTester tester,
  ProviderContainer container, {
  Locale locale = const Locale('en'),
  double scale = 1,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [BackupStatusCard(), FolderBackupControls()],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
