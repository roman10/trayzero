import 'dart:ui' show Rect;

import 'package:cleartray/application/export_backup.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/result.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/core/id_generator.dart';
import '../support/backup_files_fake.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Clock clock;
  late BackupService backup;
  late ExportBackup exportBackup;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 15, 9));
    backup = BackupService(
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
    );
    exportBackup = ExportBackup(backup: backup);
  });

  tearDown(() async => db.close());

  test('wraps share-sheet failures as an Err instead of throwing', () async {
    // In the test harness there is no path_provider / share platform, so
    // BackupService.shareBackup throws — ExportBackup must surface that as
    // a Result rather than propagating the exception.
    final r = await exportBackup();
    expect(r, isA<Err<void, String>>());
    expect((r as Err).error, isNotEmpty);
  });

  test('forwards sharePositionOrigin through to shareBackup', () async {
    // Regression guard for the iOS 26 fix: the share sheet throws a
    // PlatformException unless a non-empty origin reaches Share.shareXFiles,
    // so the use case must thread it down rather than drop it.
    final spy = _SpyBackupService(db, clock);
    const origin = Rect.fromLTWH(8, 16, 32, 48);

    final r = await ExportBackup(backup: spy).call(sharePositionOrigin: origin);

    expect(r, isA<Ok<void, String>>());
    expect(spy.capturedOrigins, [origin]);
  });

  test('exported snapshot round-trips back through import', () async {
    final items = ItemRepository(db, clock);
    final projects = ProjectRepository(db);
    final contexts = ContextRepository(db);
    final areas = AreaRepository(db);

    final now = DateTime(2026, 5, 15);
    await contexts.upsert(const GtdContext(
      id: 'c1',
      name: '@office',
      icon: 'work',
      color: 0xFF1565C0,
    ));
    await areas.upsert(const Area(id: 'a1', name: 'Work'));
    await projects.upsert(Project(
      id: 'p1',
      title: 'Launch',
      areaId: 'a1',
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ));
    await items.upsert(Item(
      id: 'i1',
      title: 'Draft spec',
      status: ItemStatus.nextAction,
      contextId: 'c1',
      projectId: 'p1',
      createdAt: now,
      updatedAt: now,
    ));

    final snapshot = await backup.export();

    await items.delete('i1');
    await projects.delete('p1');
    await contexts.delete('c1');
    await areas.delete('a1');
    expect(await items.allActive(), isEmpty);

    final count = await backup.import(snapshot);
    expect(count, 4);
    final restored = await items.getById('i1');
    expect(restored?.title, 'Draft spec');
    expect(restored?.contextId, 'c1');
    expect(restored?.projectId, 'p1');
  });

  test('export stamps the snapshot with the clock and format version',
      () async {
    final snapshot = await backup.export();
    expect(snapshot['version'], BackupService.formatVersion);
    expect(snapshot['exportedAt'], DateTime(2026, 5, 15, 9).toIso8601String());
  });
}

/// Captures the [sharePositionOrigin] passed to [BackupService.shareBackup]
/// without invoking the platform share sheet, so the forwarding can be
/// asserted in a headless test.
class _SpyBackupService extends BackupService {
  _SpyBackupService(AppDatabase db, Clock clock)
      : super(
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
        );

  final List<Rect?> capturedOrigins = [];

  @override
  Future<void> shareBackup({Rect? sharePositionOrigin}) async {
    capturedOrigins.add(sharePositionOrigin);
  }
}
