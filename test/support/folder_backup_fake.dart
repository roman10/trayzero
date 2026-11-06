import 'dart:async';

import 'package:cleartray/core/folder_backup.dart';

class MemoryFolderBackupPreferences implements FolderBackupPreferences {
  FolderBackupSettings settings = const FolderBackupSettings();
  bool fail = false;
  @override
  FolderBackupSettings load() => settings;
  @override
  Future<void> save(FolderBackupSettings value) async {
    if (fail) throw StateError('Preferences unavailable');
    settings = value;
  }
}

class MemoryFolderBackupFiles implements FolderBackupFiles {
  BackupFolder? selection;
  bool fail = false;
  bool pruned = true;
  Completer<void>? writeGate;
  final List<String> snapshots = [];
  final List<String> folders = [];
  final List<String> released = [];
  @override
  Future<BackupFolder?> chooseFolder() async => selection;
  @override
  Future<bool> writeSnapshot(BackupFolder folder, String contents) async {
    await writeGate?.future;
    if (fail) throw StateError('Folder unavailable');
    snapshots.add(contents);
    folders.add(folder.handle);
    return pruned;
  }

  @override
  Future<void> releaseFolder(BackupFolder folder) async =>
      released.add(folder.handle);

  /// Files other than those written through [writeSnapshot]; name -> text.
  final Map<String, String> extraFiles = {};
  bool listFails = false;
  Set<String> unreadable = {};

  @override
  Future<List<BackupSnapshot>> listSnapshots(BackupFolder folder) async {
    if (listFails) throw StateError('Folder unavailable');
    return [
      for (var i = 0; i < snapshots.length; i++)
        BackupSnapshot(
          id: 'auto-$i',
          name:
              'trayzero-auto-0123456789abcdef0123456789abcdef-202610${(i + 1).toString().padLeft(2, '0')}T120000000Z-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.json',
        ),
      for (final name in extraFiles.keys) BackupSnapshot(id: name, name: name),
    ];
  }

  @override
  Future<String> readSnapshot(
    BackupFolder folder,
    BackupSnapshot snapshot,
  ) async {
    if (unreadable.contains(snapshot.id)) throw StateError('Unreadable');
    if (snapshot.id.startsWith('auto-')) {
      return snapshots[int.parse(snapshot.id.substring(5))];
    }
    return extraFiles[snapshot.id]!;
  }
}
