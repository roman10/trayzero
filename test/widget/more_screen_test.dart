import 'dart:async';

import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/automatic_folder_backup.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/infrastructure/shared_preferences_folder_backup.dart';
import 'package:cleartray/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/folder_backup_fake.dart';
import '../support/harness.dart';

class _FailedBackup extends AutomaticFolderBackup {
  _FailedBackup(TestEnv env)
    : super(
        preferences: SharedPreferencesFolderBackup(env.prefs),
        files: MemoryFolderBackupFiles(),
        clock: env.clock,
        changes: const Stream.empty(),
        export: () async => {'version': 6, 'items': <Object>[]},
      ) {
    state = const FolderBackupState(failed: true);
  }
}

void main() {
  late TestEnv env;

  Future<ProviderContainer> boot(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    NotificationPermission permission = NotificationPermission.granted,
    bool backupFailed = false,
  }) async {
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
    env = await TestEnv.create(
      prefsValues: {'onboarding_complete_v1': true, ...prefs},
    );
    addTearDown(env.dispose);
    env.scheduler.status = permission;
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = env.container([
      if (backupFailed)
        automaticFolderBackupProvider.overrideWith((ref) => _FailedBackup(env)),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TrayzeroApp(),
      ),
    );
    container.read(routerProvider).go('/settings');
    await tester.pumpAndSettle();
    return container;
  }

  const noReminders = <String, Object>{
    'weekly_review_reminder_enabled': false,
    'reminder_lead_time_minutes': 0,
    'backup_reminder_enabled': false,
  };

  testWidgets('banner shows when notifications are blocked and a reminder is '
      'in use', (tester) async {
    await boot(tester, permission: NotificationPermission.permanentlyDenied);
    expect(find.text('Reminders are blocked'), findsOneWidget);
    expect(find.text('Fix'), findsOneWidget);
  });

  testWidgets('banner is hidden when blocked but no reminder is in use', (
    tester,
  ) async {
    await boot(
      tester,
      prefs: noReminders,
      permission: NotificationPermission.denied,
    );
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Reminders are blocked'), findsNothing);
    expect(find.text('Fix'), findsNothing);
  });

  testWidgets('banner is hidden when permission is granted', (tester) async {
    await boot(tester);
    expect(find.text('Fix'), findsNothing);
  });

  testWidgets('a backup reminder alone counts as a reminder in use', (
    tester,
  ) async {
    await boot(
      tester,
      prefs: {...noReminders, 'backup_reminder_enabled': true},
      permission: NotificationPermission.denied,
    );
    expect(find.text('Reminders are blocked'), findsOneWidget);
  });

  testWidgets('banner shows backup failure and Fix opens backup', (
    tester,
  ) async {
    final container = await boot(tester, backupFailed: true);
    expect(find.text('Backup failed'), findsWidgets);
    expect(find.text('Fix'), findsOneWidget);
    await tester.tap(find.text('Fix'));
    await tester.pumpAndSettle();
    expect(_location(container), '/settings/backup');
  });

  testWidgets('reminders banner wins over backup failure (max one)', (
    tester,
  ) async {
    await boot(
      tester,
      permission: NotificationPermission.denied,
      backupFailed: true,
    );
    expect(find.text('Fix'), findsOneWidget);
    expect(find.text('Reminders are blocked'), findsOneWidget);
  });

  testWidgets('each hub row navigates to its route', (tester) async {
    final container = await boot(tester);
    final rows = <String, String>{
      'Contexts': '/settings/contexts',
      'Tags & people': '/settings/tags',
      'Areas of focus': '/settings/areas',
      'Calendar connection': '/settings/calendar-sync',
      'Appearance': '/settings/appearance',
      'Reminders': '/settings/reminders',
      'Backup & restore': '/settings/backup',
      'Import from another app': '/settings/import',
      'Support Trayzero': '/settings/support',
      'About & privacy': '/settings/about',
    };
    // Some destinations (calendar sync) show a spinner, so pump a fixed time
    // instead of settling.
    Future<void> advance() async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    for (final MapEntry(key: label, value: route) in rows.entries) {
      await tester.tap(find.text(label).first);
      await advance();
      expect(_location(container), route, reason: label);
      container.read(routerProvider).pop();
      await advance();
      expect(_location(container), '/settings', reason: 'back from $label');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Language row opens the language sheet', (tester) async {
    await boot(tester);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.text('Deutsch'), findsOneWidget);
  });
}

String _location(ProviderContainer c) => c
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;
