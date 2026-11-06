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
    this.attachments = 0,
    this.reviews = 0,
  });
  final int contexts;
  final int areas;
  final int projects;
  final int items;
  final int attachments;
  final int reviews;

  int get total => contexts + areas + projects + items + attachments + reviews;
  bool get isEmpty => total == 0;
}

/// Why a backup could not be inspected or restored. The UI maps each to a
/// localized message; [BackupImportError.detail] is for logs only.
enum BackupImportFailure {
  empty,
  invalidJson,
  notBackup,
  newerVersion,
  unrecognized,
  invalidData,
  remindersNotRefreshed,
  restoreFailed,
}

final class BackupImportError {
  const BackupImportError(this.failure, [this.detail]);
  final BackupImportFailure failure;

  /// Raw technical detail (exception text). Never shown to the user.
  final String? detail;

  @override
  String toString() => 'BackupImportError($failure, $detail)';
}

/// Restores a previously-exported JSON blob via [BackupService.import].
///
/// [inspect] validates and counts a blob without writing anything, so the
/// UI can confirm with the user before the (irreversible, upsert-based)
/// import. [call] performs the actual restore.
final class ImportBackup {
  ImportBackup({
    required BackupService backup,
    Future<void> Function(List<String>)? reconcileReminders,
  }) : _backup = backup,
       _reconcileReminders = reconcileReminders;
  final BackupService _backup;
  final Future<void> Function(List<String>)? _reconcileReminders;

  /// Validates and counts a backup without touching the database.
  Result<BackupPreview, BackupImportError> inspect(String json) {
    final parsed = _parse(json);
    return switch (parsed) {
      Err(:final error) => Err(error),
      Ok(:final value) => Ok(_countsOf(value)),
    };
  }

  /// Restores the backup. Returns the number of rows added or updated.
  Future<Result<int, BackupImportError>> call(String json) async {
    final parsed = _parse(json);
    switch (parsed) {
      case Err(:final error):
        return Err(error);
      case Ok(:final value):
        try {
          final n = await _backup.import(value);
          try {
            await _reconcileReminders?.call(
              (value['items'] as List? ?? [])
                  .map((m) => (m as Map)['id'] as String)
                  .toList(),
            );
          } catch (_) {
            return const Err(
              BackupImportError(BackupImportFailure.remindersNotRefreshed),
            );
          }
          return Ok(n);
        } on Object catch (e) {
          return Err(BackupImportError(BackupImportFailure.restoreFailed, '$e'));
        }
    }
  }

  /// Parses and validates the blob into a backup map, or a user-facing
  /// error explaining why it can't be imported.
  Result<Map<String, Object?>, BackupImportError> _parse(String json) {
    if (json.trim().isEmpty) {
      return const Err(BackupImportError(BackupImportFailure.empty));
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return const Err(BackupImportError(BackupImportFailure.invalidJson));
    }
    if (decoded is! Map<String, Object?>) {
      return const Err(BackupImportError(BackupImportFailure.notBackup));
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
      return const Err(BackupImportError(BackupImportFailure.newerVersion));
    }
    const keys = [
      'contexts',
      'areas',
      'projects',
      'items',
      'attachments',
      'reviews',
    ];
    if (!keys.any(raw.containsKey)) {
      return const Err(BackupImportError(BackupImportFailure.unrecognized));
    }
    try {
      _backup.validate(raw);
    } catch (e) {
      return Err(BackupImportError(BackupImportFailure.invalidData, '$e'));
    }
    return Ok(raw);
  }

  BackupPreview _countsOf(Map<String, Object?> raw) {
    // Sections have been validated; omitted legacy sections count as zero.
    int len(String key) => raw[key] is List ? (raw[key]! as List).length : 0;
    return BackupPreview(
      contexts: len('contexts'),
      areas: len('areas'),
      projects: len('projects'),
      items: len('items'),
      attachments: len('attachments'),
      reviews: len('reviews'),
    );
  }
}
