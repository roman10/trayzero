import '../core/notification_scheduler.dart';
import '../data/repositories/attachment_repository.dart';
import '../data/repositories/item_repository.dart';

/// Bulk variant of [DeleteItem]: removes many items, their attachment files,
/// and any pending reminders in one pass.
///
/// Keeps the same three side-effects [DeleteItem] covers (the row, the files
/// on disk, the scheduled local notifications) so the inbox's batch-delete
/// path never leaks them — while collapsing the row deletes into a single
/// batched [ItemRepository.deleteAll].
final class BatchDeleteItems {
  BatchDeleteItems({
    required ItemRepository items,
    required AttachmentRepository attachments,
    required NotificationScheduler scheduler,
  })  : _items = items,
        _attachments = attachments,
        _scheduler = scheduler;

  final ItemRepository _items;
  final AttachmentRepository _attachments;
  final NotificationScheduler _scheduler;

  Future<void> call(List<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      final files = await _attachments.getForItem(id);
      for (final a in files) {
        await _attachments.delete(a);
      }
      await _scheduler.cancel(notificationIdFor(id, 1));
      await _scheduler.cancel(notificationIdFor(id, 2));
      await _scheduler.cancel(notificationIdFor(id, 3));
    }
    await _items.deleteAll(ids);
  }
}
