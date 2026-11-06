import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/item_invariants.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

void main() {
  test('refiling preserves an existing recurrence tickler', () {
    final defer = DateTime(2026, 5, 15);
    final changed = changeItemStatus(
      anItem(
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 20),
        deferUntil: defer,
        recurrence: Recurrence.weekly,
      ),
      ItemStatus.nextAction,
    );
    expect(changed.deferUntil, defer);
    expect(changed.dueAt, isNull);
  });

  test('refiling a one-off commitment does not create a tickler', () {
    final changed = changeItemStatus(
      anItem(status: ItemStatus.calendar, dueAt: DateTime(2026, 5, 20)),
      ItemStatus.nextAction,
    );
    expect(changed.deferUntil, isNull);
    expect(changed.dueAt, isNull);
  });

  test('refiling a repeating Calendar item preserves its series', () async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final c = env.container();
    final due = env.clock.now().add(const Duration(days: 2));
    final saved = await c.read(saveItemProvider)(
      changeItemStatus(
        anItem(
          id: 'repeat',
          status: ItemStatus.calendar,
          dueAt: due,
          recurrence: Recurrence.daily,
        ),
        ItemStatus.nextAction,
      ),
    );
    expect(saved.dueAt, isNull);
    expect(saved.deferUntil, due);
    final nextId = await c.read(completeItemProvider)('repeat');
    expect(nextId, isNotNull);
    final next = await c.read(itemRepositoryProvider).getById(nextId!);
    expect(next!.deferUntil, due.add(const Duration(days: 1)));
  });

  test('undated Calendar filing rejects before persistence', () {
    final item = anItem(status: ItemStatus.nextAction);
    expect(
      () => changeItemStatus(item, ItemStatus.calendar),
      throwsArgumentError,
    );
  });

  test(
    'Calendar filing persists its chosen date and appears in Calendar',
    () async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final c = env.container();
      final due = env.clock.now().add(const Duration(days: 2));
      await c.read(saveItemProvider)(
        changeItemStatus(
          anItem(id: 'a', status: ItemStatus.nextAction),
          ItemStatus.calendar,
          dueAt: due,
        ),
      );
      final calendar = await c
          .read(itemRepositoryProvider)
          .watchCalendar()
          .first;
      expect(calendar.single.dueAt, due);
    },
  );

  test(
    'filing completed work reopens it and restores list visibility',
    () async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final c = env.container();
      final item = anItem(
        id: 'a',
        status: ItemStatus.done,
        completedAt: env.clock.now(),
        previousStatus: ItemStatus.calendar,
      );
      final saved = await c.read(saveItemProvider)(
        changeItemStatus(item, ItemStatus.nextAction),
      );
      expect(saved.completedAt, isNull);
      expect(saved.previousStatus, isNull);
      expect(
        (await c.read(itemRepositoryProvider).watchNextActions().first)
            .single
            .id,
        'a',
      );
    },
  );

  for (final status in [
    ItemStatus.done,
    ItemStatus.trashed,
    ItemStatus.waiting,
  ]) {
    test('editing $status completed work cancels all reminders', () async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final c = env.container();
      final future = env.clock.now().add(const Duration(days: 2));
      await c.read(saveItemProvider)(
        anItem(
          id: 'a',
          status: status,
          completedAt: status == ItemStatus.waiting ? env.clock.now() : null,
          dueAt: future,
          deferUntil: future,
        ).copyWith(title: 'Edited history'),
      );
      expect(env.scheduler.scheduled, isEmpty);
      for (final salt in [1, 2, 3]) {
        expect(env.scheduler.cancelled, contains(notificationIdFor('a', salt)));
      }
    });
  }
}
