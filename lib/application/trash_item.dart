import '../core/clock.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';

/// Soft-deletes an item: moves it to [ItemStatus.trashed] and cancels its
/// reminders, but keeps the row and its attachment files so the delete can be
/// undone. The row is hard-deleted later by `PurgeTrash`.
///
/// Returns the item exactly as it was before trashing (the "undo snapshot"),
/// or `null` when there was nothing to trash (unknown id / already trashed).
/// Callers hand the snapshot to `RestoreTrashedItem`; it is kept in memory
/// rather than in a column so no schema migration is needed.
final class TrashItem {
  TrashItem({
    required ItemRepository items,
    required NotificationScheduler scheduler,
    required Clock clock,
  })  : _items = items,
        _scheduler = scheduler,
        _clock = clock;

  final ItemRepository _items;
  final NotificationScheduler _scheduler;
  final Clock _clock;

  Future<Item?> call(String id) async {
    final current = await _items.getById(id);
    if (current == null || current.status == ItemStatus.trashed) return null;
    await _items.upsert(
      current.copyWith(status: ItemStatus.trashed, updatedAt: _clock.now()),
    );
    for (final salt in [1, 2, 3]) {
      await _scheduler.cancel(notificationIdFor(id, salt));
    }
    return current;
  }
}
