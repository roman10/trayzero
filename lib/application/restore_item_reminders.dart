import '../core/clock.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/item_invariants.dart';
import 'calendar_sync_service.dart';
import 'reconcile_item_reminders.dart';

/// Reconciles every restored Item, including completed/undated Items that
/// must cancel alarms previously scheduled by an overwritten local version.
class RestoreItemReminders {
  RestoreItemReminders({
    required this.items,
    required this.scheduler,
    required this.clock,
    required this.leadTimeMinutes,
    required this.deferSurfaceMinutes,
  });
  final ItemRepository items;
  final NotificationScheduler scheduler;
  final Clock clock;
  final int leadTimeMinutes;
  final int deferSurfaceMinutes;

  Future<void> call(List<String> ids) async {
    for (final id in ids.toSet()) {
      final item = await items.getById(id);
      if (item == null ||
          item.status == ItemStatus.done ||
          item.status == ItemStatus.trashed ||
          item.completedAt != null ||
          id.startsWith(CalendarSyncService.importedIdPrefix)) {
        for (final salt in [1, 2, 3]) {
          await scheduler.cancel(notificationIdFor(id, salt));
        }
        continue;
      }
      await reconcileItemReminders(
        enforceStatusDateInvariant(item),
        scheduler: scheduler,
        now: clock.now(),
        leadTimeMinutes: leadTimeMinutes,
        deferSurfaceMinutes: deferSurfaceMinutes,
      );
    }
  }
}
