import '../core/clock.dart';
import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';
import '../data/repositories/item_repository.dart';

/// Cancels per-item "Soon:" / "Ready:" notifications that have outlived
/// their meaning — the early-warning banner sitting next to (or instead of)
/// the live "Due:" one for the same item.
///
/// Android already retires these declaratively via
/// `AndroidNotificationDetails.timeoutAfter` (set in
/// [reconcileItemReminders] when Soon / Ready is scheduled), so this sweep
/// is the iOS path: iOS has no `timeoutAfter` equivalent and `UNUser-
/// NotificationCenter` won't auto-clear a delivered notification at a later
/// time. On Android the sweep is harmless overlap that also catches edges
/// the OS timeout can't (e.g. the user edited `dueAt` out from under a
/// notification that's still in the tray).
///
/// Runs on app launch and on every `AppLifecycleListener.onResume` —
/// foreground is when the user is about to look at the tray anyway, so
/// "best-effort eventually" is fine for the iOS path. Unawaited from
/// `main()` so it never blocks UI; failures are swallowed by the scheduler
/// impl and logged.
///
/// What counts as stale:
/// - The item was deleted or completed (defensive; the lifecycle paths
///   already cancel by id, but a sweep is cheap insurance).
/// - Kind is `soon` and the item lost its `dueAt`, or its `dueAt` is now
///   in the past (Due has already fired).
/// - Kind is `ready` and the item now has a `dueAt` that's already in the
///   past (Due took over; the "newly available" framing is irrelevant).
///
/// Standing-reminder kinds (`weeklyReview`, `backup`) are item-less and
/// never stale by this definition — they're skipped.
final class SweepStaleItemNotifications {
  SweepStaleItemNotifications({
    required ItemRepository items,
    required NotificationScheduler scheduler,
    required Clock clock,
  })  : _items = items,
        _scheduler = scheduler,
        _clock = clock;

  final ItemRepository _items;
  final NotificationScheduler _scheduler;
  final Clock _clock;

  Future<void> call() async {
    final active = await _scheduler.getActiveNotifications();
    if (active.isEmpty) return;
    final now = _clock.now();
    for (final n in active) {
      final payload = NotificationPayload.tryDecode(n.payload);
      if (payload == null) continue;
      // Only item-scoped early-warning kinds are candidates. Due is
      // never stale (it IS the surviving banner). Standing kinds have
      // no item to consult.
      final isCandidate = payload.kind == NotificationKind.soon ||
          payload.kind == NotificationKind.ready;
      if (!isCandidate) continue;
      final itemId = payload.itemId;
      if (itemId == null) continue;
      final item = await _items.getById(itemId);
      if (item == null || item.completedAt != null) {
        await _scheduler.cancel(n.id);
        continue;
      }
      final isStale = switch (payload.kind) {
        NotificationKind.soon =>
          item.dueAt == null || !item.dueAt!.isAfter(now),
        NotificationKind.ready =>
          item.dueAt != null && !item.dueAt!.isAfter(now),
        _ => false,
      };
      if (isStale) await _scheduler.cancel(n.id);
    }
  }
}
