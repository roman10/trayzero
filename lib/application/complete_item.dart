import '../core/clock.dart';
import '../core/id_generator.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/recurrence/recurrence_policy.dart';
import 'save_item.dart';

/// Marks an item complete, cancels its outstanding reminders, and — when
/// the completed item is recurring — produces a fresh instance with the
/// dates advanced by the recurrence interval.
///
/// The spawned instance is persisted through [SaveItem], not a raw upsert,
/// so its Due:/Soon:/Ready: reminders are scheduled the same way every other
/// dated item's are — otherwise a recurring task notified only on its first
/// occurrence and went silent forever after.
///
/// This is the only place "recurrence rollover" should live; everywhere
/// else, just call this use case.
final class CompleteItem {
  CompleteItem({
    required ItemRepository items,
    required NotificationScheduler scheduler,
    required Clock clock,
    required IdGenerator ids,
    required SaveItem saveItem,
  })  : _items = items,
        _scheduler = scheduler,
        _clock = clock,
        _ids = ids,
        _saveItem = saveItem;

  final ItemRepository _items;
  final NotificationScheduler _scheduler;
  final Clock _clock;
  final IdGenerator _ids;
  final SaveItem _saveItem;

  /// Returns the id of the freshly spawned recurrence instance, or `null`
  /// when the completed item was not recurring. Callers that offer an
  /// "undo" need this id so the spawned instance can be removed too.
  Future<String?> call(String id) async {
    final now = _clock.now();
    final existing = await _items.getById(id);
    // Idempotency guard: a second completion on an already-done row must
    // not pass through to nextRecurrenceOf — that function only checks
    // the rule + count/until caps, so a replayed Done would read the
    // still-not-incremented doneCount and spawn a duplicate successor.
    // Reachable today via the notification journal: an item's "Soon:"
    // and "Due:" reminders both carry Done; if both fire while the app
    // is dead and the user taps each, the drain replays two Dones for
    // the same itemId in sequence.
    if (existing == null || existing.status == ItemStatus.done) return null;
    await _items.markCompleted(id, now);
    await _scheduler.cancel(notificationIdFor(id, 1));
    await _scheduler.cancel(notificationIdFor(id, 2));
    await _scheduler.cancel(notificationIdFor(id, 3));
    final next =
        nextRecurrenceOf(existing, completedAt: now, newId: _ids.newId());
    if (next == null) return null;
    // Through SaveItem (not _items.upsert) so the new occurrence's reminders
    // are scheduled. SaveItem re-stamps updatedAt to now; harmless — items
    // order by createdAt, which it leaves as the spawned completedAt.
    await _saveItem(next);
    return next.id;
  }
}

/// Deferred reopen of a previously completed item — e.g. from the item-edit
/// screen. Restores the item to the list it was on before completion (see
/// [ItemRepository.reopen]). Any recurrence instance spawned at completion
/// time is intentionally left alone: it has had time to become real work.
final class ReopenItem {
  ReopenItem({required ItemRepository items, required Clock clock})
      : _items = items,
        _clock = clock;
  final ItemRepository _items;
  final Clock _clock;

  Future<void> call(String id) => _items.reopen(id, _clock.now());
}

/// Immediate reversal of [CompleteItem], for the post-completion "Undo"
/// snackbar. Unlike [ReopenItem] this also removes the recurrence instance
/// that completion just spawned, so a misclick leaves no trace.
final class UndoComplete {
  UndoComplete({
    required ItemRepository items,
    required Clock clock,
    required NotificationScheduler scheduler,
  })  : _items = items,
        _clock = clock,
        _scheduler = scheduler;
  final ItemRepository _items;
  final Clock _clock;
  final NotificationScheduler _scheduler;

  Future<void> call(String id, {String? spawnedRecurrenceId}) async {
    if (spawnedRecurrenceId != null) {
      // The spawned instance was saved via SaveItem, so it may carry
      // Due:/Soon:/Ready: reminders. Cancel them before deleting the row, or
      // they'd fire for a record that no longer exists (mirrors DeleteItem).
      await _scheduler.cancel(notificationIdFor(spawnedRecurrenceId, 1));
      await _scheduler.cancel(notificationIdFor(spawnedRecurrenceId, 2));
      await _scheduler.cancel(notificationIdFor(spawnedRecurrenceId, 3));
      await _items.delete(spawnedRecurrenceId);
    }
    await _items.reopen(id, _clock.now());
  }
}
