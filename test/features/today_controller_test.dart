import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/engage/today_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 26, 10);
  final yesterday = DateTime(2026, 10, 25, 9);
  Item item(
    String id, {
    ItemStatus status = ItemStatus.nextAction,
    DateTime? focusedAt,
    DateTime? completedAt,
    DateTime? deferUntil,
    DateTime? dueAt,
    ItemStatus? previousStatus,
  }) => Item(
    id: id,
    title: id,
    status: status,
    focusedAt: focusedAt,
    completedAt: completedAt,
    deferUntil: deferUntil,
    dueAt: dueAt,
    previousStatus: previousStatus,
    createdAt: yesterday,
    updatedAt: yesterday,
  );

  group('buildTodayView', () {
    test('splits focused, carried over, and done today', () {
      final view = buildTodayView([
        item('today', focusedAt: now),
        item('old', focusedAt: yesterday),
        item(
          'done',
          status: ItemStatus.done,
          focusedAt: now,
          completedAt: now,
        ),
        item(
          'doneYesterday',
          status: ItemStatus.done,
          focusedAt: yesterday,
          completedAt: yesterday,
        ),
      ], now);
      expect(view.focused.map((i) => i.id), ['today']);
      expect(view.carriedOver.map((i) => i.id), ['old']);
      expect(view.doneToday, 1);
    });

    test('items already in the Calendar band are not repeated', () {
      final view = buildTodayView(
        [
          item('cal', status: ItemStatus.calendar, focusedAt: now),
          item('calOld', status: ItemStatus.calendar, focusedAt: yesterday),
          item('old', focusedAt: yesterday),
        ],
        now,
        exclude: {'cal', 'calOld'},
      );
      expect(view.focused, isEmpty);
      expect(view.carriedOver.map((i) => i.id), ['old']);
    });

    test('counts calendar items due and completed today, once', () {
      final doneFocused = item(
        'both',
        status: ItemStatus.done,
        focusedAt: now,
        completedAt: now,
        dueAt: now,
      );
      final view = buildTodayView(
        [doneFocused],
        now,
        completed: [
          doneFocused,
          item(
            'calDone',
            status: ItemStatus.done,
            previousStatus: ItemStatus.calendar,
            completedAt: now,
            dueAt: DateTime(2026, 10, 26, 15),
          ),
          item(
            'overdueDone',
            status: ItemStatus.done,
            previousStatus: ItemStatus.calendar,
            completedAt: now,
            dueAt: yesterday,
          ),
          item(
            'undatedDone',
            status: ItemStatus.done,
            previousStatus: ItemStatus.calendar,
            completedAt: now,
          ),
        ],
      );
      expect(view.doneToday, 2);
    });

    test('does not count completed non-calendar items that had a dueAt', () {
      final due = DateTime(2026, 10, 26, 15);
      final view = buildTodayView(
        [],
        now,
        completed: [
          item(
            'waitingDone',
            status: ItemStatus.done,
            previousStatus: ItemStatus.waiting,
            completedAt: now,
            dueAt: due,
          ),
          item(
            'projectDone',
            status: ItemStatus.done,
            previousStatus: ItemStatus.project,
            completedAt: now,
            dueAt: due,
          ),
          item(
            'legacyDone',
            status: ItemStatus.done,
            completedAt: now,
            dueAt: due,
          ),
        ],
      );
      expect(view.doneToday, 0);
    });
  });

  group('buildDailyPlan', () {
    test('sorts suggestions into sections, each Item once', () {
      final plan = buildDailyPlan(
        band: [item('cal', status: ItemStatus.calendar, dueAt: now)],
        waiting: [
          item('followUp', status: ItemStatus.waiting, deferUntil: now),
          item('dueFollowUp', status: ItemStatus.waiting, dueAt: yesterday),
          item(
            'later',
            status: ItemStatus.waiting,
            deferUntil: DateTime(2026, 10, 30),
          ),
          item('undated', status: ItemStatus.waiting),
        ],
        nextActions: [
          item('fresh', deferUntil: DateTime(2026, 10, 26)),
          item('plain'),
          item('carried'),
        ],
        now: now,
        exclude: {'carried'},
      );
      expect(plan.calendar.map((i) => i.id), ['cal']);
      expect(plan.waiting.map((i) => i.id), ['followUp', 'dueFollowUp']);
      expect(plan.available.map((i) => i.id), ['fresh']);
      expect(plan.nextActions.map((i) => i.id), ['plain']);
      expect(plan.isEmpty, isFalse);
    });

    test('is empty with nothing to suggest', () {
      expect(
        buildDailyPlan(band: [], waiting: [], nextActions: [], now: now)
            .isEmpty,
        isTrue,
      );
    });
  });
}
