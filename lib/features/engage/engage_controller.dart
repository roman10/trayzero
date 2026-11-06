import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';

/// Immutable filter selection for the Engage ("Do now") screen.
/// A `null` field means "no constraint on that dimension".
class EngageFilter {
  const EngageFilter({
    this.contextId,
    this.energy,
    this.maxTimeMinutes,
    this.tagId,
  });

  final String? contextId;
  final Energy? energy;
  final int? maxTimeMinutes;

  /// One tag at a time (ADR 0010); null = any.
  final String? tagId;

  bool get isEmpty =>
      contextId == null &&
      energy == null &&
      maxTimeMinutes == null &&
      tagId == null;

  EngageFilter withContext(String? id) => EngageFilter(
    contextId: id,
    energy: energy,
    maxTimeMinutes: maxTimeMinutes,
    tagId: tagId,
  );

  EngageFilter withEnergy(Energy? e) => EngageFilter(
    contextId: contextId,
    energy: e,
    maxTimeMinutes: maxTimeMinutes,
    tagId: tagId,
  );

  EngageFilter withMaxTime(int? minutes) => EngageFilter(
    contextId: contextId,
    energy: energy,
    maxTimeMinutes: minutes,
    tagId: tagId,
  );

  EngageFilter withTag(String? id) => EngageFilter(
    contextId: contextId,
    energy: energy,
    maxTimeMinutes: maxTimeMinutes,
    tagId: id,
  );

  @override
  bool operator ==(Object other) =>
      other is EngageFilter &&
      other.contextId == contextId &&
      other.energy == energy &&
      other.maxTimeMinutes == maxTimeMinutes &&
      other.tagId == tagId;

  @override
  int get hashCode => Object.hash(contextId, energy, maxTimeMinutes, tagId);
}

/// Pure filter applied to the next-actions list. Kept free of Riverpod so it
/// is unit-testable in isolation. [itemTags] maps Item id → tag ids; it is
/// only read when a tag is selected.
List<Item> applyEngageFilter(
  List<Item> items,
  EngageFilter f, {
  Map<String, List<String>> itemTags = const {},
}) {
  return items.where((i) {
    if (f.contextId != null && i.contextId != f.contextId) return false;
    if (f.tagId != null && !(itemTags[i.id]?.contains(f.tagId) ?? false)) {
      return false;
    }
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
  void setTag(String? id) => state = state.withTag(id);
  void clear() => state = const EngageFilter();
}

final engageFilterProvider =
    StateNotifierProvider<EngageFilterController, EngageFilter>(
      (ref) => EngageFilterController(),
    );

/// The selected tag filter, or null when none is selected or the tag has
/// since been deleted (a deleted tag's filter clears itself).
final engageFilterTagProvider = Provider.autoDispose<Tag?>((ref) {
  final id = ref.watch(engageFilterProvider.select((f) => f.tagId));
  if (id == null) return null;
  final tags = ref.watch(tagsProvider).valueOrNull ?? const [];
  return tags.where((t) => t.id == id).firstOrNull;
});

/// Read model the screen watches: next actions with the active filter
/// applied. Keeps filtering out of the widget tree.
final filteredNextActionsProvider =
    Provider.autoDispose<AsyncValue<List<Item>>>((ref) {
      final actions = ref.watch(nextActionsProvider);
      var filter = ref.watch(engageFilterProvider);
      if (filter.tagId != null) {
        // Tags still loading: keep the selection. Deleted: ignore it.
        final tags = ref.watch(tagsProvider).valueOrNull;
        if (tags != null && !tags.any((t) => t.id == filter.tagId)) {
          filter = filter.withTag(null);
        }
      }
      final itemTags = filter.tagId == null
          ? const <String, List<String>>{}
          : ref.watch(itemTagIdsProvider).valueOrNull ?? const {};
      return actions.whenData(
        (list) => applyEngageFilter(list, filter, itemTags: itemTags),
      );
    });
