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
/// The completion and successor are persisted atomically before device
/// effects. [SaveItem] then reconciles the successor's reminders without
/// writing it a second time.
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
  }) : _items = items,
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
  ///
  /// [at] backdates a completion that was queued earlier (a Today widget
  /// tap, ADR 0009) so recurrence advances from the tap, not from the
  /// drain. It is clamped to now.
  Future<String?> call(String id, {DateTime? at}) async {
    final current = _clock.now();
    final now = at != null && at.isBefore(current) ? at : current;
    final completion = await _items.completeWithSuccessor(
      id,
      now,
      (current) =>
          nextRecurrenceOf(current, completedAt: now, newId: _ids.newId()),
    );
    if (completion == null) return null;
    await _scheduler.cancel(notificationIdFor(id, 1));
    await _scheduler.cancel(notificationIdFor(id, 2));
    await _scheduler.cancel(notificationIdFor(id, 3));
    final next = completion.successor;
    if (next == null) return null;
    await _saveItem.reconcileReminders(next);
    return next.id;
  }
}

/// Deferred reopen of a previously completed item — e.g. from the item-edit
/// screen. Restores the item to the list it was on before completion and
/// persists through [SaveItem] so any due/defer reminders are re-armed. Any
/// recurrence instance spawned at completion time is intentionally left alone:
/// it has had time to become real work.
final class ReopenItem {
  ReopenItem({required ItemRepository items, required SaveItem saveItem})
    : _items = items,
      _saveItem = saveItem;
  final ItemRepository _items;
  final SaveItem _saveItem;

  Future<void> call(String id) async {
    final current = await _items.getById(id);
    if (current == null) return;
    final restored = current.previousStatus ?? ItemStatus.nextAction;
    await _saveItem(
      current.copyWith(
        status: restored,
        clearCompletedAt: true,
        clearPreviousStatus: true,
      ),
    );
  }
}

/// Immediate reversal of [CompleteItem], for the post-completion "Undo"
/// snackbar. Unlike [ReopenItem] this also removes the recurrence instance
/// that completion just spawned, so a misclick leaves no trace.
final class UndoComplete {
  UndoComplete({
    required ItemRepository items,
    required NotificationScheduler scheduler,
    required SaveItem saveItem,
  }) : _items = items,
       _scheduler = scheduler,
       _saveItem = saveItem;
  final ItemRepository _items;
  final NotificationScheduler _scheduler;
  final SaveItem _saveItem;

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
    final current = await _items.getById(id);
    if (current == null) return;
    final restored = current.previousStatus ?? ItemStatus.nextAction;
    await _saveItem(
      current.copyWith(
        status: restored,
        clearCompletedAt: true,
        clearPreviousStatus: true,
      ),
    );
  }
}
