import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/folder_backup.dart';
import '../data/providers.dart';
import 'backup_service.dart';

class FolderBackupState {
  const FolderBackupState({
    this.settings = const FolderBackupSettings(),
    this.busy = false,
    this.failed = false,
    this.historyWarning = false,
  });
  final FolderBackupSettings settings;
  final bool busy;
  final bool failed;
  final bool historyWarning;
}

const _verifyInterval = Duration(hours: 12);

/// Serializes configuration and writes. Only committed portable content is
/// observed; native calendar bookkeeping and appearance never trigger exports.
class AutomaticFolderBackup extends StateNotifier<FolderBackupState> {
  AutomaticFolderBackup({
    required FolderBackupPreferences preferences,
    required FolderBackupFiles files,
    required Future<Map<String, Object?>> Function() export,
    required Stream<void> changes,
    required Clock clock,
  }) : _preferences = preferences,
       _files = files,
       _export = export,
       _clock = clock,
       super(FolderBackupState(settings: preferences.load())) {
    _subscription = changes.listen((_) => _changed());
  }

  final FolderBackupPreferences _preferences;
  final FolderBackupFiles _files;
  final Future<Map<String, Object?>> Function() _export;
  final Clock _clock;
  late final StreamSubscription<void> _subscription;
  Future<void> _tail = Future.value();
  void Function()? _cancelDebounce;
  void Function()? _cancelDeadline;
  bool _scheduled = false;
  bool _saveRequested = false;
  bool _active = true;
  int _revision = 0;

  Future<void> _serial(Future<void> Function() action) {
    final next = _tail.then((_) async {
      if (!mounted) return;
      state = FolderBackupState(
        settings: state.settings,
        busy: true,
        failed: state.failed,
        historyWarning: state.historyWarning,
      );
      try {
        await action();
      } catch (_) {
        if (mounted) {
          state = FolderBackupState(settings: state.settings, failed: true);
        }
      } finally {
        if (mounted && state.busy) {
          state = FolderBackupState(
            settings: state.settings,
            failed: state.failed,
            historyWarning: state.historyWarning,
          );
        }
      }
    });
    _tail = next;
    return next;
  }

  Future<void> chooseFolder() => _serial(() async {
    final folder = await _files.chooseFolder();
    if (folder == null || !mounted) return;
    final old = state.settings.folder;
    final settings = FolderBackupSettings(folder: folder, enabled: true);
    try {
      await _preferences.save(settings);
    } catch (_) {
      if (folder.handle != old?.handle) await _release(folder);
      rethrow;
    }
    if (!mounted) return;
    state = FolderBackupState(settings: settings, busy: true);
    if (old != null && old.handle != folder.handle) await _release(old);
    await _save(force: true);
  });

  Future<void> _release(BackupFolder folder) async {
    try {
      await _files.releaseFolder(folder);
    } catch (_) {
      // Retiring an obsolete grant must not undo a saved folder selection.
    }
  }

  Future<void> setEnabled(bool enabled) => _serial(() async {
    if (enabled && state.settings.folder == null) return;
    final settings = state.settings.withEnabled(enabled);
    await _preferences.save(settings);
    if (!mounted) return;
    state = FolderBackupState(settings: settings, busy: true);
    _cancelScheduled();
    if (enabled) await _save(force: true);
  });

  Future<void> backUpNow() => _serial(() => _save(force: true));

  /// Startup/resume also compares content: edits committed before process death
  /// are recovered without depending on an exit callback or a dirty preference.
  Future<void> resume() {
    _active = true;
    return _requestSave();
  }

  Future<void> pause() {
    _active = false;
    _cancelScheduled();
    return _requestSave();
  }

  void _changed() {
    _revision++;
    if (!state.settings.enabled || !_active) return;
    _cancelDebounce?.call();
    _cancelDebounce = _clock.scheduleAt(
      _clock.now().add(const Duration(seconds: 5)),
      () {
        _cancelScheduled();
        unawaited(_requestSave());
      },
    );
    _cancelDeadline ??= _clock.scheduleAt(
      _clock.now().add(const Duration(minutes: 1)),
      () {
        _cancelScheduled();
        unawaited(_requestSave());
      },
    );
  }

  Future<void> _requestSave() {
    if (!mounted || !state.settings.enabled) return _tail;
    if (_scheduled) {
      _saveRequested = true;
      return _tail;
    }
    _scheduled = true;
    return _serial(() async {
      try {
        do {
          _saveRequested = false;
          final revision = _revision;
          await _save();
          // Background edits cannot rely on foreground debounce timers.
          if (!_active && _revision != revision) _saveRequested = true;
        } while (_saveRequested && mounted && state.settings.enabled);
      } finally {
        _scheduled = false;
      }
    });
  }

  Future<void> _save({bool force = false}) async {
    final settings = state.settings;
    final folder = settings.folder;
    if (!settings.enabled || folder == null) return;
    final revision = _revision;
    final snapshot = await _export();
    // Export order is immaterial; timestamp changes alone aren't user edits.
    final content = Map<String, Object?>.of(snapshot)..remove('exportedAt');
    for (final value in content.values.whereType<List>()) {
      value.sort(
        (a, b) =>
            (a as Map)['id'].toString().compareTo((b as Map)['id'].toString()),
      );
    }
    final fingerprint = sha256
        .convert(utf8.encode(jsonEncode(content)))
        .toString();
    if (!force && fingerprint == settings.fingerprint) {
      // Nothing to write: the newest snapshot already matches. Record that
      // check (at most every 12 hours) so an idle but healthy backup is not
      // reported as stale by the health indicator.
      final verified = settings.lastHealthy;
      var current = settings;
      if (verified == null ||
          _clock.now().difference(verified) >= _verifyInterval) {
        current = settings.withVerified(_clock.now());
        try {
          await _preferences.save(current);
        } catch (_) {
          current = settings; // Best effort; never fail a backup over this.
        }
      }
      if (!mounted) return;
      state = FolderBackupState(
        settings: current,
        historyWarning: state.historyWarning,
      );
      return;
    }
    final pruned = await _files.writeSnapshot(folder, jsonEncode(snapshot));
    final saved = FolderBackupSettings(
      folder: folder,
      enabled: true,
      lastSuccess: _clock.now(),
      fingerprint: fingerprint,
    );
    await _preferences.save(saved);
    if (!mounted) return;
    state = FolderBackupState(settings: saved, historyWarning: !pruned);
    // A concurrent edit must produce another snapshot, even after a slow write.
    if (_revision != revision) _changed();
  }

  void _cancelScheduled() {
    _cancelDebounce?.call();
    _cancelDeadline?.call();
    _cancelDebounce = null;
    _cancelDeadline = null;
  }

  @override
  void dispose() {
    _cancelScheduled();
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

final automaticFolderBackupProvider =
    StateNotifierProvider<AutomaticFolderBackup, FolderBackupState>((ref) {
      final db = ref.watch(databaseProvider);
      return AutomaticFolderBackup(
        preferences: ref.watch(folderBackupPreferencesProvider),
        files: ref.watch(folderBackupFilesProvider),
        export: () => ref.read(backupServiceProvider).export(),
        changes: db
            .tableUpdates(
              TableUpdateQuery.onAllTables([
                db.items,
                db.projects,
                db.contexts,
                db.areas,
                db.attachments,
                db.reviews,
                // Tags and assignments are portable content, and their writes
                // deliberately do not touch the owning Item's updatedAt.
                db.tags,
                db.itemTags,
              ]),
            )
            .map((_) {}),
        clock: ref.watch(clockProvider),
      );
    });

/// Quiet backup status for the More hub and Backup screen. Evaluated against
/// the current time whenever the backup state changes or a screen rebuilds it.
final backupHealthProvider = Provider<BackupHealth>((ref) {
  final state = ref.watch(automaticFolderBackupProvider);
  return evaluateBackupHealth(
    settings: state.settings,
    lastAttemptFailed: state.failed,
    now: ref.watch(clockProvider).now(),
  );
});
