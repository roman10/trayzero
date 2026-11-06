import 'package:cleartray/application/delete_item.dart';
import 'package:cleartray/application/process_inbox_decision.dart';
import 'package:cleartray/application/complete_item.dart';
import 'package:cleartray/application/convert_to_project.dart';
import 'package:cleartray/application/purge_trash.dart';
import 'package:cleartray/application/restore_trashed_item.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/application/trash_item.dart';
import 'package:cleartray/application/undo_process_decision.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late FakeNotificationScheduler scheduler;
  late FakeClock clock;
  late FixedIdGenerator ids;
  late SaveItem saveItem;
  late TrashItem trash;
  late RestoreTrashedItem restore;
  late PurgeTrash purge;
  late CompleteItem complete;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 12));
    ids = FixedIdGenerator(['spawn-1', 'proj-1']);
    items = ItemRepository(db, clock);
    scheduler = FakeNotificationScheduler();
    saveItem = SaveItem(items: items, scheduler: scheduler, clock: clock);
    trash = TrashItem(items: items, scheduler: scheduler, clock: clock);
    restore = RestoreTrashedItem(items: items, saveItem: saveItem);
    purge = PurgeTrash(
      items: items,
      deleteItem: DeleteItem(
        items: items,
        attachments: AttachmentRepository(db, clock, ids),
        scheduler: scheduler,
      ),
    );
    complete = CompleteItem(
      items: items,
      scheduler: scheduler,
      clock: clock,
      ids: ids,
      saveItem: saveItem,
    );
  });

  tearDown(() async => db.close());

  Item make(
    String id, {
    ItemStatus status = ItemStatus.nextAction,
    DateTime? deferUntil,
    DateTime? focusedAt,
  }) => Item(
    id: id,
    title: 'Task $id',
    status: status,
    deferUntil: deferUntil,
    focusedAt: focusedAt,
    createdAt: DateTime(2026, 5, 14),
    updatedAt: DateTime(2026, 5, 14),
  );

  group('TrashItem', () {
    test('moves the row to trashed, hides it everywhere, cancels reminders',
        () async {
      await items.upsert(make('a'));

      final snapshot = await trash('a');

      expect(snapshot!.status, ItemStatus.nextAction);
      expect((await items.getById('a'))!.status, ItemStatus.trashed);
      expect(await items.allActive(), isEmpty);
      expect(await items.allRestorable(), isEmpty);
      expect(await items.search('Task'), isEmpty);
      expect(scheduler.cancelled, [
        notificationIdFor('a', 1),
        notificationIdFor('a', 2),
        notificationIdFor('a', 3),
      ]);
    });

    test('a trashed project action leaves the project lists', () async {
      await items.upsert(
        make('p').copyWith(projectId: 'proj', status: ItemStatus.nextAction),
      );
      await items.upsert(
        make('done').copyWith(
          projectId: 'proj',
          status: ItemStatus.done,
          completedAt: DateTime(2026, 5, 13),
        ),
      );
      await trash('p');
      await trash('done');

      expect(await items.watchForProject('proj').first, isEmpty);
      expect(await items.watchCompletedForProject('proj').first, isEmpty);
    });

    test('returns null for an unknown or already trashed id', () async {
      expect(await trash('missing'), isNull);
      await items.upsert(make('a'));
      await trash('a');
      expect(await trash('a'), isNull);
    });
  });

  group('RestoreTrashedItem', () {
    test('restores the exact prior state and re-arms reminders', () async {
      final defer = DateTime(2026, 6, 1, 9);
      await items.upsert(make('a', deferUntil: defer));
      final snapshot = (await trash('a'))!;
      scheduler.scheduled.clear();

      expect(await restore(snapshot), isTrue);

      final back = (await items.getById('a'))!;
      expect(back.status, ItemStatus.nextAction);
      expect(back.deferUntil, defer);
      expect(
        scheduler.scheduled.map((s) => s.id),
        contains(notificationIdFor('a', 2)),
      );
    });

    test('puts Today focus back', () async {
      final focus = DateTime(2026, 5, 14, 8);
      await items.upsert(make('a', focusedAt: focus));
      final snapshot = (await trash('a'))!;
      expect((await items.getById('a'))!.focusedAt, isNull);

      await restore(snapshot);

      expect((await items.getById('a'))!.focusedAt, focus);
    });

    test('does nothing once the row was purged or restored', () async {
      await items.upsert(make('a'));
      final snapshot = (await trash('a'))!;
      await purge(ids: ['a']);

      expect(await restore(snapshot), isFalse);
      expect(await items.getById('a'), isNull);
    });
  });

  group('PurgeTrash', () {
    test('with ids deletes only those still trashed', () async {
      await items.upsert(make('gone'));
      await items.upsert(make('undone'));
      await items.upsert(make('live'));
      await trash('gone');
      final snapshot = (await trash('undone'))!;
      await restore(snapshot);

      await purge(ids: ['gone', 'undone', 'live']);

      expect(await items.getById('gone'), isNull);
      expect(await items.getById('undone'), isNotNull);
      expect(await items.getById('live'), isNotNull);
    });

    test('without ids sweeps every trashed row (startup sweep)', () async {
      await items.upsert(make('a'));
      await items.upsert(make('b'));
      await items.upsert(make('keep'));
      await trash('a');
      await trash('b');

      await purge();

      expect(await items.getById('a'), isNull);
      expect(await items.getById('b'), isNull);
      expect(await items.getById('keep'), isNotNull);
    });
  });

  group('UndoProcessDecision', () {
    late ProcessInboxDecisionUseCase decide;
    late UndoProcessDecision undo;

    setUp(() {
      decide = ProcessInboxDecisionUseCase(
        saveItem: saveItem,
        trashItem: trash,
        completeItem: complete,
        convertToProject: ConvertToProject(
          projects: ProjectRepository(db),
          saveItem: saveItem,
          clock: clock,
          ids: ids,
        ),
      );
      undo = UndoProcessDecision(
        saveItem: saveItem,
        restoreTrashedItem: restore,
        undoComplete: UndoComplete(
          items: items,
          scheduler: scheduler,
          saveItem: saveItem,
        ),
      );
    });

    Future<Item> seedInbox() async {
      final item = make('i', status: ItemStatus.inbox);
      await items.upsert(item);
      return item;
    }

    for (final d in <ProcessingDecision>[
      const ReferenceDecision(),
      const SomedayDecision(),
      const WaitingDecision('Bob'),
      const ToCalendarDecision(),
      const ToNextActionDecision(energy: Energy.low),
      const TrashDecision(),
    ]) {
      test('${d.runtimeType} is reversed back to the inbox', () async {
        final item = await seedInbox();
        final spawned = await decide(item, d);

        await undo(item, d, spawnedRecurrenceId: spawned);

        final back = (await items.getById('i'))!;
        expect(back.status, ItemStatus.inbox);
        expect(back.energy, isNull);
        expect(back.waitingOn, isNull);
      });
    }

    test('DoItNow is reversed, including the spawned recurrence', () async {
      final item = make(
        'i',
        status: ItemStatus.inbox,
        deferUntil: DateTime(2026, 5, 14),
      ).copyWith(recurrence: Recurrence.daily);
      await items.upsert(item);

      final spawned = await decide(item, const DoItNowDecision());
      expect(spawned, isNotNull);
      expect((await items.getById('i'))!.status, ItemStatus.done);

      await undo(item, const DoItNowDecision(), spawnedRecurrenceId: spawned);

      final back = (await items.getById('i'))!;
      expect(back.status, ItemStatus.inbox);
      expect(back.completedAt, isNull);
      expect(back.isTwoMin, item.isTwoMin);
      expect(await items.getById(spawned!), isNull);
    });

    test('only Convert-to-Project is not undoable', () {
      expect(const ToProjectDecision().isUndoable, isFalse);
      expect(const TrashDecision().isUndoable, isTrue);
      expect(const DoItNowDecision().isUndoable, isTrue);
    });
  });
}
