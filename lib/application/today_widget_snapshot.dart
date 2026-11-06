import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/home_widget_bridge.dart';
import '../domain/entities/entities.dart';
import '../domain/today_focus.dart';
import 'current_time.dart';
import 'providers.dart';

/// Rows the snapshot carries. Native layouts show at most this many (the
/// large iOS widget); smaller layouts fold the rest into "+N more".
const todayWidgetMaxRows = 8;

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Pure: builds the Today widget snapshot (ADR 0009) from the focused-items
/// stream, which arrives in focus order. Lists open Items focused on the
/// current local day; carry-over is excluded, matching the Today list.
TodayWidgetSnapshot buildTodayWidgetSnapshot(List<Item> items, DateTime now) {
  final local = now.toLocal();
  final open = <Item>[];
  var done = 0;
  for (final item in items) {
    final completedAt = item.completedAt;
    if (completedAt != null || item.status == ItemStatus.done) {
      if (completedAt != null && _sameDay(completedAt.toLocal(), local)) {
        done++;
      }
      continue;
    }
    if (isFocusedToday(item, local)) open.add(item);
  }
  final shown = open.take(todayWidgetMaxRows).toList();
  return TodayWidgetSnapshot(
    day: DateTime(local.year, local.month, local.day),
    items: [for (final i in shown) (id: i.id, title: i.title)],
    more: open.length - shown.length,
    done: done,
  );
}

/// The current Today widget snapshot. Watched from `main()`, which
/// publishes each new value; `null` until the focused stream has loaded.
final todayWidgetSnapshotProvider = Provider.autoDispose<TodayWidgetSnapshot?>((
  ref,
) {
  final now = ref.watch(currentTimeProvider);
  final items = ref.watch(focusedItemsProvider).valueOrNull;
  return items == null ? null : buildTodayWidgetSnapshot(items, now);
});
