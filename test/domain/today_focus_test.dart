import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/item_invariants.dart';
import 'package:cleartray/domain/today_focus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 26, 9);
  Item item({
    ItemStatus status = ItemStatus.nextAction,
    DateTime? focusedAt,
    DateTime? completedAt,
  }) => Item(
    id: 'i',
    title: 'Call Bob',
    status: status,
    focusedAt: focusedAt,
    completedAt: completedAt,
    createdAt: now,
    updatedAt: now,
  );

  test('only actionable statuses (and done, for Undo) hold focus', () {
    expect(
      ItemStatus.values.where(canHoldFocus).toSet(),
      {
        ItemStatus.nextAction,
        ItemStatus.waiting,
        ItemStatus.calendar,
        ItemStatus.done,
      },
    );
    expect(canFocus(item(status: ItemStatus.done)), isFalse);
    expect(canFocus(item(status: ItemStatus.inbox)), isFalse);
    expect(canFocus(item(status: ItemStatus.waiting)), isTrue);
  });

  test('focus stamped today is in Today; earlier days carry over', () {
    final today = item(focusedAt: DateTime(2026, 10, 26, 0, 1));
    expect(isFocusedToday(today, now), isTrue);
    expect(isCarriedOver(today, now), isFalse);

    final yesterday = item(focusedAt: DateTime(2026, 10, 25, 23, 59));
    expect(isFocusedToday(yesterday, now), isFalse);
    expect(isCarriedOver(yesterday, now), isTrue);

    expect(isFocusedToday(item(), now), isFalse);
    expect(isCarriedOver(item(), now), isFalse);
  });

  test('midnight rollover moves today\'s focus to carry-over', () {
    final focused = item(focusedAt: DateTime(2026, 10, 26, 22));
    final afterMidnight = DateTime(2026, 10, 27, 0, 0, 1);
    expect(isFocusedToday(focused, afterMidnight), isFalse);
    expect(isCarriedOver(focused, afterMidnight), isTrue);
  });

  test('a completed Item is never carried over', () {
    final done = item(
      status: ItemStatus.done,
      focusedAt: DateTime(2026, 10, 20),
      completedAt: DateTime(2026, 10, 21),
    );
    expect(isCarriedOver(done, now), isFalse);
  });

  test('moving an Item off actionable lists drops its focus', () {
    final focused = item(focusedAt: now);
    for (final status in [
      ItemStatus.inbox,
      ItemStatus.someday,
      ItemStatus.reference,
      ItemStatus.trashed,
      ItemStatus.project,
    ]) {
      expect(
        enforceItemInvariants(focused.copyWith(status: status)).focusedAt,
        isNull,
        reason: status.name,
      );
    }
    for (final status in [
      ItemStatus.waiting,
      ItemStatus.calendar,
      ItemStatus.done,
    ]) {
      expect(
        enforceItemInvariants(focused.copyWith(status: status)).focusedAt,
        now,
        reason: status.name,
      );
    }
  });
}
