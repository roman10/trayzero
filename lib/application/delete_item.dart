import '../core/notification_scheduler.dart';
import '../data/repositories/attachment_repository.dart';
import '../data/repositories/item_repository.dart';

/// Deletes an item, its attachment files, and any pending reminders.
///
/// Splitting this from the repo lets the orchestration cover three side
/// effects in one place: the row, the files on disk, and the scheduled
/// local notifications.
final class DeleteItem {
  DeleteItem({
    required ItemRepository items,
    required AttachmentRepository attachments,
    required NotificationScheduler scheduler,
  })  : _items = items,
        _attachments = attachments,
        _scheduler = scheduler;

  final ItemRepository _items;
  final AttachmentRepository _attachments;
  final NotificationScheduler _scheduler;

  Future<void> call(String id) async {
    final files = await _attachments.getForItem(id);
    for (final a in files) {
      await _attachments.delete(a);
    }
    await _items.delete(id);
    await _scheduler.cancel(notificationIdFor(id, 1));
    await _scheduler.cancel(notificationIdFor(id, 2));
    await _scheduler.cancel(notificationIdFor(id, 3));
  }
}
