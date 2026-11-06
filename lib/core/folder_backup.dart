import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opaque OS permission/bookmark. It must never be treated as a filesystem path.
class BackupFolder {
  const BackupFolder({required this.handle, required this.label});
  final String handle;
  final String label;
}

/// A backup file found in a chosen folder. [id] is opaque (a document URI on
/// Android, a file name on iOS) and is only meaningful to the adapter that
/// produced it.
class BackupSnapshot {
  const BackupSnapshot({required this.id, required this.name, this.modified});
  final String id;
  final String name;
  final DateTime? modified;

  /// When the snapshot was taken: the UTC stamp in the file name written by
  /// this app (`...20261016T123456789Z...` or `trayzero-backup-2026-10-16T12-34-56`),
  /// else the provider's modified time. Null when neither is known.
  DateTime? get takenAt => parseSnapshotStamp(name) ?? modified;
}

final _autoStamp = RegExp(
  r'(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(\d{3})Z',
);
final _manualStamp = RegExp(
  r'trayzero-backup-(\d{4})-(\d{2})-(\d{2})T(\d{2})-(\d{2})-(\d{2})',
);

/// Parses the timestamp embedded in a Trayzero backup file name. Manual
/// exports are named with the device's local time, automatic ones with UTC.
DateTime? parseSnapshotStamp(String name) {
  final auto = _autoStamp.firstMatch(name);
  if (auto != null) {
    final g = [for (var i = 1; i <= 7; i++) int.parse(auto.group(i)!)];
    return DateTime.utc(g[0], g[1], g[2], g[3], g[4], g[5], g[6]);
  }
  final manual = _manualStamp.firstMatch(name);
  if (manual != null) {
    final g = [for (var i = 1; i <= 6; i++) int.parse(manual.group(i)!)];
    return DateTime(g[0], g[1], g[2], g[3], g[4], g[5]);
  }
  return null;
}

class FolderBackupSettings {
  const FolderBackupSettings({
    this.folder,
    this.enabled = false,
    this.lastSuccess,
    this.fingerprint,
    this.lastVerified,
  });
  final BackupFolder? folder;
  final bool enabled;
  final DateTime? lastSuccess;
  final String? fingerprint;

  /// Last time the app confirmed the newest snapshot still matches the data
  /// (nothing needed writing). Keeps an idle-but-healthy backup from looking
  /// stale; [lastSuccess] stays the time a file was actually written.
  final DateTime? lastVerified;

  /// Most recent evidence that the folder holds an up-to-date backup.
  DateTime? get lastHealthy {
    final a = lastSuccess;
    final b = lastVerified;
    if (a == null || b == null) return a ?? b;
    return a.isAfter(b) ? a : b;
  }

  FolderBackupSettings withEnabled(bool value) => FolderBackupSettings(
    folder: folder,
    enabled: value,
    lastSuccess: lastSuccess,
    fingerprint: fingerprint,
    lastVerified: lastVerified,
  );

  FolderBackupSettings withVerified(DateTime when) => FolderBackupSettings(
    folder: folder,
    enabled: enabled,
    lastSuccess: lastSuccess,
    fingerprint: fingerprint,
    lastVerified: when,
  );
}

/// Quiet status shown outside the Backup screen.
enum BackupHealth { off, ok, failed, stale }

/// Automatic backups are "stale" when nothing has confirmed an up-to-date
/// snapshot for this long.
const backupStaleAfter = Duration(days: 7);

BackupHealth evaluateBackupHealth({
  required FolderBackupSettings settings,
  required bool lastAttemptFailed,
  required DateTime now,
}) {
  if (!settings.enabled || settings.folder == null) return BackupHealth.off;
  if (lastAttemptFailed) return BackupHealth.failed;
  final healthy = settings.lastHealthy;
  if (healthy != null && now.difference(healthy) > backupStaleAfter) {
    return BackupHealth.stale;
  }
  return BackupHealth.ok;
}

abstract class FolderBackupPreferences {
  FolderBackupSettings load();
  Future<void> save(FolderBackupSettings settings);
}

abstract class FolderBackupFiles {
  Future<BackupFolder?> chooseFolder();

  /// Publishes a new complete JSON file before pruning to ten snapshots owned
  /// by this installation. Other devices' files are never replaced or pruned.
  /// Returns false if publication succeeded but history cleanup failed.
  Future<bool> writeSnapshot(BackupFolder folder, String contents);
  Future<void> releaseFolder(BackupFolder folder);

  /// Lists Trayzero backup files in [folder] (any installation), unsorted.
  Future<List<BackupSnapshot>> listSnapshots(BackupFolder folder);

  /// Reads one listed snapshot as UTF-8 text.
  Future<String> readSnapshot(BackupFolder folder, BackupSnapshot snapshot);
}

final folderBackupPreferencesProvider = Provider<FolderBackupPreferences>(
  (ref) => throw UnimplementedError('Override at bootstrap'),
);
final folderBackupFilesProvider = Provider<FolderBackupFiles>(
  (ref) => throw UnimplementedError('Override at bootstrap'),
);
