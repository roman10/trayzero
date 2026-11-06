// Run only on a disposable emulator/simulator; no app startup, billing, or
// user database is involved. All platform adapters here are real, not mocks.
import 'dart:convert';
import 'dart:io';

import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/application/calendar_sync_service.dart';
import 'package:cleartray/application/delete_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/calendar_mirror_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/infrastructure/device_backup_files.dart';
import 'package:cleartray/infrastructure/device_calendar_gateway.dart';
import 'package:cleartray/infrastructure/local_notification_scheduler.dart';
import 'package:cleartray/infrastructure/time_zone.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'notification_delivery_test.dart' as notifications;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const clock = SystemClock();

  setUpAll(() async {
    await configureLocalTimeZone();
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
  });

  testWidgets('portable backup restores files and SQLite on a fresh store', (
    tester,
  ) async {
    final root = await (await getTemporaryDirectory()).createTemp(
      'native-backup-',
    );
    final ids = FixedIdGenerator([
      '${p.basename(root.path)}-source',
      '${p.basename(root.path)}-restore',
      '${p.basename(root.path)}-reimport',
    ]);
    final files = DeviceBackupFiles(ids: ids);
    final source = AppDatabase.forTesting(
      NativeDatabase(File(p.join(root.path, 'source.sqlite'))),
    );
    final targetFile = File(p.join(root.path, 'target.sqlite'));
    var target = AppDatabase.forTesting(NativeDatabase(targetFile));
    final paths = <String>[];
    File? exported;
    addTearDown(() async {
      await source.close();
      await target.close();
      for (final path in paths) {
        await files.deleteAttachment(path);
      }
      if (exported != null && await exported.exists()) {
        await exported.delete();
      }
      await root.delete(recursive: true);
    });

    BackupService backup(AppDatabase db) => BackupService(
      database: db,
      items: ItemRepository(db, clock),
      projects: ProjectRepository(db),
      contexts: ContextRepository(db),
      tags: TagRepository(db),
      areas: AreaRepository(db),
      attachments: AttachmentRepository(db, clock, ids),
      reviews: ReviewRepository(db),
      files: files,
      clock: clock,
    );
    final now = clock.now();
    await ContextRepository(source).upsert(
      const GtdContext(
        id: 'native-context',
        name: 'Home',
        icon: 'home',
        color: 0xFF6750A4,
      ),
    );
    await ProjectRepository(source).upsert(
      Project(
        id: 'native-project',
        title: 'Plan a trip',
        status: ProjectStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await ItemRepository(source, clock).upsert(
      Item(
        id: 'native-item',
        title: 'Pack résumé',
        notes: 'First line\nSecond line',
        status: ItemStatus.calendar,
        dueAt: now.add(const Duration(days: 1)),
        contextId: 'native-context',
        projectId: 'native-project',
        calendarEventId: 'belongs-to-source-device',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await ReviewRepository(source).upsertAll([
      ReviewLog(
        id: 'native-review',
        type: ReviewType.weekly,
        startedAt: now,
        currentStep: WeeklyReviewStep.projects,
      ),
    ]);
    const bytes = [0, 1, 127, 128, 255];
    final input = File(p.join(root.path, 'memo.bin'));
    await input.writeAsBytes(bytes, flush: true);
    final attachment = await AttachmentRepository(source, clock, ids).attach(
      itemId: 'native-item',
      kind: AttachmentKind.file,
      source: input,
      originalName: 'memo.bin',
    );
    paths.add(attachment.path);
    exported = await backup(source).exportToFile();
    final raw = (jsonDecode(await exported.readAsString()) as Map)
        .cast<String, Object?>();

    // Eliminate both source copies: restoration must use the exported bytes.
    await files.deleteAttachment(attachment.path);
    await input.delete();
    expect(await ItemRepository(target, clock).allRestorable(), isEmpty);
    expect(await backup(target).import(raw), 5);
    var restored = (await AttachmentRepository(
      target,
      clock,
      ids,
    ).getForItem('native-item')).single;
    paths.add(restored.path);
    expect(await files.readAttachment(restored.path), bytes);
    expect(restored.path, isNot(attachment.path));

    // Re-import retires the previous file rather than duplicating metadata.
    final previousPath = restored.path;
    expect(await backup(target).import(raw), 5);
    restored = (await AttachmentRepository(
      target,
      clock,
      ids,
    ).getForItem('native-item')).single;
    paths.add(restored.path);
    final docs = await getApplicationDocumentsDirectory();
    expect(await File(p.join(docs.path, previousPath)).exists(), isFalse);
    await target.close();
    target = AppDatabase.forTesting(NativeDatabase(targetFile));
    final item = (await ItemRepository(target, clock).getById('native-item'))!;
    expect(item.title, 'Pack résumé');
    expect(item.notes, 'First line\nSecond line');
    expect(item.contextId, 'native-context');
    expect(item.projectId, 'native-project');
    expect(item.calendarEventId, isNull);
    expect(
      (await ReviewRepository(target).all()).single.currentStep,
      WeeklyReviewStep.projects,
    );
    expect(await files.readAttachment(restored.path), bytes);
    expect(await ItemRepository(target, clock).allRestorable(), hasLength(1));
  });

  testWidgets('deleting an Item cleans its owned native calendar event', (
    tester,
  ) async {
    final plugin = DeviceCalendarPlugin();
    final permission = await plugin.hasPermissions();
    expect(
      permission.isSuccess && permission.data == true,
      isTrue,
      reason: 'Pre-grant calendar access on the disposable CI device.',
    );
    final created = await plugin.createCalendar(
      'Trayzero native CI',
      localAccountName: 'Trayzero CI',
    );
    expect(
      created.isSuccess && (created.data?.isNotEmpty ?? false),
      isTrue,
      reason: 'A dedicated writable test calendar is required.',
    );
    final calendarId = created.data!;
    addTearDown(() async {
      final removed = await plugin.deleteCalendar(calendarId);
      expect(removed.isSuccess && removed.data == true, isTrue);
    });
    final root = await (await getTemporaryDirectory()).createTemp(
      'native-calendar-',
    );
    final db = AppDatabase.forTesting(
      NativeDatabase(File(p.join(root.path, 'calendar.sqlite'))),
    );
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final items = ItemRepository(db, clock);
    final mirrors = CalendarMirrorRepository(db);
    final gateway = DeviceCalendarGateway();
    expect(
      (await gateway.listCalendars()).map((c) => c.id),
      contains(calendarId),
    );
    final scheduler = LocalNotificationScheduler();
    await scheduler.init();
    final now = clock.now();
    await items.upsert(
      Item(
        id: 'native-calendar-item',
        title: 'Native event',
        status: ItemStatus.calendar,
        dueAt: now.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final sync = CalendarSyncService(items, clock, gateway, mirrors: mirrors);
    final result = await sync.mirrorOut(calendarId: calendarId);
    expect(result.written, 1);
    final eventId = (await items.getById(
      'native-calendar-item',
    ))!.calendarEventId!;
    final before = await gateway.eventsInRange(
      calendarId: calendarId,
      from: now,
      to: now.add(const Duration(days: 2)),
    );
    expect(before.map((e) => e.id), contains(eventId));
    await DeleteItem(
      items: items,
      attachments: AttachmentRepository(db, clock, FixedIdGenerator()),
      scheduler: scheduler,
    )('native-calendar-item');
    expect(await mirrors.all(), hasLength(1));
    // A new service must still know which native event the deleted Item owned.
    final restarted = CalendarSyncService(
      items,
      clock,
      gateway,
      mirrors: CalendarMirrorRepository(db),
    );
    expect((await restarted.mirrorOut(calendarId: calendarId)).removed, 1);
    expect(await mirrors.all(), isEmpty);
    final after = await plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
      ),
    );
    expect(
      after.isSuccess && after.data != null,
      isTrue,
      reason:
          'An unsuccessful native lookup must not count as confirmed absence.',
    );
    expect(after.data!.map((e) => e.eventId), isNot(contains(eventId)));
  });

  if (Platform.isAndroid) {
    group('Android release notifications', notifications.main);
  }
}
