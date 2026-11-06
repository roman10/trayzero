import 'dart:async';
import 'dart:convert';

import 'package:cleartray/application/automatic_folder_backup.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/folder_backup.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/folder_backup_fake.dart';

void main() {
  const folder = BackupFolder(handle: 'permission', label: 'My backups');
  late MemoryFolderBackupPreferences prefs;
  late MemoryFolderBackupFiles files;
  late FakeClock clock;
  late StreamController<void> changes;
  late AutomaticFolderBackup controller;
  var title = 'Before';
  var exports = 0;
  bool exportFails = false;

  Future<void> settle() => Future<void>.delayed(Duration.zero);
  Future<void> enable() async {
    files.selection = folder;
    await controller.chooseFolder();
  }

  void edit() {
    changes.add(null);
  }

  setUp(() {
    prefs = MemoryFolderBackupPreferences();
    files = MemoryFolderBackupFiles();
    clock = FakeClock(DateTime.utc(2026, 10, 16));
    changes = StreamController<void>.broadcast(sync: true);
    title = 'Before';
    exports = 0;
    exportFails = false;
    controller = AutomaticFolderBackup(
      preferences: prefs,
      files: files,
      clock: clock,
      changes: changes.stream,
      export: () async {
        exports++;
        if (exportFails) throw StateError('Missing attachment');
        return {
          'version': 6,
          'exportedAt': clock.now().toIso8601String(),
          'items': [
            {'id': 'one', 'title': title},
          ],
          'attachments': [
            {'id': 'photo', 'data': 'AAE='},
          ],
        };
      },
    );
  });
  tearDown(() async {
    controller.dispose();
    await changes.close();
  });

  test('opt-in only; cancellation has no side effects', () async {
    await controller.resume();
    edit();
    clock.advance(const Duration(minutes: 2));
    await controller.chooseFolder();
    expect(exports, 0);
    expect(files.snapshots, isEmpty);
    expect(prefs.settings.enabled, false);
    expect(controller.state.failed, false);
  });

  test(
    'selection saves immediately with portable media, and manual save forces a snapshot',
    () async {
      await enable();
      expect(prefs.settings.folder!.handle, folder.handle);
      expect(prefs.settings.lastSuccess, clock.now());
      expect(
        jsonDecode(files.snapshots.single)['attachments'][0]['data'],
        'AAE=',
      );
      await controller.backUpNow();
      expect(files.snapshots, hasLength(2));
    },
  );

  test(
    'resume ignores timestamp churn but catches edits missed before termination',
    () async {
      await enable();
      controller.dispose();
      controller = AutomaticFolderBackup(
        preferences: prefs,
        files: files,
        clock: clock,
        changes: changes.stream,
        export: () async => {
          ...jsonDecode(files.snapshots.first) as Map<String, dynamic>,
          'exportedAt': 'different',
          'items': [
            {'id': 'one', 'title': title},
          ],
        },
      );
      await controller.resume();
      expect(files.snapshots, hasLength(1));
      title = 'Changed while app was dead';
      await controller.resume();
      expect(files.snapshots, hasLength(2));
    },
  );

  test(
    'edits are debounced and continuous edits flush within one minute',
    () async {
      await enable();
      title = 'After';
      edit();
      clock.advance(const Duration(seconds: 4));
      await settle();
      expect(files.snapshots, hasLength(1));
      edit();
      clock.advance(const Duration(seconds: 5));
      await settle();
      expect(files.snapshots, hasLength(2));
      title = 'Continuous';
      for (var i = 0; i < 16; i++) {
        edit();
        clock.advance(const Duration(seconds: 4));
        await settle();
      }
      expect(files.snapshots, hasLength(3));
    },
  );

  test(
    'background save flushes pending edits; disabled backups stay off across resume',
    () async {
      await enable();
      title = 'Background';
      edit();
      await controller.pause();
      expect(files.snapshots, hasLength(2));
      await controller.setEnabled(false);
      title = 'Disabled';
      edit();
      clock.advance(const Duration(minutes: 2));
      await controller.resume();
      expect(files.snapshots, hasLength(2));
      expect(prefs.settings.enabled, false);
    },
  );

  test(
    'folder or export failures preserve last success and retry on resume',
    () async {
      await enable();
      final success = prefs.settings.lastSuccess;
      final fingerprint = prefs.settings.fingerprint;
      title = 'Retry';
      files.fail = true;
      await controller.backUpNow();
      expect(controller.state.failed, true);
      expect(prefs.settings.lastSuccess, success);
      expect(prefs.settings.fingerprint, fingerprint);
      files.fail = false;
      exportFails = true;
      await controller.resume();
      expect(controller.state.failed, true);
      expect(files.snapshots, hasLength(1));
      exportFails = false;
      await controller.resume();
      expect(controller.state.failed, false);
      expect(files.snapshots, hasLength(2));
    },
  );

  test(
    'edits during an in-flight write get a follow-up; saves do not overlap',
    () async {
      await enable();
      files.writeGate = Completer<void>();
      title = 'First';
      final saving = controller.backUpNow();
      await settle();
      title = 'Second';
      edit();
      clock.advance(const Duration(seconds: 5));
      await settle();
      expect(files.snapshots, hasLength(1));
      files.writeGate!.complete();
      await saving;
      await settle();
      expect(files.snapshots, hasLength(3));
      expect(jsonDecode(files.snapshots.last)['items'][0]['title'], 'Second');
    },
  );

  test('pause during an automatic write flushes the newest content', () async {
    await enable();
    files.writeGate = Completer<void>();
    title = 'First';
    final saving = controller.resume();
    await settle();
    title = 'Latest';
    edit();
    final paused = controller.pause();
    files.writeGate!.complete();
    await saving;
    await paused;
    expect(files.snapshots, hasLength(3));
    expect(jsonDecode(files.snapshots.last)['items'][0]['title'], 'Latest');
  });

  test('preference failure rolls back disable and folder selection', () async {
    await enable();
    prefs.fail = true;
    await controller.setEnabled(false);
    expect(controller.state.settings.enabled, true);
    expect(controller.state.failed, true);
    files.selection = const BackupFolder(handle: 'other', label: 'Other');
    await controller.chooseFolder();
    expect(controller.state.settings.folder!.handle, folder.handle);
    expect(files.released, ['other']);
    expect(files.snapshots, hasLength(1));
  });

  test(
    'switching folders resets fingerprint and releases only the old grant',
    () async {
      await enable();
      files.selection = const BackupFolder(handle: 'other', label: 'Other');
      await controller.chooseFolder();
      expect(files.folders, ['permission', 'other']);
      expect(files.released, ['permission']);
    },
  );

  test(
    'cleanup failure keeps a successful backup and surfaces a warning',
    () async {
      files.pruned = false;
      await enable();
      expect(controller.state.historyWarning, true);
      expect(controller.state.failed, false);
      expect(prefs.settings.lastSuccess, clock.now());
    },
  );

  test(
    'an unchanged check records a verification so idle backups stay healthy',
    () async {
      await enable();
      final firstSuccess = prefs.settings.lastSuccess;
      clock.advance(const Duration(days: 10));
      await controller.resume();
      await settle();
      // Nothing changed: no new file, but the check itself is on record.
      expect(files.snapshots, hasLength(1));
      expect(prefs.settings.lastSuccess, firstSuccess);
      expect(prefs.settings.lastVerified, clock.now());
      expect(
        evaluateBackupHealth(
          settings: prefs.settings,
          lastAttemptFailed: controller.state.failed,
          now: clock.now(),
        ),
        BackupHealth.ok,
      );
      // Frequent resumes do not rewrite preferences every time.
      clock.advance(const Duration(hours: 1));
      await controller.resume();
      await settle();
      expect(prefs.settings.lastVerified, isNot(clock.now()));
    },
  );

  test('a failed verification write never fails the backup', () async {
    await enable();
    clock.advance(const Duration(days: 10));
    prefs.fail = true;
    await controller.resume();
    await settle();
    expect(controller.state.failed, false);
  });
}
