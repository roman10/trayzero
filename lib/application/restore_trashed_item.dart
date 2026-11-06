import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import 'save_item.dart';

/// Undo for `TrashItem`: puts [snapshot] (the item as it was before it was
/// trashed) back and re-arms its reminders through [SaveItem].
///
/// Returns false, touching nothing, when the row is no longer trashed — it
/// was already restored, or purged — so a late or repeated Undo is harmless.
final class RestoreTrashedItem {
  RestoreTrashedItem({
    required ItemRepository items,
    required SaveItem saveItem,
  })  : _items = items,
        _saveItem = saveItem;

  final ItemRepository _items;
  final SaveItem _saveItem;

  Future<bool> call(Item snapshot) async {
    final row = await _items.getById(snapshot.id);
    if (row == null || row.status != ItemStatus.trashed) return false;
    await _saveItem(
      snapshot.copyWith(
        // Calendar sync may have removed the mirrored event while trashed;
        // keep its current bookkeeping rather than the snapshot's.
        calendarEventId: row.calendarEventId,
        clearCalendarEventId: row.calendarEventId == null,
      ),
    );
    // Trashing dropped Today focus (it cannot be held in trash); put it back.
    if (snapshot.focusedAt != null) {
      await _items.setFocusedAt({snapshot.id: snapshot.focusedAt});
    }
    return true;
  }
}
