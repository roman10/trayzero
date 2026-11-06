import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/folder_backup.dart';
import '../core/result.dart';
import 'automatic_folder_backup.dart';
import 'import_backup.dart';
import 'providers.dart';

/// One backup file in the folder, with its contents summarized once read.
class RestoreEntry {
  const RestoreEntry({
    required this.snapshot,
    this.preview,
    this.unreadable = false,
  });
  final BackupSnapshot snapshot;

  /// Counts found in the file; null while loading or when [unreadable].
  final BackupPreview? preview;

  /// The file could not be read or is not a Trayzero backup.
  final bool unreadable;

  bool get loading => preview == null && !unreadable;
}

class FolderRestoreState {
  const FolderRestoreState({
    this.folder,
    this.loading = false,
    this.failed = false,
    this.entries = const [],
  });
  final BackupFolder? folder;

  /// The folder listing is in flight.
  final bool loading;

  /// The folder could not be opened or listed (revoked access, offline
  /// provider). The user can pick a different folder.
  final bool failed;
  final List<RestoreEntry> entries;

  bool get listed => folder != null && !loading && !failed;
}

/// Newest snapshots shown. A folder replicated from several devices can hold
/// dozens of files; older ones are rarely what someone restoring wants.
const maxRestoreEntries = 30;

/// Lists and restores backup snapshots from a folder (ADR 0013). Restoring
/// goes through [ImportBackup], so it keeps the merge semantics of the manual
/// restore: matching ids are updated and omitted rows are not deleted.
class FolderRestoreController extends StateNotifier<FolderRestoreState> {
  FolderRestoreController({
    required FolderBackupFiles files,
    required ImportBackup importer,
    required BackupFolder? Function() configuredFolder,
  }) : _files = files,
       _importer = importer,
       _configuredFolder = configuredFolder,
       super(const FolderRestoreState());

  final FolderBackupFiles _files;
  final ImportBackup _importer;
  final BackupFolder? Function() _configuredFolder;
  BackupFolder? _transient;
  int _generation = 0;

  /// Lists the folder already used for automatic backups.
  Future<void> useConfiguredFolder() async {
    final folder = _configuredFolder();
    if (folder != null) await _load(folder);
  }

  /// Opens the system folder picker and lists what it finds. Cancelling keeps
  /// the current list.
  Future<void> chooseFolder() async {
    final BackupFolder? picked;
    try {
      picked = await _files.chooseFolder();
    } catch (_) {
      if (mounted) state = const FolderRestoreState(failed: true);
      return;
    }
    if (picked == null || !mounted) return;
    final previous = _transient;
    _transient = picked;
    if (previous != null && previous.handle != picked.handle) {
      await _releaseIfUnused(previous);
    }
    await _load(picked);
  }

  Future<void> _load(BackupFolder folder) async {
    final generation = ++_generation;
    state = FolderRestoreState(folder: folder, loading: true);
    final List<BackupSnapshot> snapshots;
    try {
      snapshots = await _files.listSnapshots(folder);
    } catch (_) {
      if (mounted && generation == _generation) {
        state = FolderRestoreState(folder: folder, failed: true);
      }
      return;
    }
    if (!mounted || generation != _generation) return;
    // Files without any known date sort last.
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final sorted = [...snapshots]
      ..sort((a, b) => (b.takenAt ?? epoch).compareTo(a.takenAt ?? epoch));
    final shown = sorted.take(maxRestoreEntries).toList();
    state = FolderRestoreState(
      folder: folder,
      entries: [for (final s in shown) RestoreEntry(snapshot: s)],
    );
    for (var i = 0; i < shown.length; i++) {
      final entry = await _summarize(folder, shown[i]);
      if (!mounted || generation != _generation) return;
      final entries = [...state.entries];
      entries[i] = entry;
      state = FolderRestoreState(folder: folder, entries: entries);
    }
  }

  Future<RestoreEntry> _summarize(
    BackupFolder folder,
    BackupSnapshot snapshot,
  ) async {
    try {
      final raw = await _files.readSnapshot(folder, snapshot);
      return switch (_importer.inspect(raw)) {
        Ok(:final value) => RestoreEntry(snapshot: snapshot, preview: value),
        Err() => RestoreEntry(snapshot: snapshot, unreadable: true),
      };
    } catch (_) {
      return RestoreEntry(snapshot: snapshot, unreadable: true);
    }
  }

  /// Re-reads [entry] and restores it through the shared restore path. The
  /// UI localizes the [BackupImportError]; its detail is for logs only.
  Future<Result<int, BackupImportError>> restore(RestoreEntry entry) async {
    final folder = state.folder;
    if (folder == null) {
      return const Err(
        BackupImportError(
          BackupImportFailure.restoreFailed,
          'No backup folder is selected.',
        ),
      );
    }
    final String raw;
    try {
      raw = await _files.readSnapshot(folder, entry.snapshot);
    } catch (e) {
      return Err(
        BackupImportError(
          BackupImportFailure.restoreFailed,
          'The backup file could not be read: $e',
        ),
      );
    }
    return _importer.call(raw);
  }

  Future<void> _releaseIfUnused(BackupFolder folder) async {
    // Never drop a grant that automatic backups still depend on.
    try {
      if (_configuredFolder()?.handle == folder.handle) return;
    } catch (_) {
      return; // App is shutting down; keeping a grant is always safe.
    }
    try {
      await _files.releaseFolder(folder);
    } catch (_) {
      // A leftover read grant is harmless.
    }
  }

  @override
  void dispose() {
    final transient = _transient;
    if (transient != null) unawaited(_releaseIfUnused(transient));
    super.dispose();
  }
}

final folderRestoreControllerProvider =
    StateNotifierProvider.autoDispose<
      FolderRestoreController,
      FolderRestoreState
    >(
      (ref) => FolderRestoreController(
        files: ref.watch(folderBackupFilesProvider),
        importer: ref.watch(importBackupProvider),
        configuredFolder: () =>
            ref.read(automaticFolderBackupProvider).settings.folder,
      ),
    );
