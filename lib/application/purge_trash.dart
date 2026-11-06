import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import 'delete_item.dart';

/// Permanently deletes trashed items (row, attachment files, reminders).
///
/// With [ids], purges only those that are still trashed — an item the user
/// restored via Undo meanwhile is left alone. Without, sweeps every trashed
/// row; run at launch to finish deletes interrupted by the app being killed
/// inside the Undo window.
final class PurgeTrash {
  PurgeTrash({required ItemRepository items, required DeleteItem deleteItem})
      : _items = items,
        _deleteItem = deleteItem;

  final ItemRepository _items;
  final DeleteItem _deleteItem;

  Future<void> call({Iterable<String>? ids}) async {
    final targets = ids == null
        ? await _items.trashedIds()
        : [
            for (final id in ids)
              if ((await _items.getById(id))?.status == ItemStatus.trashed) id,
          ];
    for (final id in targets) {
      await _deleteItem(id);
    }
  }
}
