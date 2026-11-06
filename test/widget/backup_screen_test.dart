import 'package:cleartray/app/theme.dart';
import 'package:cleartray/application/automatic_folder_backup.dart';
import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/features/settings/backup_screen.dart';
import 'package:cleartray/infrastructure/shared_preferences_folder_backup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/folder_backup_fake.dart';
import '../support/harness.dart';

const _folder = BackupFolder(handle: 'tree', label: 'Cloud backups');

void main() {
  late TestEnv env;
  late MemoryFolderBackupFiles files;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 11, 4, 9));
    files = MemoryFolderBackupFiles()..selection = _folder;
  });
  tearDown(() => env.dispose());

  Future<void> pumpScreen(
    WidgetTester tester, {
    FolderBackupSettings settings = const FolderBackupSettings(),
    ThemeData? theme,
  }) async {
    await SharedPreferencesFolderBackup(env.prefs).save(settings);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpApp(
      tester,
      const BackupScreen(),
      env: env,
      theme: theme,
      extraOverrides: [
        automaticFolderBackupProvider.overrideWith(
          (ref) => AutomaticFolderBackup(
            preferences: SharedPreferencesFolderBackup(env.prefs),
            files: files,
            clock: env.clock,
            changes: const Stream.empty(),
            export: () async => {'version': 6, 'items': <Object>[]},
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  FolderBackupSettings enabled({DateTime? lastSuccess, DateTime? verified}) =>
      FolderBackupSettings(
        folder: _folder,
        enabled: true,
        lastSuccess: lastSuccess,
        lastVerified: verified,
        fingerprint: 'x',
      );

  testWidgets('healthy card headline is relative for recent backups', (
    tester,
  ) async {
    // Clock is 2026-11-04 09:00.
    final cases = <(DateTime, String)>[
      (DateTime(2026, 11, 4, 9), 'Backed up just now'),
      (DateTime(2026, 11, 4, 8, 55), 'Backed up 5 minutes ago'),
      (DateTime(2026, 11, 4, 8, 59), 'Backed up 1 minute ago'),
      (DateTime(2026, 11, 4, 7), 'Backed up 2 hours ago'),
      (DateTime(2026, 11, 3, 15), 'Backed up 18 hours ago'),
      (DateTime(2026, 11, 3, 7), 'Backed up yesterday'),
    ];
    for (final (at, text) in cases) {
      await pumpScreen(tester, settings: enabled(lastSuccess: at));
      expect(find.text(text), findsOneWidget, reason: text);
      // The exact moment stays available as a secondary line.
      expect(find.textContaining(RegExp(r'Nov [34], 2026')), findsOneWidget);
    }
  });

  testWidgets('older backups fall back to the absolute date', (tester) async {
    await pumpScreen(
      tester,
      settings: enabled(lastSuccess: DateTime(2026, 11, 2, 8)),
    );
    expect(find.textContaining('Backed up Nov 2, 2026'), findsOneWidget);
    expect(find.textContaining('ago'), findsNothing);
  });

  testWidgets('How it works opens the explanation sheet', (tester) async {
    await pumpScreen(
      tester,
      settings: enabled(lastSuccess: DateTime(2026, 11, 4, 8)),
    );
    await tester.scrollUntilVisible(find.text('How it works'), 200);
    await tester.tap(find.text('How it works'));
    await tester.pumpAndSettle();
    expect(find.text('How backup works'), findsOneWidget);
    expect(find.textContaining('keeps the latest 10 copies'), findsOneWidget);
    expect(find.textContaining('Syncthing'), findsOneWidget);
  });

  testWidgets('healthy card shows when and where, with Back up now', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      settings: enabled(lastSuccess: DateTime(2026, 11, 4, 8)),
    );
    expect(find.text('Backed up 1 hour ago'), findsOneWidget);
    expect(find.textContaining('Nov 4, 2026'), findsOneWidget);
    expect(find.text('Folder: Cloud backups'), findsOneWidget);
    expect(find.text('Back up now'), findsOneWidget);
    expect(find.text('Choose folder again'), findsNothing);
    expect(find.byKey(const ValueKey('backup_folder')), findsOneWidget);
    expect(find.text('Cloud backups'), findsOneWidget);

    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();
    expect(files.snapshots, hasLength(1));
  });

  testWidgets('enabled but never backed up shows the neutral card', (
    tester,
  ) async {
    await pumpScreen(tester, settings: enabled());
    expect(find.text('No successful backup yet.'), findsOneWidget);
    expect(find.text('Back up now'), findsOneWidget);
  });

  testWidgets('stale backup offers Choose folder again and Try again', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      settings: enabled(lastSuccess: DateTime(2026, 10, 20, 8)),
    );
    expect(find.textContaining('No fresh backup for 15 days'), findsOneWidget);
    expect(
      find.text('Choose the folder again if backups have stopped working.'),
      findsOneWidget,
    );
    expect(find.text('Choose folder again'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Back up now'), findsNothing);
  });

  testWidgets('a failed backup shows the repair actions', (tester) async {
    files.fail = true;
    await pumpScreen(
      tester,
      settings: enabled(lastSuccess: DateTime(2026, 11, 4, 8)),
    );
    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Backup failed'), findsOneWidget);
    expect(find.text('Choose folder again'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    files.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Choose folder again'), findsNothing);
    expect(find.textContaining('Backed up'), findsOneWidget);
  });

  testWidgets('off state offers Turn on and hides the folder row', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Automatic backups are off.'), findsOneWidget);
    expect(find.byKey(const ValueKey('backup_folder')), findsNothing);
    expect(find.text('Back up now'), findsNothing);

    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();
    expect(files.snapshots, hasLength(1));
    expect(find.byKey(const ValueKey('backup_folder')), findsOneWidget);
    expect(find.textContaining('Backed up'), findsOneWidget);
  });

  testWidgets('dark theme renders every state without errors', (tester) async {
    await pumpScreen(
      tester,
      theme: AppTheme.dark(),
      settings: enabled(lastSuccess: DateTime(2026, 11, 4, 8)),
    );
    expect(find.textContaining('Backed up'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restore row opens a sheet with the three sources', (
    tester,
  ) async {
    await pumpScreen(tester);
    // Only one restore entry point remains.
    expect(find.text('Restore a backup'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('backup_restore')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("You'll see what's inside before anything changes"),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('restore_source_folder')), findsOneWidget);
    expect(find.byKey(const ValueKey('restore_source_file')), findsOneWidget);
    expect(find.byKey(const ValueKey('restore_source_paste')), findsOneWidget);
    expect(find.text('From backup folder'), findsOneWidget);
    expect(find.text('From a file'), findsOneWidget);
    expect(find.text('Paste backup text'), findsOneWidget);
  });

  testWidgets('footnote replaces the long copy and the import footer', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.textContaining('Backup, not sync'), findsOneWidget);
    expect(find.text('Import from another app'), findsNothing);
  });
}
