import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import 'save_item.dart';

/// Triages a surfaced item straight into Next Actions — the action offered
/// on a "Ready:" notification, where the deferred item has just become
/// available and the natural next move is to make it active work rather
/// than complete it.
///
/// Goes through [SaveItem] (not a raw status write) so the now-spent
/// "Ready:" reminder is reconciled away and the status/date invariant is
/// enforced. [deferUntil] is cleared: the defer has done its job (it fired),
/// and a Next Action must not carry a future defer.
final class MoveItemToNextActions {
  MoveItemToNextActions({
    required ItemRepository items,
    required SaveItem saveItem,
  })  : _items = items,
        _saveItem = saveItem;

  final ItemRepository _items;
  final SaveItem _saveItem;

  Future<void> call(String id) async {
    final item = await _items.getById(id);
    if (item == null) return;
    await _saveItem(
      item.copyWith(status: ItemStatus.nextAction, clearDeferUntil: true),
    );
  }
}
