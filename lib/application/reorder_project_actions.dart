import '../core/clock.dart';
import '../data/repositories/item_repository.dart';

/// Persists a user-chosen manual order for the next-actions of a project.
///
/// Takes the action ids in their new visual order and assigns them dense
/// sequential `projectSortOrder` values (`0, 1, 2, …`). Reorder is a pure
/// presentation mutation — it changes no date/status/reminder state — so it
/// goes straight to the batched repository write and deliberately does NOT
/// route through `SaveItem` (which would reconcile reminders once per row).
final class ReorderProjectActions {
  ReorderProjectActions({required ItemRepository items, required Clock clock})
      : _items = items,
        _clock = clock;
  final ItemRepository _items;
  final Clock _clock;

  /// [orderedActionIds] is the full next-actions list of [projectId] in its
  /// new order. [projectId] is accepted for call-site clarity; the write
  /// keys on the unique item ids.
  Future<void> call(String projectId, List<String> orderedActionIds) async {
    if (orderedActionIds.isEmpty) return;
    final updates = <({String id, int order})>[
      for (var i = 0; i < orderedActionIds.length; i++)
        (id: orderedActionIds[i], order: i),
    ];
    await _items.reorderProjectActions(updates, _clock.now());
  }
}
