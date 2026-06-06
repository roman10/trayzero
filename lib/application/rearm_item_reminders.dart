import '../core/clock.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';
import '../domain/item_invariants.dart';
import 'calendar_sync_service.dart';
import 'reconcile_item_reminders.dart';

/// On app launch, re-schedule the Due:/Soon:/Ready: reminder for every
/// active dated item.
///
/// `SaveItem` is the only thing that schedules item reminders, so an item
/// written by any other path keeps no alarm: a restored backup / Google
/// Tasks import (`BackupService.import` upserts in bulk), and any pending
/// alarm an OEM force-stop wiped (the documented final failure in
/// `LocalNotificationScheduler`). Re-arming here heals all of them, and
/// shares `reconcileItemReminders` with `SaveItem` so the rules can't drift.
///
/// Idempotent: deterministic `notificationIdFor` ids, so a re-run just
/// replaces the existing alarm, and the scheduler's past-time DROP guard
/// skips items whose moment already passed — stale history never spams.
///
/// Runs unawaited after launch, so the loop overlaps the first seconds of
/// use. It therefore re-reads each candidate by id immediately before
/// acting, instead of trusting the initial list snapshot: a concurrent
/// edit / complete / delete must win, and a row removed mid-loop must not
/// have its reminder revived. (The cheap "has a date?" pre-filter stays on
/// the snapshot — an item that gained a date in that window was already
/// scheduled by the `SaveItem` that dated it — so a huge restore stays
/// O(dated items), not O(all items) of database reads.)
///
/// Imported calendar events (`cal-` id prefix) are skipped: they came from
/// the user's real calendar, which already alerts, so Trayzero nagging too
/// would be wrong — the same boundary [CalendarSyncService.mirrorOut] draws.
final class RearmItemReminders {
  RearmItemReminders({
    required ItemRepository items,
    required NotificationScheduler scheduler,
    required Clock clock,
    required int leadTimeMinutes,
    required int deferSurfaceMinutes,
  })  : _items = items,
        _scheduler = scheduler,
        _clock = clock,
        _leadTimeMinutes = leadTimeMinutes,
        _deferSurfaceMinutes = deferSurfaceMinutes;

  final ItemRepository _items;
  final NotificationScheduler _scheduler;
  final Clock _clock;
  final int _leadTimeMinutes;
  final int _deferSurfaceMinutes;

  Future<void> call() async {
    final active = await _items.allActive(); // excludes done / trashed
    for (final snapshot in active) {
      // Snapshot pre-filter — cheap, on fields that don't matter if stale:
      // skip the majority carrying no reminder anchor (a huge restore stays
      // O(dated items)), and skip device-calendar imports (the real
      // calendar app alerts; their id prefix never changes).
      if (snapshot.dueAt == null && snapshot.deferUntil == null) continue;
      if (snapshot.id.startsWith(CalendarSyncService.importedIdPrefix)) {
        continue;
      }
      // Re-read current truth before acting (this overlaps the first
      // seconds of use): a concurrent edit / complete wins over the
      // snapshot, and a row deleted meanwhile yields null — never revive
      // its reminder.
      final item = await _items.getById(snapshot.id);
      if (item == null || item.completedAt != null) continue;
      await reconcileItemReminders(
        // Read-only normalise, exactly as SaveItem does before persisting,
        // so a stray next-action dueAt is dropped (no "Due:" we'd ignore).
        enforceStatusDateInvariant(item),
        scheduler: _scheduler,
        now: _clock.now(),
        leadTimeMinutes: _leadTimeMinutes,
        deferSurfaceMinutes: _deferSurfaceMinutes,
      );
    }
  }
}
