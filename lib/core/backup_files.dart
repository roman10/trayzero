import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Device file access used by backups. Restored attachments always receive a
/// new path, so a failed restore cannot overwrite an existing attachment.
abstract class BackupFiles {
  Future<List<int>> readAttachment(String path);
  Future<String> writeAttachment(List<int> bytes, {required String extension});
  Future<void> deleteAttachment(String path);
  Future<File> writeBackup(String name, String contents);
  Future<void> shareBackup(File file, {Rect? sharePositionOrigin});
}

final backupFilesProvider = Provider<BackupFiles>((ref) {
  throw UnimplementedError('backupFilesProvider must be overridden');
});
