import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/search_text.dart';
import '../../domain/entities/entities.dart';

/// The status chips offered in the filter bar, in display order. Also the
/// single source for the statuses search treats as "live" (see
/// [_activeSearchStatuses]). `done` is deliberately absent: completed items
/// are governed solely by [SearchFilter.includeCompleted], and `trashed` is
/// never searchable (excluded at the repository query layer).
const searchStatusChips = <ItemStatus>[
  ItemStatus.inbox,
  ItemStatus.nextAction,
  ItemStatus.waiting,
  ItemStatus.someday,
  ItemStatus.reference,
  ItemStatus.calendar,
];

/// The allow-set applied when no status chip is selected — i.e. an empty
/// [SearchFilter.statuses] means *all of these* (the no-op default), never
/// "match nothing". Derived from [searchStatusChips] so the two cannot drift.
final _activeSearchStatuses = searchStatusChips.toSet();

/// Immutable filter selection for the Search screen. Mirrors the
/// `EngageFilter` pattern: `null`/empty fields mean "no constraint on that
/// dimension". Kept value-equal (including the [statuses] set) so Riverpod
/// does not re-derive results spuriously.
class SearchFilter {
  const SearchFilter({
    this.statuses = const {},
    this.includeCompleted = false,
    this.projectId,
    this.contextId,
  });

  /// Multi-select status narrowing. **Empty means "all active statuses"**
  /// (the default and common case), not "match nothing".
  final Set<ItemStatus> statuses;

  /// When true, completed (`done`) items are also surfaced. `trashed` is
  /// never included regardless of this flag.
  final bool includeCompleted;

  /// `null` = any project.
  final String? projectId;

  /// `null` = any context.
  final String? contextId;

  bool get isEmpty =>
      statuses.isEmpty &&
      !includeCompleted &&
      projectId == null &&
      contextId == null;

  /// Number of active filter dimensions — drives the AppBar badge.
  int get activeCount =>
      (statuses.isEmpty ? 0 : 1) +
      (includeCompleted ? 1 : 0) +
      (projectId != null ? 1 : 0) +
      (contextId != null ? 1 : 0);

  SearchFilter withStatuses(Set<ItemStatus> s) => SearchFilter(
        statuses: s,
        includeCompleted: includeCompleted,
        projectId: projectId,
        contextId: contextId,
      );

  SearchFilter toggleStatus(ItemStatus s) {
    final next = {...statuses};
    if (!next.remove(s)) next.add(s);
    return withStatuses(next);
  }

  SearchFilter withIncludeCompleted(bool v) => SearchFilter(
        statuses: statuses,
        includeCompleted: v,
        projectId: projectId,
        contextId: contextId,
      );

  SearchFilter withProject(String? id) => SearchFilter(
        statuses: statuses,
        includeCompleted: includeCompleted,
        projectId: id,
        contextId: contextId,
      );

  SearchFilter withContext(String? id) => SearchFilter(
        statuses: statuses,
        includeCompleted: includeCompleted,
        projectId: projectId,
        contextId: id,
      );

  @override
  bool operator ==(Object other) =>
      other is SearchFilter &&
      setEquals(other.statuses, statuses) &&
      other.includeCompleted == includeCompleted &&
      other.projectId == projectId &&
      other.contextId == contextId;

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(statuses),
        includeCompleted,
        projectId,
        contextId,
      );
}

/// Pure filter applied to raw search results. Riverpod-free so it is
/// unit-testable in isolation (mirrors `applyEngageFilter`).
///
/// Rules:
///  - `trashed` is always dropped (belt-and-braces; also excluded at the
///    repository query layer).
///  - `done` is surfaced *only* when [SearchFilter.includeCompleted] is
///    true — orthogonal to the status set.
///  - Any other status must be in the effective allow-set: the selected
///    [SearchFilter.statuses], or all active statuses when none selected.
///  - `projectId`/`contextId` constrain by exact match when non-null.
///  - Dimensions combine with AND.
List<Item> applySearchFilter(List<Item> items, SearchFilter f) {
  final allowed =
      f.statuses.isEmpty ? _activeSearchStatuses : f.statuses;

  return items.where((i) {
    if (i.status == ItemStatus.trashed) return false;

    if (i.status == ItemStatus.done) {
      if (!f.includeCompleted) return false;
    } else if (!allowed.contains(i.status)) {
      return false;
    }

    if (f.projectId != null && i.projectId != f.projectId) return false;
    if (f.contextId != null && i.contextId != f.contextId) return false;
    return true;
  }).toList();
}

class SearchFilterController extends StateNotifier<SearchFilter> {
  SearchFilterController() : super(const SearchFilter());

  void toggleStatus(ItemStatus s) => state = state.toggleStatus(s);
  void setIncludeCompleted(bool v) => state = state.withIncludeCompleted(v);
  void setProject(String? id) => state = state.withProject(id);
  void setContext(String? id) => state = state.withContext(id);
  void clear() => state = const SearchFilter();
}

/// The query string driving search, fed by the AppBar text field.
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Raw DB results, keyed solely on the query. Queries too short to be
/// meaningful (see [isSearchableQuery]) skip the database entirely. Trashed
/// rows are already excluded by the repo.
///
/// Watched (not one-shot) so a mutation made while the search screen is
/// still mounted — e.g. deleting, editing, or completing an item via the
/// detail screen pushed on top of a result — is reflected on return
/// instead of showing a stale cached list.
final searchResultsProvider =
    StreamProvider.autoDispose<List<Item>>((ref) {
  final q = ref.watch(searchQueryProvider).trim();
  if (!isSearchableQuery(q)) return Stream.value(const []);
  // A query also matches tag names (ADR 0010). Selected as a joined string so
  // the query re-subscribes only when the set of matching tags changes, not
  // on every tag-list emission.
  final tagIds = ref.watch(
    tagsProvider.select(
      (tags) => tagIdsMatchingQuery(tags.valueOrNull ?? const [], q).join(' '),
    ),
  );
  return ref.watch(itemRepositoryProvider).watchSearch(
        q,
        tagIds: tagIds.isEmpty ? const [] : tagIds.split(' '),
      );
});

/// Ids of [tags] whose name contains [query], folded like item search text
/// (case- and accent-insensitive).
List<String> tagIdsMatchingQuery(List<Tag> tags, String query) {
  final needle = normalizeForSearch(query.trim());
  if (needle.isEmpty) return const [];
  return [
    for (final t in tags)
      if (normalizeForSearch(t.name).contains(needle)) t.id,
  ];
}

/// Filter state. Deliberately **not** autoDispose: filters are sticky
/// across navigation within a session (the badge/clear affordance keeps
/// their presence obvious and resettable).
final searchFilterProvider =
    StateNotifierProvider<SearchFilterController, SearchFilter>(
        (ref) => SearchFilterController());

/// Read model the screen watches: raw results with the active filter
/// applied. Re-derives synchronously when *either* the results or the
/// filter change, so toggling a chip re-filters with no DB round-trip and
/// no need to retype.
final filteredSearchResultsProvider =
    Provider.autoDispose<AsyncValue<List<Item>>>((ref) {
  final results = ref.watch(searchResultsProvider);
  final filter = ref.watch(searchFilterProvider);
  return results.whenData((list) => applySearchFilter(list, filter));
});
