import 'dart:convert';
import 'dart:io';

import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/application/import_backup.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/result.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/mappers.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/backup_files_fake.dart';

class FailingReviews extends ReviewRepository {
  FailingReviews(super.db);
  @override
  Future<void> upsertAll(List<ReviewLog> rows) async =>
      throw StateError('Write failed');
}

void main() {
  final clock = FakeClock(DateTime(2026, 10, 13, 9));
  late AppDatabase source;
  late AppDatabase target;
  late MemoryBackupFiles sourceFiles;
  late MemoryBackupFiles targetFiles;
  BackupService backup(
    AppDatabase db,
    MemoryBackupFiles files, {
    ReviewRepository? reviews,
  }) => BackupService(
    database: db,
    items: ItemRepository(db, clock),
    projects: ProjectRepository(db),
    contexts: ContextRepository(db),
    tags: TagRepository(db),
    areas: AreaRepository(db),
    attachments: AttachmentRepository(db, clock, FixedIdGenerator([])),
    reviews: reviews ?? ReviewRepository(db),
    files: files,
    clock: clock,
  );
  Item item(String title) => Item(
    id: 'i',
    title: title,
    status: ItemStatus.calendar,
    dueAt: clock.now().add(const Duration(days: 1)),
    createdAt: clock.now(),
    updatedAt: clock.now(),
  );

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
    sourceFiles = MemoryBackupFiles();
    targetFiles = MemoryBackupFiles();
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<Map<String, Object?>> snapshot() async {
    await ContextRepository(source).upsert(
      const GtdContext(
        id: 'ctx',
        name: 'Home',
        icon: 'home',
        color: 0xFF6750A4,
      ),
    );
    await AreaRepository(source).upsert(const Area(id: 'area', name: 'Family'));
    await ProjectRepository(source).upsert(
      Project(
        id: 'project',
        title: 'Plan a trip',
        status: ProjectStatus.active,
        areaId: 'area',
        createdAt: clock.now(),
        updatedAt: clock.now(),
      ),
    );
    await ItemRepository(source, clock).upsert(
      item('Portable task').copyWith(projectId: 'project', contextId: 'ctx'),
    );
    for (final kind in AttachmentKind.values) {
      final a = Attachment(
        id: kind.name,
        itemId: 'i',
        kind: kind,
        path: 'attachments/i/${kind.name}.dat',
        name: '${kind.name} original',
        sizeBytes: 4,
        createdAt: clock.now(),
      );
      sourceFiles.attachments[a.path] = [0, 1, 127, 255];
      await source.into(source.attachments).insert(a.toCompanion());
    }
    await ReviewRepository(source).insert(
      ReviewLog(
        id: 'review',
        type: ReviewType.weekly,
        startedAt: clock.now(),
        completedAt: clock.now().add(const Duration(minutes: 20)),
        notes: 'Remember the family project.',
      ),
    );
    return backup(source, sourceFiles).export();
  }

  test(
    'fresh-device JSON restore preserves all attachment bytes and Review history',
    () async {
      final raw = await snapshot();
      expect(raw['version'], BackupService.formatVersion);
      final importer = ImportBackup(backup: backup(target, targetFiles));
      final preview =
          (importer.inspect(jsonEncode(raw)) as Ok<BackupPreview, BackupImportError>)
              .value;
      expect(preview.attachments, 3);
      expect(preview.reviews, 1);
      expect((await importer(jsonEncode(raw)) as Ok<int, BackupImportError>).value, 8);
      expect(
        (await ItemRepository(target, clock).getById('i'))!.projectId,
        'project',
      );
      expect(
        (await ProjectRepository(target).getById('project'))!.areaId,
        'area',
      );
      final media = await AttachmentRepository(
        target,
        clock,
        FixedIdGenerator([]),
      ).getForItem('i');
      expect(media.map((a) => a.kind).toSet(), AttachmentKind.values.toSet());
      for (final a in media) {
        expect(a.path, startsWith('attachments/restored/'));
        expect(await targetFiles.readAttachment(a.path), [0, 1, 127, 255]);
        expect(a.name, '${a.kind.name} original');
        expect(a.createdAt, clock.now());
      }
      final review = (await ReviewRepository(target).all()).single;
      expect(review.type, ReviewType.weekly);
      expect(review.notes, 'Remember the family project.');
      expect(review.completedAt, clock.now().add(const Duration(minutes: 20)));
    },
  );

  test(
    're-import updates metadata and retires superseded files after commit',
    () async {
      final raw = await snapshot();
      final service = backup(target, targetFiles);
      await service.import(raw);
      final oldPaths = targetFiles.attachments.keys.toSet();
      await service.import(raw);
      expect(targetFiles.attachments, hasLength(3));
      expect(
        targetFiles.attachments.keys.toSet().intersection(oldPaths),
        isEmpty,
      );
      expect(await ReviewRepository(target).all(), hasLength(1));
      expect(await target.select(target.attachments).get(), hasLength(3));
    },
  );

  test(
    'database failure rolls back every section and removes newly staged files',
    () async {
      final raw = await snapshot();
      await ItemRepository(target, clock).upsert(item('Existing local task'));
      final service = backup(
        target,
        targetFiles,
        reviews: FailingReviews(target),
      );
      await expectLater(service.import(raw), throwsStateError);
      expect(
        (await ItemRepository(target, clock).getById('i'))!.title,
        'Existing local task',
      );
      expect(await target.select(target.attachments).get(), isEmpty);
      expect(await ReviewRepository(target).all(), isEmpty);
      expect(await ContextRepository(target).all(), isEmpty);
      expect(await AreaRepository(target).watchAll().first, isEmpty);
      expect(await ProjectRepository(target).watchAll().first, isEmpty);
      expect(targetFiles.attachments, isEmpty);
    },
  );

  test(
    'disk failure before commit leaves existing data and files intact',
    () async {
      final raw = await snapshot();
      await ItemRepository(target, clock).upsert(item('Local task'));
      targetFiles.attachments['attachments/existing.dat'] = [42];
      targetFiles.failWriteAt = 2;
      final r = await ImportBackup(backup: backup(target, targetFiles))(
        jsonEncode(raw),
      );
      expect(r, isA<Err<int, BackupImportError>>());
      expect(
        (await ItemRepository(target, clock).getById('i'))!.title,
        'Local task',
      );
      expect(targetFiles.attachments, {
        'attachments/existing.dat': [42],
      });
      expect(await target.select(target.attachments).get(), isEmpty);
    },
  );

  test(
    'missing attachment fails export rather than silently omitting content',
    () async {
      await snapshot();
      sourceFiles.attachments.clear();
      await expectLater(
        backup(source, sourceFiles).export(),
        throwsA(isA<FileSystemException>()),
      );
    },
  );

  test('invalid dates are rejected before any write', () async {
    final raw = await snapshot();
    (raw['items'] as List).first['dueAt'] = 'not-a-date';
    await expectLater(
      backup(target, targetFiles).import(raw),
      throwsFormatException,
    );
    expect(await ItemRepository(target, clock).allRestorable(), isEmpty);
    expect(targetFiles.attachments, isEmpty);
  });

  test('malformed embedded bytes are rejected before any write', () async {
    final raw = await snapshot();
    (raw['attachments'] as List).cast<Map>().first['data'] = '%broken%';
    final importer = ImportBackup(backup: backup(target, targetFiles));
    expect(
      importer.inspect(jsonEncode(raw)),
      isA<Err<BackupPreview, BackupImportError>>(),
    );
    expect(await importer(jsonEncode(raw)), isA<Err<int, BackupImportError>>());
    expect(await target.select(target.items).get(), isEmpty);
    expect(targetFiles.attachments, isEmpty);
  });

  test(
    'unsafe extensions, mismatched sizes and dangling attachments are rejected',
    () async {
      for (final change in [
        {'extension': '/../../escape'},
        {'sizeBytes': 900},
        {'itemId': 'missing'},
      ]) {
        final raw = await snapshot();
        (raw['attachments'] as List).cast<Map>().first.addAll(change);
        expect(
          ImportBackup(
            backup: backup(target, targetFiles),
          ).inspect(jsonEncode(raw)),
          isA<Err<BackupPreview, BackupImportError>>(),
        );
        // Freshen source for the next case without duplicating its seeded rows.
        await source.delete(source.attachments).go();
        await source.delete(source.reviews).go();
      }
    },
  );

  test(
    'same-device restore keeps native ownership; portable JSON contains no event ids',
    () async {
      final raw = await snapshot();
      final items = ItemRepository(target, clock);
      await items.upsert(
        item('Local title').copyWith(calendarEventId: 'native-local'),
      );
      expect(
        (raw['items'] as List).cast<Map>().single.containsKey(
          'calendarEventId',
        ),
        isFalse,
      );
      await backup(target, targetFiles).import(raw);
      expect((await items.getById('i'))!.calendarEventId, 'native-local');
    },
  );

  test(
    'reminder reconciliation runs after successful restore, with a distinct error on failure',
    () async {
      final raw = await snapshot();
      final importer = ImportBackup(
        backup: backup(target, targetFiles),
        reconcileReminders: (ids) async {
          expect(ids, ['i']);
          expect(await ItemRepository(target, clock).getById('i'), isNotNull);
          throw StateError('Scheduler unavailable');
        },
      );
      final r = await importer(jsonEncode(raw));
      expect(
        ((r as Err).error as BackupImportError).failure,
        BackupImportFailure.remindersNotRefreshed,
      );
      expect(await target.select(target.attachments).get(), hasLength(3));
    },
  );
}
