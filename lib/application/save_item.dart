import '../core/clock.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/item_invariants.dart';
import 'reconcile_item_reminders.dart';

/// Persists an edited item and reconciles its due/defer reminders.
///
/// Schedules a notification when `dueAt` / `deferUntil` is set, cancels the
/// matching reminder when those fields are cleared. This is the single
/// authority for "item edits → scheduled reminders"; the reminder logic
/// itself lives in [reconcileItemReminders] so the launch re-arm
/// (`RearmItemReminders`) applies exactly the same rules.
final class SaveItem {
  SaveItem({
    required ItemRepository items,
    required NotificationScheduler scheduler,
    required Clock clock,
    int leadTimeMinutes = 0,
    int deferSurfaceMinutes = 540,
  })  : _items = items,
        _scheduler = scheduler,
        _clock = clock,
        _leadTimeMinutes = leadTimeMinutes,
        _deferSurfaceMinutes = deferSurfaceMinutes;

  final ItemRepository _items;
  final NotificationScheduler _scheduler;
  final Clock _clock;

  /// Minutes before `dueAt` to fire an extra "Soon:" tickler. 0 = off.
  final int _leadTimeMinutes;

  /// Minutes-since-midnight at which a no-time (start-of-day) `deferUntil`
  /// fires its "Ready:" reminder (see `deferReminderAt`).
  final int _deferSurfaceMinutes;

  Future<Item> call(Item updated) async {
    // Normalise before stamping so the reminder reconciliation below sees the
    // canonical item: a next action's `dueAt` is dropped here, which makes the
    // `else { cancel(dueId) }` branch correctly tear down any stale "Due:"
    // reminder instead of scheduling one we'd never honour.
    final stamped = enforceStatusDateInvariant(updated)
        .copyWith(updatedAt: _clock.now());
    await _items.upsert(stamped);
    await reconcileItemReminders(
      stamped,
      scheduler: _scheduler,
      now: _clock.now(),
      leadTimeMinutes: _leadTimeMinutes,
      deferSurfaceMinutes: _deferSurfaceMinutes,
    );
    return stamped;
  }
}
