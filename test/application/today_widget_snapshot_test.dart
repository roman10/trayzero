import 'package:cleartray/application/today_widget_snapshot.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Today widget snapshot (ADR 0009).
void main() {
  final now = DateTime(2026, 10, 26, 15);
  final created = DateTime(2026, 10, 20);

  Item item(
    String id, {
    DateTime? focusedAt,
    DateTime? completedAt,
    ItemStatus status = ItemStatus.nextAction,
  }) => Item(
    id: id,
    title: 'Title $id',
    status: completedAt != null ? ItemStatus.done : status,
    createdAt: created,
    updatedAt: created,
    focusedAt: focusedAt,
    completedAt: completedAt,
  );

  test('lists open Items focused today in stream order', () {
    final s = buildTodayWidgetSnapshot([
      item('b', focusedAt: DateTime(2026, 10, 26, 8)),
      item('a', focusedAt: DateTime(2026, 10, 26, 9)),
    ], now);
    expect(s.items, [(id: 'b', title: 'Title b'), (id: 'a', title: 'Title a')]);
    expect(s.more, 0);
    expect(s.done, 0);
    expect(s.day, DateTime(2026, 10, 26));
  });

  test('excludes carry-over and counts only today\'s completions', () {
    final s = buildTodayWidgetSnapshot([
      item('old', focusedAt: DateTime(2026, 10, 25, 9)),
      item(
        'doneToday',
        focusedAt: DateTime(2026, 10, 26, 8),
        completedAt: DateTime(2026, 10, 26, 10),
      ),
      item(
        'doneYesterday',
        focusedAt: DateTime(2026, 10, 25, 8),
        completedAt: DateTime(2026, 10, 25, 10),
      ),
      item('today', focusedAt: DateTime(2026, 10, 26, 7)),
    ], now);
    expect(s.items.map((r) => r.id), ['today']);
    expect(s.done, 1);
  });

  test('caps the rows and reports the rest as more', () {
    final s = buildTodayWidgetSnapshot([
      for (var i = 0; i < todayWidgetMaxRows + 3; i++)
        item('i$i', focusedAt: DateTime(2026, 10, 26, 8, i)),
    ], now);
    expect(s.items, hasLength(todayWidgetMaxRows));
    expect(s.more, 3);
  });

  test('serializes to the versioned JSON native code reads', () {
    final s = buildTodayWidgetSnapshot([
      item('a', focusedAt: DateTime(2026, 10, 26, 8)),
    ], DateTime(2026, 3, 5, 9));
    // Focused on another day than "now": carry-over, not listed.
    expect(s.toJson(), {
      'v': 1,
      'day': '2026-03-05',
      'items': <Object>[],
      'more': 0,
      'done': 0,
    });
  });
}
