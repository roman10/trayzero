import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/domain/entities/entities.dart';

void main() {
  group('Item.copyWith', () {
    final now = DateTime(2026, 5, 14, 10);
    final base = Item(
      id: 'a',
      title: 'Capture this',
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    );

    test('preserves unset fields and updates set fields', () {
      final updated = base.copyWith(
        title: 'Refined',
        status: ItemStatus.nextAction,
        energy: Energy.high,
        timeEstimateMinutes: 15,
      );
      expect(updated.id, 'a');
      expect(updated.title, 'Refined');
      expect(updated.status, ItemStatus.nextAction);
      expect(updated.energy, Energy.high);
      expect(updated.timeEstimateMinutes, 15);
      expect(updated.createdAt, now);
    });

    test('clearProject explicitly drops the project link', () {
      final assigned = base.copyWith(projectId: 'p1');
      final cleared = assigned.copyWith(clearProject: true);
      expect(assigned.projectId, 'p1');
      expect(cleared.projectId, isNull);
    });

    test('clearDueAt drops the due date', () {
      final due = base.copyWith(dueAt: DateTime(2026, 6, 1));
      final cleared = due.copyWith(clearDueAt: true);
      expect(cleared.dueAt, isNull);
    });

    test('clearRecurrence also drops the end condition (invariant)', () {
      final recurring = base.copyWith(
        recurrence: Recurrence.weekly,
        recurrenceUntil: DateTime(2026, 12, 31),
        recurrenceCount: 5,
        recurrenceDoneCount: 2,
      );
      final off = recurring.copyWith(clearRecurrence: true);
      expect(off.recurrence, isNull);
      expect(off.recurrenceUntil, isNull);
      expect(off.recurrenceCount, isNull);
      expect(off.recurrenceDoneCount, 0);
    });

    test('clearRecurrenceUntil / clearRecurrenceCount drop only their field',
        () {
      final withUntil = base.copyWith(
        recurrence: Recurrence.daily,
        recurrenceUntil: DateTime(2026, 12, 31),
      );
      expect(withUntil.copyWith(clearRecurrenceUntil: true).recurrenceUntil,
          isNull);
      final withCount =
          base.copyWith(recurrence: Recurrence.daily, recurrenceCount: 4);
      expect(withCount.copyWith(clearRecurrenceCount: true).recurrenceCount,
          isNull);
    });

    test('marking complete', () {
      final completed = base.copyWith(
        status: ItemStatus.done,
        completedAt: now.add(const Duration(minutes: 1)),
      );
      expect(completed.status, ItemStatus.done);
      expect(completed.completedAt, isNotNull);
    });
  });
}
