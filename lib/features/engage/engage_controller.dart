import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';

/// Immutable filter selection for the Engage ("Do now") screen.
/// A `null` field means "no constraint on that dimension".
class EngageFilter {
  const EngageFilter({this.contextId, this.energy, this.maxTimeMinutes});

  final String? contextId;
  final Energy? energy;
  final int? maxTimeMinutes;

  bool get isEmpty =>
      contextId == null && energy == null && maxTimeMinutes == null;

  EngageFilter withContext(String? id) =>
      EngageFilter(contextId: id, energy: energy, maxTimeMinutes: maxTimeMinutes);

  EngageFilter withEnergy(Energy? e) => EngageFilter(
      contextId: contextId, energy: e, maxTimeMinutes: maxTimeMinutes);

  EngageFilter withMaxTime(int? minutes) =>
      EngageFilter(contextId: contextId, energy: energy, maxTimeMinutes: minutes);

  @override
  bool operator ==(Object other) =>
      other is EngageFilter &&
      other.contextId == contextId &&
      other.energy == energy &&
      other.maxTimeMinutes == maxTimeMinutes;

  @override
  int get hashCode => Object.hash(contextId, energy, maxTimeMinutes);
}

/// Pure filter applied to the next-actions list. Kept free of Riverpod so it
/// is unit-testable in isolation.
List<Item> applyEngageFilter(List<Item> items, EngageFilter f) {
  return items.where((i) {
    if (f.contextId != null && i.contextId != f.contextId) return false;
    if (f.energy != null && i.energy != f.energy) return false;
    final maxTime = f.maxTimeMinutes;
    if (maxTime != null) {
      final t = i.timeEstimateMinutes;
      if (t == null || t > maxTime) return false;
    }
    return true;
  }).toList();
}

class EngageFilterController extends StateNotifier<EngageFilter> {
  EngageFilterController() : super(const EngageFilter());

  void setContext(String? id) => state = state.withContext(id);
  void setEnergy(Energy? e) => state = state.withEnergy(e);
  void setMaxTime(int? minutes) => state = state.withMaxTime(minutes);
  void clear() => state = const EngageFilter();
}

final engageFilterProvider =
    StateNotifierProvider<EngageFilterController, EngageFilter>(
        (ref) => EngageFilterController());

/// Read model the screen watches: next actions with the active filter
/// applied. Keeps filtering out of the widget tree.
final filteredNextActionsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final actions = ref.watch(nextActionsProvider);
  final filter = ref.watch(engageFilterProvider);
  return actions.whenData((list) => applyEngageFilter(list, filter));
});
