import 'dart:convert';

import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/application/folder_restore.dart';
import 'package:cleartray/application/import_backup.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/result.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/backup_files_fake.dart';
import '../support/folder_backup_fake.dart';
import '../support/harness.dart' show anItem;

String backupWith(int items) => jsonEncode({
  'version': BackupService.formatVersion,
  'items': [
    for (var i = 0; i < items; i++) {'id': 'i$i', 'title': 'Task $i'},
  ],
});

void main() {
  const folder = BackupFolder(handle: 'tree', label: 'Backups');
  const other = BackupFolder(handle: 'other-tree', label: 'Elsewhere');
  late AppDatabase db;
  late ItemRepository items;
  late MemoryFolderBackupFiles files;
  late BackupFolder? configured;
  late FolderRestoreController controller;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  FolderRestoreController build() {
    final clock = FakeClock(DateTime(2026, 11, 4));
    return FolderRestoreController(
      files: files,
      configuredFolder: () => configured,
      importer: ImportBackup(
        backup: BackupService(
          database: db,
          attachments: AttachmentRepository(db, clock, FixedIdGenerator([])),
          reviews: ReviewRepository(db),
          files: MemoryBackupFiles(),
          items: items,
          projects: ProjectRepository(db),
          contexts: ContextRepository(db),
          tags: TagRepository(db),
          areas: AreaRepository(db),
          clock: clock,
        ),
      ),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    items = ItemRepository(db, FakeClock(DateTime(2026, 11, 4)));
    files = MemoryFolderBackupFiles();
    configured = folder;
    controller = build();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  test('lists the configured folder newest first with item counts', () async {
    files.snapshots
      ..add(backupWith(1))
      ..add(backupWith(3));
    await controller.useConfiguredFolder();
    await settle();
    final state = controller.state;
    expect(state.listed, isTrue);
    expect(state.folder, folder);
    // Second file carries the later timestamp, so it leads.
    expect(state.entries.map((e) => e.preview!.items), [3, 1]);
    expect(state.entries.first.snapshot.takenAt, DateTime.utc(2026, 10, 2, 12));
  });

  test('does nothing without a configured folder', () async {
    configured = null;
    await controller.useConfiguredFolder();
    expect(controller.state.folder, isNull);
    expect(controller.state.listed, isFalse);
  });

  test('empty folder is listed but has no entries', () async {
    await controller.useConfiguredFolder();
    expect(controller.state.listed, isTrue);
    expect(controller.state.entries, isEmpty);
  });

  test('unreadable and non-backup files are flagged, not fatal', () async {
    files.snapshots.add(backupWith(2));
    files.extraFiles['trayzero-backup-2026-10-01T10-00-00.json'] =
        '{"hello": "world"}';
    files.extraFiles['trayzero-backup-2026-09-01T10-00-00.json'] = backupWith(
      5,
    );
    files.unreadable.add('trayzero-backup-2026-09-01T10-00-00.json');
    await controller.useConfiguredFolder();
    await settle();
    final byName = {for (final e in controller.state.entries) e.snapshot.id: e};
    expect(byName['auto-0']!.preview!.items, 2);
    expect(
      byName['trayzero-backup-2026-10-01T10-00-00.json']!.unreadable,
      true,
    );
    expect(
      byName['trayzero-backup-2026-09-01T10-00-00.json']!.unreadable,
      true,
    );
  });

  test('a failing folder reports failure and can be replaced', () async {
    files.listFails = true;
    await controller.useConfiguredFolder();
    expect(controller.state.failed, isTrue);
    expect(controller.state.listed, isFalse);

    files
      ..listFails = false
      ..selection = other
      ..snapshots.add(backupWith(1));
    await controller.chooseFolder();
    await settle();
    expect(controller.state.folder, other);
    expect(controller.state.entries, hasLength(1));
  });

  test('cancelling the picker keeps the current list', () async {
    files.snapshots.add(backupWith(1));
    await controller.useConfiguredFolder();
    await settle();
    files.selection = null;
    await controller.chooseFolder();
    expect(controller.state.folder, folder);
    expect(controller.state.entries, hasLength(1));
  });

  test('restore merges into existing data and deletes nothing', () async {
    // An unrelated local item that the backup does not contain.
    await items.upsert(anItem(id: 'local', title: 'Keep me'));
    files.snapshots.add(backupWith(2));
    await controller.useConfiguredFolder();
    await settle();
    final result = await controller.restore(controller.state.entries.single);
    expect(result, isA<Ok<int, BackupImportError>>());
    final titles = (await items.allActive()).map((i) => i.title).toSet();
    expect(titles, containsAll(['Keep me', 'Task 0', 'Task 1']));
  });

  test('restore reports an unreadable file as an error', () async {
    files.snapshots.add(backupWith(1));
    await controller.useConfiguredFolder();
    await settle();
    files.unreadable.add('auto-0');
    final result = await controller.restore(controller.state.entries.single);
    expect(result, isA<Err<int, BackupImportError>>());
  });

  test(
    'a temporary folder grant is released, the configured one is not',
    () async {
      final temporary = build();
      files.selection = other;
      await temporary.chooseFolder();
      await settle();
      temporary.dispose();
      await settle();
      expect(files.released, ['other-tree']);

      // Choosing the folder automatic backups already use must keep its grant.
      final again = build();
      files.selection = folder;
      await again.chooseFolder();
      await settle();
      again.dispose();
      await settle();
      expect(files.released, ['other-tree']);
    },
  );
}
