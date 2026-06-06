import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import 'database.dart';

/// Retires hard `dueAt` dates from next actions (GTD Option A).
///
/// A next action lives off the calendar — its only date anchor is
/// `deferUntil` (a tickler). Pre-v8 the edit screen let one accrue a `dueAt`
/// that surfaced nowhere (the Do-screen hard-landscape band is calendar-only)
/// and silently aged. This one-time v7→v8 fix preserves the user's intent
/// rather than discarding it: the date becomes the item's defer anchor when it
/// has none, otherwise the stray `dueAt` is simply cleared. Moving it to
/// `deferUntil` also keeps any recurrence series alive — recurrence advances
/// `dueAt ?? deferUntil`, so the anchor survives the move.
///
/// Idempotent (a clean run finds no `nextAction` rows with a `dueAt`) and
/// batched into one round trip, mirroring [backfillSearchText].
Future<void> migrateNextActionDueDates(AppDatabase db) async {
  final rows = await db.select(db.items).get();
  final stale = rows.where(
    (r) => r.status == ItemStatus.nextAction && r.dueAt != null,
  );
  if (stale.isEmpty) return;
  await db.batch((b) {
    for (final r in stale) {
      b.update(
        db.items,
        ItemsCompanion(
          deferUntil: Value(r.deferUntil ?? r.dueAt),
          dueAt: const Value(null),
        ),
        where: (t) => t.id.equals(r.id),
      );
    }
  });
}
