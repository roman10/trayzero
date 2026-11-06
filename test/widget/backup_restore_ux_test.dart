import 'dart:convert';

import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/automatic_folder_backup.dart';
import 'package:cleartray/application/backup_prompt.dart';
import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/onboarding/onboarding_screen.dart';
import 'package:cleartray/features/settings/restore_from_folder_screen.dart';
import 'package:cleartray/features/settings/settings_screen.dart';
import 'package:cleartray/infrastructure/shared_preferences_folder_backup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/folder_backup_fake.dart';
import '../support/harness.dart';

const _folder = BackupFolder(handle: 'tree', label: 'Cloud backups');

String _backup(int items) => jsonEncode({
  'version': BackupService.formatVersion,
  'items': [
    for (var i = 0; i < items; i++) {'id': 'r$i', 'title': 'Restored $i'},
  ],
});

void main() {
  late TestEnv env;
  late MemoryFolderBackupFiles files;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 11, 4, 9));
    files = MemoryFolderBackupFiles()..selection = _folder;
  });
  tearDown(() => env.dispose());

  Override backupOverride() => automaticFolderBackupProvider.overrideWith(
    (ref) => AutomaticFolderBackup(
      preferences: SharedPreferencesFolderBackup(env.prefs),
      files: files,
      clock: env.clock,
      changes: const Stream.empty(),
      export: () async => {'version': 6, 'items': <Object>[]},
    ),
  );

  Future<void> seedItems(int n) => ItemRepository(env.db, env.clock).upsertAll([
    for (var i = 0; i < n; i++) anItem(id: 'seed$i', title: 'Seed $i'),
  ]);

  Future<ProviderContainer> bootApp(
    WidgetTester tester, {
    required Map<String, Object> prefs,
    String? go,
    List<String> snapshots = const [],
  }) async {
    ReceiveSharingIntent.setMockValues(
      initialMedia: [],
      mediaStream: const Stream.empty(),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Trayzero',
      packageName: 'app.cleartray',
      version: '1.0.7',
      buildNumber: '1',
      buildSignature: '',
    );
    await env.dispose();
    env = await TestEnv.create(now: DateTime(2026, 11, 4, 9), prefsValues: prefs);
    files = MemoryFolderBackupFiles()
      ..selection = _folder
      ..snapshots.addAll(snapshots);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = env.container([
      backupOverride(),
      folderBackupFilesProvider.overrideWithValue(files),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TrayzeroApp(),
      ),
    );
    if (go != null) container.read(routerProvider).go(go);
    await tester.pumpAndSettle();
    return container;
  }

  group('enable prompt', () {
    testWidgets('hidden below the item threshold', (tester) async {
      await seedItems(backupPromptMinItems - 1);
      await pumpApp(
        tester,
        const InboxScreen(),
        env: env,
        extraOverrides: [backupOverride()],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsNothing);
    });

    testWidgets('shown at the threshold; dismissing hides it for good', (
      tester,
    ) async {
      await seedItems(backupPromptMinItems);
      await pumpApp(
        tester,
        const InboxScreen(),
        env: env,
        extraOverrides: [backupOverride()],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('backup_prompt_dismiss')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsNothing);
      expect(env.prefs.getBool('backup_prompt_done_v1'), isTrue);
      expect(files.snapshots, isEmpty);
    });

    testWidgets('stays hidden after a restart once dismissed', (tester) async {
      await env.prefs.setBool('backup_prompt_done_v1', true);
      await seedItems(backupPromptMinItems + 5);
      await pumpApp(
        tester,
        const InboxScreen(),
        env: env,
        extraOverrides: [backupOverride()],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsNothing);
    });

    testWidgets('choosing a folder enables backups and retires the prompt', (
      tester,
    ) async {
      await seedItems(backupPromptMinItems);
      late ProviderContainer container;
      await pumpApp(
        tester,
        Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const InboxScreen();
          },
        ),
        env: env,
        extraOverrides: [backupOverride()],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('backup_prompt_enable')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsNothing);
      expect(
        container.read(automaticFolderBackupProvider).settings.enabled,
        isTrue,
      );
      expect(files.snapshots, hasLength(1));
      expect(env.prefs.getBool('backup_prompt_done_v1'), isTrue);
    });

    testWidgets('cancelling the picker keeps the prompt available', (
      tester,
    ) async {
      await seedItems(backupPromptMinItems);
      files.selection = null;
      await pumpApp(
        tester,
        const InboxScreen(),
        env: env,
        extraOverrides: [backupOverride()],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('backup_prompt_enable')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsOneWidget);
      expect(env.prefs.getBool('backup_prompt_done_v1'), isNull);
    });

    testWidgets('never shown when automatic backups were already set up', (
      tester,
    ) async {
      await seedItems(backupPromptMinItems);
      await SharedPreferencesFolderBackup(env.prefs).save(
        FolderBackupSettings(
          folder: _folder,
          enabled: false,
          lastSuccess: env.clock.now(),
        ),
      );
      await pumpApp(
        tester,
        const InboxScreen(),
        env: env,
        extraOverrides: [backupOverride()],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup_prompt')), findsNothing);
    });
  });

  group('health indicator', () {
    Map<String, Object> backupPrefs(DateTime lastSuccess) => {
      'onboarding_complete_v1': true,
      'backup_reminder_enabled': false,
      'weekly_review_reminder_enabled': false,
      'reminder_lead_time_minutes': 0,
      SharedPreferencesFolderBackup.key: jsonEncode({
        'handle': 'tree',
        'label': 'Cloud backups',
        'enabled': true,
        'lastSuccess': lastSuccess.toUtc().toIso8601String(),
        'fingerprint': 'x',
      }),
    };

    testWidgets('More shows a quiet warning when the last backup is old', (
      tester,
    ) async {
      final now = DateTime(2026, 11, 4, 9);
      final container = await bootApp(
        tester,
        prefs: backupPrefs(now.subtract(const Duration(days: 9))),
        go: '/settings',
      );
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
        find.textContaining('No fresh backup for 9 days'),
        findsOneWidget,
      );
      // Quiet: no loud failure banner.
      expect(find.text('Backup failed'), findsNothing);
      expect(container.read(backupHealthProvider), BackupHealth.stale);
    });

    testWidgets('a recent backup shows no warning', (tester) async {
      final now = DateTime(2026, 11, 4, 9);
      await bootApp(
        tester,
        prefs: backupPrefs(now.subtract(const Duration(days: 2))),
        go: '/settings',
      );
      expect(find.textContaining('No fresh backup'), findsNothing);
    });

    testWidgets('Backup screen explains and offers repair when stale', (
      tester,
    ) async {
      final now = DateTime(2026, 11, 4, 9);
      await bootApp(
        tester,
        prefs: backupPrefs(now.subtract(const Duration(days: 12))),
        go: '/settings/backup',
      );
      expect(find.textContaining('No fresh backup for 12 days'), findsOneWidget);
      expect(
        find.text('Choose the folder again if backups have stopped working.'),
        findsOneWidget,
      );
      expect(find.textContaining('Backup, not sync'), findsOneWidget);
    });
  });

  group('restore from folder', () {
    testWidgets('onboarding offers restore on the first page only', (
      tester,
    ) async {
      await pumpApp(tester, const OnboardingScreen(), env: env);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding_restore')), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding_restore')), findsNothing);
    });

    testWidgets('onboarding restore lists, confirms, restores, and finishes', (
      tester,
    ) async {
      final container = await bootApp(
        tester,
        prefs: {},
        snapshots: [_backup(2), _backup(4)],
      );
      expect(
        find.text('Coming from another device? Restore a backup'),
        findsOneWidget,
      );
      // The device has no configured folder, so the user picks one.
      await tester.tap(find.byKey(const ValueKey('onboarding_restore')));
      await tester.pumpAndSettle();
      expect(find.byType(RestoreFromFolderScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('restore_auto-0')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('restore_choose_folder')));
      await tester.pumpAndSettle();
      expect(find.text('Folder: Cloud backups'), findsOneWidget);
      // Newest first, with item counts.
      expect(find.text('4 items'), findsOneWidget);
      expect(find.text('2 items'), findsOneWidget);
      final rows = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .where((t) => t.key.toString().contains('restore_auto'))
          .map((t) => (t.subtitle! as Text).data)
          .toList();
      expect(rows, ['2 items', '4 items'].reversed.toList());

      await tester.tap(find.byKey(const ValueKey('restore_auto-1')));
      await tester.pumpAndSettle();
      expect(find.text('Import this backup?'), findsOneWidget);
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.last
            .matchedLocation,
        '/inbox',
      );
      expect(env.prefs.getBool('onboarding_complete_v1'), isTrue);
      final restored = await ItemRepository(env.db, env.clock).allActive();
      expect(restored.map((i) => i.title), contains('Restored 3'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('uses the configured folder straight away', (tester) async {
      await bootApp(
        tester,
        snapshots: [_backup(7)],
        prefs: {
          'onboarding_complete_v1': true,
          SharedPreferencesFolderBackup.key: jsonEncode({
            'handle': 'tree',
            'label': 'Cloud backups',
            'enabled': true,
            'lastSuccess': DateTime(2026, 11, 4, 8).toUtc().toIso8601String(),
          }),
        },
        go: '/settings/backup/restore',
      );
      expect(find.text('7 items'), findsOneWidget);
      expect(find.text('Folder: Cloud backups'), findsOneWidget);
    });

    testWidgets('shows an empty and a failed folder state', (tester) async {
      await bootApp(tester, prefs: {'onboarding_complete_v1': true},
          go: '/settings/backup/restore');
      await tester.tap(find.byKey(const ValueKey('restore_choose_folder')));
      await tester.pumpAndSettle();
      expect(find.text('No Trayzero backups found in this folder.'), findsOneWidget);

      files.listFails = true;
      await tester.tap(find.byKey(const ValueKey('restore_choose_folder')));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't open this folder"), findsOneWidget);
    });
  });
}
