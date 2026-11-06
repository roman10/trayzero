import 'package:cleartray/application/complete_item.dart';
import 'package:cleartray/application/finish_daily_review.dart';
import 'package:cleartray/application/mark_project_reviewed.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/application/set_today_focus.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// Today focus and per-project review persistence (ADR 0007).
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late ItemRepository items;
  late SetTodayFocus focus;
  final created = DateTime(2026, 10, 20, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 10, 26, 9));
    items = ItemRepository(db, clock);
    focus = SetTodayFocus(items: items, clock: clock);
  });
  tearDown(() => db.close());

  Item item(
    String id, {
    ItemStatus status = ItemStatus.nextAction,
    String? projectId,
  }) => Item(
    id: id,
    title: id,
    status: status,
    projectId: projectId,
    createdAt: created,
    updatedAt: created,
  );

  test('starring stamps now without touching updatedAt; Undo restores',
      () async {
    await items.upsert(item('a'));
    final previous = await focus([item('a')], focused: true);
    final starred = (await items.getById('a'))!;
    expect(starred.focusedAt, clock.now());
    expect(starred.updatedAt, created);

    await focus.restore(previous);
    expect((await items.getById('a'))!.focusedAt, isNull);
  });

  test('a stale star on an Item filed elsewhere is a no-op', () async {
    await items.upsert(item('s', status: ItemStatus.someday));
    await focus([item('s')], focused: true);
    expect((await items.getById('s'))!.focusedAt, isNull);
  });

  test('filing a focused Item to Someday drops its focus', () async {
    await items.upsert(item('a'));
    await focus([item('a')], focused: true);
    final focused = (await items.getById('a'))!;
    await items.upsert(focused.copyWith(status: ItemStatus.someday));
    expect((await items.getById('a'))!.focusedAt, isNull);
  });

  test('completing keeps the stamp; the recurrence successor is unfocused',
      () async {
    final scheduler = FakeNotificationScheduler();
    final save = SaveItem(items: items, scheduler: scheduler, clock: clock);
    final complete = CompleteItem(
      items: items,
      scheduler: scheduler,
      clock: clock,
      ids: FixedIdGenerator(['next']),
      saveItem: save,
    );
    await items.upsert(
      item('r').copyWith(
        recurrence: Recurrence.daily,
        deferUntil: DateTime(2026, 10, 26),
      ),
    );
    await focus([item('r')], focused: true);
    final spawned = await complete('r');
    expect(spawned, 'next');
    expect((await items.getById('r'))!.focusedAt, clock.now());
    expect((await items.getById('next'))!.focusedAt, isNull);
  });

  test('watchFocused keeps open carry-over and only today\'s completions',
      () async {
    await items.upsertAll([
      item('open'),
      item('doneToday'),
      item('doneLongAgo'),
      item('never'),
    ]);
    await items.setFocusedAt({
      'open': DateTime(2026, 10, 1),
      'doneToday': clock.now(),
      'doneLongAgo': DateTime(2026, 10, 1),
    });
    await items.markCompleted('doneToday', clock.now());
    await items.markCompleted('doneLongAgo', DateTime(2026, 10, 2));

    final focused = await items
        .watchFocused(since: DateTime(2026, 10, 26))
        .first;
    expect(focused.map((i) => i.id).toSet(), {'open', 'doneToday'});
  });

  test('finishing the daily plan clears un-kept focus and logs a review',
      () async {
    await items.upsertAll([item('kept'), item('dropped')]);
    await items.setFocusedAt({
      'kept': clock.now(),
      'dropped': DateTime(2026, 10, 24),
    });
    final reviews = ReviewRepository(db);
    final finish = FinishDailyReview(
      database: db,
      items: items,
      reviews: reviews,
      clock: clock,
      ids: FixedIdGenerator(['daily-1']),
    );
    final dropped = (await items.getById('dropped'))!;
    final cleared = await finish(notKept: [dropped]);

    expect(cleared, {'dropped': DateTime(2026, 10, 24)});
    expect((await items.getById('dropped'))!.focusedAt, isNull);
    expect((await items.getById('kept'))!.focusedAt, clock.now());
    final daily = await reviews.watchLatestCompletedDaily().first;
    expect(daily!.id, 'daily-1');
    expect(daily.type, ReviewType.daily);
    expect(daily.completedAt, clock.now());

    // Undo puts the carry-over back.
    await focus.restore(cleared);
    expect((await items.getById('dropped'))!.focusedAt, DateTime(2026, 10, 24));
  });

  group('projects', () {
    late ProjectRepository projects;
    setUp(() => projects = ProjectRepository(db));

    test('marking reviewed stamps lastReviewedAt, not updatedAt', () async {
      await projects.upsert(
        Project(
          id: 'p',
          title: 'Garage',
          status: ProjectStatus.active,
          createdAt: created,
          updatedAt: created,
        ),
      );
      await MarkProjectReviewed(projects: projects, clock: clock)('p');
      final p = (await projects.getById('p'))!;
      expect(p.lastReviewedAt, clock.now());
      expect(p.updatedAt, created);
    });

    test('activity is the latest non-trashed Item update per Project',
        () async {
      await items.upsertAll([
        item('a', projectId: 'p').copyWith(updatedAt: DateTime(2026, 10, 1)),
        item('b', projectId: 'p').copyWith(updatedAt: DateTime(2026, 10, 9)),
        item(
          't',
          projectId: 'p',
          status: ItemStatus.trashed,
        ).copyWith(updatedAt: DateTime(2026, 10, 25)),
        item('q', projectId: 'q').copyWith(updatedAt: DateTime(2026, 9, 1)),
      ]);
      final activity = await items.watchProjectActivity().first;
      expect(activity, {
        'p': DateTime(2026, 10, 9),
        'q': DateTime(2026, 9, 1),
      });
    });
  });
}
