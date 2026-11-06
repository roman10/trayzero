import 'package:cleartray/application/backup_prompt.dart';
import 'package:cleartray/core/folder_backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const folder = BackupFolder(handle: 'h', label: 'Backups');
  final now = DateTime.utc(2026, 11, 4, 12);

  FolderBackupSettings settings({
    bool enabled = true,
    BackupFolder? folder = folder,
    DateTime? lastSuccess,
    DateTime? lastVerified,
  }) => FolderBackupSettings(
    folder: folder,
    enabled: enabled,
    lastSuccess: lastSuccess,
    lastVerified: lastVerified,
  );

  group('evaluateBackupHealth', () {
    BackupHealth health(FolderBackupSettings s, {bool failed = false}) =>
        evaluateBackupHealth(settings: s, lastAttemptFailed: failed, now: now);

    test('off when disabled or without a folder', () {
      expect(
        health(settings(enabled: false, lastSuccess: now)),
        BackupHealth.off,
      );
      expect(health(settings(folder: null)), BackupHealth.off);
      // Even a failure is not shown when the user turned backups off.
      expect(health(settings(enabled: false), failed: true), BackupHealth.off);
    });

    test('ok when the last success is recent', () {
      expect(
        health(settings(lastSuccess: now.subtract(const Duration(days: 6)))),
        BackupHealth.ok,
      );
    });

    test('exactly seven days is still ok, beyond is stale', () {
      expect(
        health(settings(lastSuccess: now.subtract(const Duration(days: 7)))),
        BackupHealth.ok,
      );
      expect(
        health(
          settings(
            lastSuccess: now.subtract(const Duration(days: 7, minutes: 1)),
          ),
        ),
        BackupHealth.stale,
      );
    });

    test('a recent verification keeps an idle backup healthy', () {
      expect(
        health(
          settings(
            lastSuccess: now.subtract(const Duration(days: 30)),
            lastVerified: now.subtract(const Duration(hours: 5)),
          ),
        ),
        BackupHealth.ok,
      );
    });

    test('a failed last attempt wins over a recent success', () {
      expect(health(settings(lastSuccess: now), failed: true), BackupHealth.failed);
    });

    test('never succeeded yet is not stale', () {
      expect(health(settings()), BackupHealth.ok);
    });
  });

  group('parseSnapshotStamp', () {
    test('reads automatic snapshot names as UTC', () {
      expect(
        parseSnapshotStamp(
          'trayzero-auto-0123456789abcdef0123456789abcdef-20261016T123456789Z-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.json',
        ),
        DateTime.utc(2026, 10, 16, 12, 34, 56, 789),
      );
    });

    test('reads manual export names', () {
      expect(
        parseSnapshotStamp('trayzero-backup-2026-10-16T12-34-56.json'),
        DateTime(2026, 10, 16, 12, 34, 56),
      );
    });

    test('is null for unknown names and falls back to modified time', () {
      expect(parseSnapshotStamp('notes.json'), isNull);
      final modified = DateTime.utc(2026, 1, 2);
      expect(
        BackupSnapshot(id: 'x', name: 'notes.json', modified: modified).takenAt,
        modified,
      );
    });
  });

  group('shouldShowBackupPrompt', () {
    bool show({bool done = false, BackupFolder? folder, int items = 20}) =>
        shouldShowBackupPrompt(done: done, folder: folder, keptItems: items);

    test('appears once there is real data and no decision yet', () {
      expect(show(items: backupPromptMinItems), isTrue);
      expect(show(items: backupPromptMinItems - 1), isFalse);
    });

    test('never after dismissal', () {
      expect(show(done: true, items: 500), isFalse);
    });

    test('never when a backup folder was ever chosen', () {
      expect(show(folder: folder, items: 500), isFalse);
    });
  });
}
