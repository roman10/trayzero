import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/application/import_backup.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/result.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/core/id_generator.dart';
import '../support/backup_files_fake.dart';

void main() {
  late AppDatabase db;
  late ImportBackup importer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final clock = FakeClock(DateTime(2026, 5, 15));
    importer = ImportBackup(
      backup: BackupService(
        database: db,
        attachments: AttachmentRepository(db, clock, FixedIdGenerator([])),
        reviews: ReviewRepository(db),
        files: MemoryBackupFiles(),
        items: ItemRepository(db, clock),
        projects: ProjectRepository(db),
        contexts: ContextRepository(db),
        tags: TagRepository(db),
        areas: AreaRepository(db),
        clock: clock,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('inspect', () {
    test('rejects empty input', () {
      final r = importer.inspect('   ');
      expect(r, isA<Err<BackupPreview, BackupImportError>>());
      expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.empty);
    });

    test('rejects invalid JSON', () {
      final r = importer.inspect('{not json');
      expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.invalidJson);
    });

    test('rejects a JSON value that is not an object', () {
      final r = importer.inspect('[1,2,3]');
      expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.notBackup);
    });

    test('rejects a backup from a newer format version', () {
      final r = importer.inspect(jsonEncode({
        'version': BackupService.formatVersion + 1,
        'items': [],
      }));
      expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.newerVersion);
    });

    test('rejects JSON object without any backup keys', () {
      final r = importer.inspect(jsonEncode({'hello': 'world'}));
      expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.unrecognized);
    });

    test('rejects a non-list entity value without throwing', () {
      final r = importer.inspect(jsonEncode({
        'version': BackupService.formatVersion,
        'items': 5,
        'contexts': {'not': 'a list'},
      }));
      expect(r, isA<Err<BackupPreview, BackupImportError>>());
      expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.invalidData);
    });

    test('counts entities without writing', () {
      final r = importer.inspect(jsonEncode({
        'version': BackupService.formatVersion,
        'contexts': [
          {'id': 'c1', 'name': '@home'}
        ],
        'projects': [
          {'id': 'p1', 'title': 'p1'},
          {'id': 'p2', 'title': 'p2'}
        ],
        'items': [
          {'id': 'i1', 'title': 'i1'},
          {'id': 'i2', 'title': 'i2'},
          {'id': 'i3', 'title': 'i3'}
        ],
      }));
      final preview = (r as Ok<BackupPreview, BackupImportError>).value;
      expect(preview.contexts, 1);
      expect(preview.projects, 2);
      expect(preview.items, 3);
      expect(preview.areas, 0);
      expect(preview.total, 6);
      expect(preview.isEmpty, isFalse);
    });
  });

  test('call surfaces the same validation errors', () async {
    final r = await importer.call('');
    expect(((r as Err).error as BackupImportError).failure, BackupImportFailure.empty);
  });

  group('Google Takeout Tasks export', () {
    final takeout = jsonEncode({
      'kind': 'tasks#taskLists',
      'items': [
        {
          'title': 'Next action',
          'id': 'list-1',
          'items': [
            {
              'id': 'open1',
              'title': 'Buy milk',
              'status': 'needsAction',
              'due': '2026-11-03T00:00:00Z',
            },
            {
              'id': 'done1',
              'title': 'Old thing',
              'status': 'completed',
              'completed': '2024-11-20T07:14:05.940Z',
            },
          ],
        },
      ],
    });

    test('inspect auto-detects and counts the converted items', () {
      final r = importer.inspect(takeout);
      final preview = (r as Ok<BackupPreview, BackupImportError>).value;
      expect(preview.items, 2);
      expect(preview.total, 2);
    });

    test('call restores open→inbox and completed→done', () async {
      final r = await importer.call(takeout);
      expect((r as Ok).value, 2);

      final items = ItemRepository(db, FakeClock(DateTime(2026, 5, 15)));
      final open = await items.getById('gt-open1');
      expect(open, isNotNull);
      expect(open!.status.name, 'inbox');
      expect(open.completedAt, isNull);
      expect(open.dueAt, DateTime(2026, 11, 3));
      expect(open.dueAt!.isUtc, isFalse);

      final done = await items.getById('gt-done1');
      expect(done!.status.name, 'done');
      expect(done.completedAt, isNotNull);
    });
  });
}
