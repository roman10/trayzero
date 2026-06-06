import 'package:cleartray/application/providers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// The Review screen splits due items into "needs re-decision" (past) vs the
/// live Calendar (today + upcoming). The two must partition the set with no
/// overlap so nothing appears twice.
void main() {
  late TestEnv env;

  setUp(() async =>
      env = await TestEnv.create(now: DateTime(2026, 5, 16, 12)));
  tearDown(() => env.dispose());

  test('past-due vs calendar partition is correct and disjoint', () async {
    final container = env.container();
    final repo = container.read(itemRepositoryProvider);

    await repo.upsert(anItem(
        id: 'yesterday',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 15, 9)));
    await repo.upsert(anItem(
        id: 'tomorrow',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 17, 9)));
    await repo.upsert(anItem(
        id: 'now',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 16, 12)));
    await repo.upsert(anItem(
        id: 'recurring',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 13, 9),
        recurrence: Recurrence.weekly));
    await repo.upsert(anItem(
        id: 'cal-evt1',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 9, 9)));
    await repo.upsert(anItem(
        id: 'defer-future-due-past',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 10, 9),
        deferUntil: DateTime(2026, 5, 20, 9)));

    // Bind the underlying stream and let it emit.
    container.listen(pastDueItemsProvider, (_, _) {});
    container.listen(calendarItemsProvider, (_, _) {});
    await pumpEventQueue();

    final pastDue =
        container.read(pastDueItemsProvider).map((i) => i.id).toSet();
    final calendar =
        container.read(calendarItemsProvider).map((i) => i.id).toSet();

    expect(
        pastDue,
        {'yesterday', 'recurring', 'cal-evt1', 'defer-future-due-past'});
    expect(calendar, {'tomorrow', 'now'});
    expect(pastDue.intersection(calendar), isEmpty);
  });

  test('a dated next-action or someday item never reaches Calendar', () async {
    final container = env.container();
    final repo = container.read(itemRepositoryProvider);

    // Both carry a dueAt but are NOT committed to the hard landscape.
    await repo.upsert(anItem(
        id: 'soft-na',
        status: ItemStatus.nextAction,
        dueAt: DateTime(2026, 5, 10, 9))); // would be "overdue" by date
    await repo.upsert(anItem(
        id: 'soft-someday',
        status: ItemStatus.someday,
        dueAt: DateTime(2026, 5, 20, 9))); // would be "upcoming" by date

    container.listen(pastDueItemsProvider, (_, _) {});
    container.listen(calendarItemsProvider, (_, _) {});
    await pumpEventQueue();

    final pastDue =
        container.read(pastDueItemsProvider).map((i) => i.id).toSet();
    final calendar =
        container.read(calendarItemsProvider).map((i) => i.id).toSet();

    expect(pastDue, isEmpty);
    expect(calendar, isEmpty);
  });

  test('engageCalendarBandProvider = overdue + today, most-overdue first, '
      'excludes upcoming and non-calendar dated items', () async {
    final container = env.container();
    final repo = container.read(itemRepositoryProvider);

    await repo.upsert(anItem(
        id: 'today',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 16, 15)));
    await repo.upsert(anItem(
        id: 'over-1d',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 15, 9)));
    await repo.upsert(anItem(
        id: 'over-5d',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 11, 9)));
    await repo.upsert(anItem(
        id: 'upcoming',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 20, 9)));
    // Dated but not committed to the hard landscape — must not appear.
    await repo.upsert(anItem(
        id: 'soft-na',
        status: ItemStatus.nextAction,
        dueAt: DateTime(2026, 5, 12, 9)));

    container.listen(engageCalendarBandProvider, (_, _) {});
    await pumpEventQueue();

    final band =
        container.read(engageCalendarBandProvider).map((i) => i.id).toList();
    expect(band, ['over-5d', 'over-1d', 'today']);
  });

  test('rescheduling a past-due item moves it to the calendar and '
      'reschedules its reminders', () async {
    // Lead time is seeded through SharedPreferences (its real source).
    final leadEnv = await TestEnv.create(
      now: DateTime(2026, 5, 16, 12),
      prefsValues: const {'reminder_lead_time_minutes': 60},
    );
    addTearDown(leadEnv.dispose);
    final container = leadEnv.container();
    final repo = container.read(itemRepositoryProvider);
    await repo.upsert(anItem(
        id: 'late',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 10, 9)));

    container.listen(pastDueItemsProvider, (_, _) {});
    container.listen(calendarItemsProvider, (_, _) {});
    await pumpEventQueue();
    expect(container.read(pastDueItemsProvider).single.id, 'late');

    final newDue = DateTime(2026, 5, 20, 9);
    await container
        .read(saveItemProvider)
        .call(container.read(pastDueItemsProvider).single.copyWith(
              dueAt: newDue,
            ));
    await pumpEventQueue();

    expect(container.read(pastDueItemsProvider), isEmpty);
    expect(container.read(calendarItemsProvider).single.id, 'late');
    final scheduled = leadEnv.scheduler.scheduled;
    expect(scheduled.any((s) => s.title.startsWith('Due') && s.at == newDue),
        isTrue);
    expect(
        scheduled.any((s) =>
            s.title.startsWith('Soon') &&
            s.at == DateTime(2026, 5, 20, 8)),
        isTrue);
  });
}
