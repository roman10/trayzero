import 'dart:convert';

import '../core/result.dart';
import 'backup_service.dart';
import 'google_tasks_import.dart';

/// Entity counts found in a backup blob, used to preview an import before
/// any rows are written.
final class BackupPreview {
  const BackupPreview({
    required this.contexts,
    required this.areas,
    required this.projects,
    required this.items,
  });
  final int contexts;
  final int areas;
  final int projects;
  final int items;

  int get total => contexts + areas + projects + items;
  bool get isEmpty => total == 0;
}

/// Restores a previously-exported JSON blob via [BackupService.import].
///
/// [inspect] validates and counts a blob without writing anything, so the
/// UI can confirm with the user before the (irreversible, upsert-based)
/// import. [call] performs the actual restore.
final class ImportBackup {
  ImportBackup({required BackupService backup}) : _backup = backup;
  final BackupService _backup;

  /// Validates and counts a backup without touching the database.
  Result<BackupPreview, String> inspect(String json) {
    final parsed = _parse(json);
    return switch (parsed) {
      Err(:final error) => Err(error),
      Ok(:final value) => Ok(_countsOf(value)),
    };
  }

  /// Restores the backup. Returns the number of rows added or updated.
  Future<Result<int, String>> call(String json) async {
    final parsed = _parse(json);
    switch (parsed) {
      case Err(:final error):
        return Err(error);
      case Ok(:final value):
        try {
          final n = await _backup.import(value);
          return Ok(n);
        } on Object catch (e) {
          return Err('Something went wrong while restoring: $e');
        }
    }
  }

  /// Parses and validates the blob into a backup map, or a user-facing
  /// error explaining why it can't be imported.
  Result<Map<String, Object?>, String> _parse(String json) {
    if (json.trim().isEmpty) {
      return const Err('The backup is empty — nothing to import.');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return const Err(
        "This isn't valid JSON. Make sure you selected a complete, "
        'unedited Trayzero backup file.',
      );
    }
    if (decoded is! Map<String, Object?>) {
      return const Err('This file is not a Trayzero backup.');
    }
    // A Google Takeout Tasks export is converted up-front to a Trayzero
    // backup so the rest of the pipeline (preview, confirm, restore) is
    // unchanged. The use case has no clock injected; DateTime.now() is the
    // fallback for tasks missing a timestamp.
    var raw = decoded;
    if (isGoogleTasksExport(raw)) {
      raw = convertGoogleTasksExport(raw, fallback: DateTime.now());
    }
    final version = raw['version'];
    if (version is int && version > BackupService.formatVersion) {
      return const Err(
        'This backup was created by a newer version of the app. '
        'Update Trayzero, then try importing again.',
      );
    }
    const keys = ['contexts', 'areas', 'projects', 'items'];
    if (!keys.any(raw.containsKey)) {
      return const Err(
        "This file doesn't look like a Trayzero backup.",
      );
    }
    return Ok(raw);
  }

  BackupPreview _countsOf(Map<String, Object?> raw) {
    // A backup may parse as JSON yet carry a non-list value here
    // (e.g. "items": 5); treat anything that isn't a list as empty
    // rather than throwing out of the unguarded inspect() path.
    int len(String key) => raw[key] is List ? (raw[key]! as List).length : 0;
    return BackupPreview(
      contexts: len('contexts'),
      areas: len('areas'),
      projects: len('projects'),
      items: len('items'),
    );
  }
}
