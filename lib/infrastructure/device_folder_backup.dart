import 'package:flutter/services.dart';

import '../core/folder_backup.dart';

class DeviceFolderBackup implements FolderBackupFiles {
  const DeviceFolderBackup();
  static const channel = MethodChannel('app.cleartray/folder_backup');

  @override
  Future<BackupFolder?> chooseFolder() async {
    final raw = await channel.invokeMapMethod<String, dynamic>('chooseFolder');
    return raw == null
        ? null
        : BackupFolder(
            handle: raw['handle'] as String,
            label: raw['label'] as String,
          );
  }

  @override
  Future<bool> writeSnapshot(BackupFolder folder, String contents) async =>
      await channel.invokeMethod<bool>('writeSnapshot', {
        'handle': folder.handle,
        'contents': contents,
      }) ??
      false;

  @override
  Future<void> releaseFolder(BackupFolder folder) =>
      channel.invokeMethod<void>('releaseFolder', {'handle': folder.handle});

  @override
  Future<List<BackupSnapshot>> listSnapshots(BackupFolder folder) async {
    final raw = await channel.invokeListMethod<Map<Object?, Object?>>(
      'listSnapshots',
      {'handle': folder.handle},
    );
    return [
      for (final entry in raw ?? const <Map<Object?, Object?>>[])
        BackupSnapshot(
          id: entry['id'] as String,
          name: entry['name'] as String,
          modified: (entry['modified'] as int? ?? 0) > 0
              ? DateTime.fromMillisecondsSinceEpoch(entry['modified'] as int)
              : null,
        ),
    ];
  }

  @override
  Future<String> readSnapshot(
    BackupFolder folder,
    BackupSnapshot snapshot,
  ) async =>
      await channel.invokeMethod<String>('readSnapshot', {
        'handle': folder.handle,
        'id': snapshot.id,
      }) ??
      '';
}
