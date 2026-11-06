// Run on a disposable emulator/simulator. Select a dedicated QA folder when
// prompted. This exercises the real OS picker, bookmark/grant and publication.
// Use a retained QA installation (flutter run / adb install). Relaunch the same
// binary to reuse the saved grant/bookmark after process death. flutter test
// removes the app after its run, so it cannot check this cross-process phase.
import 'dart:convert';
import 'dart:io';

import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/infrastructure/device_folder_backup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'folder permission survives restart; snapshots publish and prune',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Choose a dedicated folder for backup QA'),
            ),
          ),
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      const files = DeviceFolderBackup();
      final reuse = prefs.getString('qa_backup_folder') != null;
      final BackupFolder? folder;
      if (reuse) {
        folder = BackupFolder(
          handle: prefs.getString('qa_backup_folder')!,
          label: 'QA',
        );
      } else {
        folder = await files.chooseFolder();
        expect(folder, isNotNull);
        await prefs.setString('qa_backup_folder', folder!.handle);
      }
      for (var i = 0; i < 12; i++) {
        expect(
          await files.writeSnapshot(
            folder,
            jsonEncode({
              'version': 6,
              'exportedAt': DateTime.now().toUtc().toIso8601String(),
              'items': <Object>[],
              'contexts': <Object>[],
              'areas': <Object>[],
              'projects': <Object>[],
              'attachments': <Object>[],
              'reviews': <Object>[],
              'qaIteration': i,
            }),
          ),
          true,
        );
      }
      // Android can revoke the saved grant in-app. iOS bookmarks have no matching
      // revoke operation; provider removal is checked separately on hardware.
      if (reuse && Platform.isAndroid) {
        await files.releaseFolder(folder);
        await expectLater(
          files.writeSnapshot(folder, '{}'),
          throwsA(isA<PlatformException>()),
        );
        await prefs.remove('qa_backup_folder');
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
