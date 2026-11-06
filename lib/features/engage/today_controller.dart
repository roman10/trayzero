import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/current_time.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../domain/today_focus.dart';
import '../settings/settings_controller.dart';

/// The two views of the Do tab (ADR 0007). Next actions is the default so
/// users who never plan see the screen they always had.
enum DoView { today, nextActions }

const _kDoView = 'do_view';

/// Remembers the last Do view on this device.
class DoViewController extends StateNotifier<DoView> {
  DoViewController(this._prefs)
    : super(
        DoView.values.asNameMap()[_prefs.getString(_kDoView)] ??
            DoView.nextActions,
      );
  final SharedPreferences _prefs;

  Future<void> set(DoView view) async {
    state = view;
    await _prefs.setString(_kDoView, view.name);
  }
}

final doViewProvider = StateNotifierProvider<DoViewController, DoView>(
  (ref) => DoViewController(ref.watch(sharedPreferencesProvider)),
);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// What the Today view shows, derived from the focused-items stream.
class TodayView {
  const TodayView({
    required this.focused,
    required this.carriedOver,
    required this.doneToday,
  });

  /// Open Items committed to the current day, in the order they were starred.
  final List<Item> focused;

  /// Open Items focused on an earlier day, awaiting keep or clear.
  final List<Item> carriedOver;

  /// Items completed today that were focused, or were calendar items due
  /// today.
  final int doneToday;
}

/// Pure split of [items] into Today's sections. [exclude] holds ids already
/// shown in the Calendar band (calendar items are on Today by definition), so
/// no Item appears twice and band items are neither listed as focused nor
/// offered for a carry-over decision.
///
/// [completed] is the Items finished recently (any source). Those that were
/// Calendar items (`previousStatus`, captured at completion, since completing
/// overwrites the status), due today and completed today count as done even if
/// never focused, since the Calendar band put them on Today; an Item already
/// counted via [items] is not counted twice. Waiting items and others that
/// happen to carry a `dueAt` are not Calendar items and do not count unless
/// focused. Rows completed before `previousStatus` existed are not counted.
TodayView buildTodayView(
  List<Item> items,
  DateTime now, {
  Set<String> exclude = const {},
  List<Item> completed = const [],
}) {
  final focused = <Item>[];
  final carried = <Item>[];
  final doneIds = <String>{};
  for (final item in items) {
    final completedAt = item.completedAt;
    if (completedAt != null || item.status == ItemStatus.done) {
      if (completedAt != null && _sameDay(completedAt.toLocal(), now)) {
        doneIds.add(item.id);
      }
      continue;
    }
    if (exclude.contains(item.id)) continue;
    if (isFocusedToday(item, now)) {
      focused.add(item);
    } else if (isCarriedOver(item, now)) {
      carried.add(item);
    }
  }
  for (final item in completed) {
    final completedAt = item.completedAt;
    final dueAt = item.dueAt;
    if (item.previousStatus == ItemStatus.calendar &&
        completedAt != null &&
        dueAt != null &&
        _sameDay(completedAt.toLocal(), now) &&
        _sameDay(dueAt.toLocal(), now)) {
      doneIds.add(item.id);
    }
  }
  return TodayView(
    focused: focused,
    carriedOver: carried,
    doneToday: doneIds.length,
  );
}

final todayViewProvider = Provider.autoDispose<AsyncValue<TodayView>>((ref) {
  final now = ref.watch(currentTimeProvider);
  final band = ref.watch(engageCalendarBandProvider);
  final completed =
      ref.watch(completedTodayProvider).valueOrNull ?? const <Item>[];
  return ref
      .watch(focusedItemsProvider)
      .whenData(
        (items) => buildTodayView(
          items,
          now,
          exclude: {for (final i in band) i.id},
          completed: completed,
        ),
      );
});

/// Whether today's daily plan has been finished.
final plannedTodayProvider = Provider.autoDispose<bool>((ref) {
  final now = ref.watch(currentTimeProvider);
  final completedAt = ref
      .watch(latestDailyReviewProvider)
      .valueOrNull
      ?.completedAt;
  return completedAt != null && _sameDay(completedAt.toLocal(), now);
});

/// Suggestions for the daily plan, one list per section (ADR 0007). Each
/// Item appears in at most one section, in section order.
class DailyPlanSuggestions {
  const DailyPlanSuggestions({
    required this.calendar,
    required this.waiting,
    required this.available,
    required this.nextActions,
  });

  final List<Item> calendar;
  final List<Item> waiting;
  final List<Item> available;
  final List<Item> nextActions;

  bool get isEmpty =>
      calendar.isEmpty &&
      waiting.isEmpty &&
      available.isEmpty &&
      nextActions.isEmpty;
}

/// Pure: builds the plan sections. [band] is the calendar due today or
/// overdue; [waiting] all open Waiting Items; [nextActions] the available
/// Next Actions. Ids in [exclude] (the carry-over section) are skipped.
DailyPlanSuggestions buildDailyPlan({
  required List<Item> band,
  required List<Item> waiting,
  required List<Item> nextActions,
  required DateTime now,
  Set<String> exclude = const {},
}) {
  final endOfToday = DateTime(now.year, now.month, now.day + 1);
  bool keep(Item i) => !exclude.contains(i.id);

  final followUps = waiting.where((i) {
    final at = i.deferUntil ?? i.dueAt;
    return keep(i) && at != null && at.toLocal().isBefore(endOfToday);
  }).toList();

  final available = <Item>[];
  final rest = <Item>[];
  for (final i in nextActions) {
    if (!keep(i)) continue;
    final defer = i.deferUntil;
    if (defer != null && _sameDay(defer.toLocal(), now)) {
      available.add(i);
    } else {
      rest.add(i);
    }
  }
  return DailyPlanSuggestions(
    calendar: band.where(keep).toList(),
    waiting: followUps,
    available: available,
    nextActions: rest,
  );
}
