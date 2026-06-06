import 'dart:ui' show Rect;

import '../core/result.dart';
import 'backup_service.dart';

/// Triggers the JSON-to-share-sheet backup flow. Wraps the existing
/// [BackupService.shareBackup] so failures (disk full, share denied)
/// flow back as a [Result] instead of a thrown exception.
final class ExportBackup {
  ExportBackup({required BackupService backup}) : _backup = backup;
  final BackupService _backup;

  Future<Result<void, String>> call({Rect? sharePositionOrigin}) async {
    try {
      await _backup.shareBackup(sharePositionOrigin: sharePositionOrigin);
      return const Ok(null);
    } on Object catch (e) {
      return Err(e.toString());
    }
  }
}
