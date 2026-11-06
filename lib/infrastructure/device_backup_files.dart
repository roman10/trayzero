import 'dart:io';
import 'dart:ui' show Rect;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/backup_files.dart';
import '../core/id_generator.dart';

class DeviceBackupFiles implements BackupFiles {
  DeviceBackupFiles({
    required IdGenerator ids,
    Future<Directory> Function()? documentsDirectory,
    Future<Directory> Function()? temporaryDirectory,
  }) : _ids = ids,
       _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final IdGenerator _ids;
  final Future<Directory> Function() _documentsDirectory;
  final Future<Directory> Function() _temporaryDirectory;

  Future<File> _attachmentFile(String path) async {
    final docs = await _documentsDirectory();
    final root = p.join(docs.path, 'attachments');
    final absolute = p.normalize(p.join(docs.path, path));
    if (p.isAbsolute(path) || !p.isWithin(root, absolute)) {
      throw const FormatException('Invalid attachment path');
    }
    return File(absolute);
  }

  @override
  Future<List<int>> readAttachment(String path) async {
    final file = await _attachmentFile(path);
    final docs = await _documentsDirectory();
    final resolved = await file.resolveSymbolicLinks();
    final root = await Directory(
      p.join(docs.path, 'attachments'),
    ).resolveSymbolicLinks();
    if (!p.isWithin(root, resolved)) {
      throw const FormatException('Attachment points outside its folder');
    }
    return file.readAsBytes();
  }

  @override
  Future<String> writeAttachment(
    List<int> bytes, {
    required String extension,
  }) async {
    if (extension.isNotEmpty &&
        !RegExp(r'^\.[a-zA-Z0-9]{1,10}$').hasMatch(extension)) {
      throw const FormatException('Invalid attachment extension');
    }
    final id = _ids.newId();
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
      throw StateError('Invalid generated attachment id');
    }
    final path = p.join('attachments', 'restored', '$id$extension');
    final file = await _attachmentFile(path);
    await file.parent.create(recursive: true);
    // Exclusive creation also protects against a broken/replayed id generator.
    await file.create(exclusive: true);
    try {
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {
      await file.delete();
      rethrow;
    }
    return path;
  }

  @override
  Future<void> deleteAttachment(String path) async {
    final file = await _attachmentFile(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<File> writeBackup(String name, String contents) async {
    final dir = await _temporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsString(contents, flush: true);
    return file;
  }

  @override
  Future<void> shareBackup(File file, {Rect? sharePositionOrigin}) =>
      Share.shareXFiles(
        [XFile(file.path)],
        text: 'Trayzero backup',
        sharePositionOrigin: sharePositionOrigin,
      ).then((_) {});
}
