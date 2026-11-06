import 'dart:io';
import 'dart:ui' show Rect;

import 'package:cleartray/core/backup_files.dart';

class MemoryBackupFiles implements BackupFiles {
  final Map<String, List<int>> attachments = {};
  final List<String> deleted = [];
  String? backupContents;
  int? failWriteAt;
  int _writes = 0;

  @override
  Future<List<int>> readAttachment(String path) async {
    final bytes = attachments[path];
    if (bytes == null) throw FileSystemException('Missing attachment', path);
    return List.of(bytes);
  }

  @override
  Future<String> writeAttachment(
    List<int> bytes, {
    required String extension,
  }) async {
    final n = ++_writes;
    if (n == failWriteAt) throw const FileSystemException('Disk full');
    final path = 'attachments/restored/$n$extension';
    attachments[path] = List.of(bytes);
    return path;
  }

  @override
  Future<void> deleteAttachment(String path) async {
    deleted.add(path);
    attachments.remove(path);
  }

  @override
  Future<File> writeBackup(String name, String contents) async {
    backupContents = contents;
    return File('/tmp/$name');
  }

  @override
  Future<void> shareBackup(File file, {Rect? sharePositionOrigin}) async {
    throw UnsupportedError('No share sheet in headless tests');
  }
}
