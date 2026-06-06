import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/recurrence/recurrence_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Item base({
    Recurrence? r,
    int interval = 1,
    DateTime? dueAt,
    DateTime? deferUntil,
    DateTime? until,
    int? count,
    int doneCount = 0,
  }) =>
      Item(
        id: 'orig',
        title: 'Water plants',
        // Calendar keeps a hard `dueAt`, so these tests assert the rule's
        // date math directly. The next-action anchor-folding rule (Option A)
        // has its own test below.
        status: ItemStatus.calendar,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
        recurrence: r,
        recurrenceInterval: interval,
        dueAt: dueAt,
        deferUntil: deferUntil,
        recurrenceUntil: until,
        recurrenceCount: count,
        recurrenceDoneCount: doneCount,
      );

  test('non-recurring items roll over to null', () {
    final next = nextRecurrenceOf(base(),
        completedAt: DateTime(2026, 5, 14), newId: 'n');
    expect(next, isNull);
  });

  test('daily recurrence advances dueAt by interval days', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.daily, interval: 3, dueAt: DateTime(2026, 5, 14, 9)),
      completedAt: DateTime(2026, 5, 14, 10),
      newId: 'new-id',
    );
    expect(next, isNotNull);
    expect(next!.dueAt, DateTime(2026, 5, 17, 9));
    expect(next.id, 'new-id');
    expect(next.recurrence, Recurrence.daily);
    expect(next.recurrenceInterval, 3);
  });

  test('weekly recurrence advances 7 * interval days', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.weekly, interval: 2, dueAt: DateTime(2026, 5, 14)),
      completedAt: DateTime(2026, 5, 14),
      newId: 'n',
    );
    expect(next!.dueAt, DateTime(2026, 5, 14).add(const Duration(days: 14)));
  });

  test('monthly recurrence preserves day-of-month', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.monthly, dueAt: DateTime(2026, 5, 14, 9)),
      completedAt: DateTime(2026, 5, 14),
      newId: 'n',
    );
    expect(next!.dueAt, DateTime(2026, 6, 14, 9));
  });

  test('yearly recurrence preserves month + day', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.yearly, dueAt: DateTime(2026, 5, 14)),
      completedAt: DateTime(2026, 5, 14),
      newId: 'n',
    );
    expect(next!.dueAt, DateTime(2027, 5, 14));
  });

  test('rollover advances both dueAt and deferUntil when both present', () {
    final next = nextRecurrenceOf(
      base(
        r: Recurrence.weekly,
        dueAt: DateTime(2026, 5, 14),
        deferUntil: DateTime(2026, 5, 13),
      ),
      completedAt: DateTime(2026, 5, 14),
      newId: 'n',
    );
    expect(next!.dueAt, DateTime(2026, 5, 21));
    expect(next.deferUntil, DateTime(2026, 5, 20));
  });

  test('monthly recurrence clamps day to short months (Jan 31 -> Feb 28)', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.monthly, dueAt: DateTime(2026, 1, 31, 9)),
      completedAt: DateTime(2026, 1, 31),
      newId: 'n',
    );
    // 2026 is not a leap year: February has 28 days.
    expect(next!.dueAt, DateTime(2026, 2, 28, 9));
  });

  test('monthly recurrence rolls year over (Dec -> Jan next year)', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.monthly, dueAt: DateTime(2026, 12, 15)),
      completedAt: DateTime(2026, 12, 15),
      newId: 'n',
    );
    expect(next!.dueAt, DateTime(2027, 1, 15));
  });

  test('monthly with interval > 1 advances that many months', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.monthly, interval: 3, dueAt: DateTime(2026, 11, 10)),
      completedAt: DateTime(2026, 11, 10),
      newId: 'n',
    );
    expect(next!.dueAt, DateTime(2027, 2, 10));
  });

  test('yearly recurrence clamps Feb 29 to Feb 28 in non-leap years', () {
    final next = nextRecurrenceOf(
      base(r: Recurrence.yearly, dueAt: DateTime(2028, 2, 29, 8)),
      completedAt: DateTime(2028, 2, 29),
      newId: 'n',
    );
    // 2029 is not a leap year.
    expect(next!.dueAt, DateTime(2029, 2, 28, 8));
  });

  group('end condition — count cap', () {
    test('advances recurrenceDoneCount and carries the cap forward', () {
      final next = nextRecurrenceOf(
        base(r: Recurrence.daily, count: 3, dueAt: DateTime(2026, 5, 14)),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      expect(next, isNotNull);
      expect(next!.recurrenceDoneCount, 1);
      expect(next.recurrenceCount, 3);
    });

    test('completing the final allowed occurrence ends the series', () {
      // count=3, two already done → this is occurrence 3, the last one.
      final next = nextRecurrenceOf(
        base(
          r: Recurrence.daily,
          count: 3,
          doneCount: 2,
          dueAt: DateTime(2026, 5, 16),
        ),
        completedAt: DateTime(2026, 5, 16),
        newId: 'n',
      );
      expect(next, isNull);
    });

    test('chaining produces exactly count occurrences', () {
      Item? cur =
          base(r: Recurrence.daily, count: 3, dueAt: DateTime(2026, 5, 14));
      var spawned = 0;
      while (cur != null) {
        cur = nextRecurrenceOf(cur,
            completedAt: DateTime(2026, 5, 14), newId: 'n$spawned');
        if (cur != null) spawned++;
      }
      // original + 2 spawned = 3 total occurrences.
      expect(spawned, 2);
    });
  });

  group('no anchor date — series cannot continue', () {
    test('recurring item with neither due nor defer date does not spawn', () {
      final next = nextRecurrenceOf(
        base(r: Recurrence.daily),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      expect(next, isNull);
    });

    test('no anchor overrides a count cap — still no spawn', () {
      // Even with occurrences remaining on the count, a dateless clone
      // would be useless, so the series ends rather than cloning.
      final next = nextRecurrenceOf(
        base(r: Recurrence.daily, count: 5),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      expect(next, isNull);
    });

    test('an anchor on either field is enough to continue', () {
      final viaDefer = nextRecurrenceOf(
        base(r: Recurrence.daily, deferUntil: DateTime(2026, 5, 14)),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      expect(viaDefer, isNotNull);
      expect(viaDefer!.deferUntil, DateTime(2026, 5, 15));
    });
  });

  group('end condition — until date', () {
    test('stops once the next occurrence falls after the end date', () {
      final next = nextRecurrenceOf(
        base(
          r: Recurrence.weekly,
          dueAt: DateTime(2026, 5, 14),
          until: DateTime(2026, 5, 20),
        ),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      // Next would be May 21 — past the May 20 end date.
      expect(next, isNull);
    });

    test('includes an occurrence landing on the end day itself', () {
      final next = nextRecurrenceOf(
        base(
          r: Recurrence.weekly,
          dueAt: DateTime(2026, 5, 14, 9),
          until: DateTime(2026, 5, 21),
        ),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      expect(next, isNotNull);
      expect(next!.dueAt, DateTime(2026, 5, 21, 9));
      expect(next.recurrenceUntil, DateTime(2026, 5, 21));
    });

    test('uses deferUntil as the anchor when there is no due date', () {
      final next = nextRecurrenceOf(
        base(
          r: Recurrence.daily,
          deferUntil: DateTime(2026, 5, 14),
          until: DateTime(2026, 5, 14),
        ),
        completedAt: DateTime(2026, 5, 14),
        newId: 'n',
      );
      // Next defer date is May 15, past the May 14 end date.
      expect(next, isNull);
    });
  });

  test('weekly-by-weekday rolls over and carries the pattern forward', () {
    final completed = base(
      r: Recurrence.weekly,
      dueAt: DateTime(2026, 5, 13, 8), // a Wednesday
    ).copyWith(recurrenceByWeekdays: const [1, 3, 5]);
    final next = nextRecurrenceOf(
      completed,
      completedAt: DateTime(2026, 5, 13),
      newId: 'n',
    );
    // Wed → Fri (next selected weekday in the same week).
    expect(next!.dueAt, DateTime(2026, 5, 15, 8));
    expect(next.recurrenceByWeekdays, const [1, 3, 5]);
  });

  test('monthly nth-weekday carries the qualifier through rollover', () {
    final completed = base(
      r: Recurrence.monthly,
      dueAt: DateTime(2026, 5, 12, 9),
    ).copyWith(recurrenceMonthlyWeek: 2, recurrenceMonthlyWeekday: 2);
    final next = nextRecurrenceOf(
      completed,
      completedAt: DateTime(2026, 5, 12),
      newId: 'n',
    );
    // 2nd Tuesday of June 2026.
    expect(next!.dueAt, DateTime(2026, 6, 9, 9));
    expect(next.recurrenceMonthlyWeek, 2);
    expect(next.recurrenceMonthlyWeekday, 2);
  });

  test('rollover resets done status to next-action', () {
    final completed =
        base(r: Recurrence.daily, dueAt: DateTime(2026, 5, 14)).copyWith(
      status: ItemStatus.done,
      completedAt: DateTime(2026, 5, 14),
    );
    final next = nextRecurrenceOf(
      completed,
      completedAt: DateTime(2026, 5, 14),
      newId: 'n',
    );
    expect(next!.status, ItemStatus.nextAction);
  });

  group('Option A — next-action anchor folding', () {
    test('a recurring next action advances via deferUntil, never dueAt', () {
      final completed = base(
        r: Recurrence.weekly,
        deferUntil: DateTime(2026, 5, 14),
      ).copyWith(status: ItemStatus.nextAction);
      final next = nextRecurrenceOf(completed,
          completedAt: DateTime(2026, 5, 14), newId: 'n');
      expect(next!.dueAt, isNull);
      expect(next.deferUntil, DateTime(2026, 5, 21));
    });

    test('a dueAt-anchored series folds into deferUntil when it spawns a '
        'next action — the anchor survives the status rules', () {
      // A recurring item completed from `done` spawns a next action; its
      // advanced dueAt must move to deferUntil or the series would die.
      final completed = base(
        r: Recurrence.weekly,
        dueAt: DateTime(2026, 5, 14),
      ).copyWith(status: ItemStatus.done, completedAt: DateTime(2026, 5, 14));
      final next = nextRecurrenceOf(completed,
          completedAt: DateTime(2026, 5, 14), newId: 'n');
      expect(next!.status, ItemStatus.nextAction);
      expect(next.dueAt, isNull);
      expect(next.deferUntil, DateTime(2026, 5, 21));
    });

    test('a recurring calendar item keeps its dueAt anchor', () {
      final completed = base(
        r: Recurrence.weekly,
        dueAt: DateTime(2026, 5, 14),
      ); // base() is calendar
      final next = nextRecurrenceOf(completed,
          completedAt: DateTime(2026, 5, 14), newId: 'n');
      expect(next!.status, ItemStatus.calendar);
      expect(next.dueAt, DateTime(2026, 5, 21));
    });
  });
}
