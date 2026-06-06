import 'package:drift/drift.dart';

import '../../core/search_text.dart';
import 'database.dart';

/// Recomputes `Items.searchText` for every row from its title/notes.
///
/// Called by the v6→v7 migration so existing users' items remain searchable
/// immediately — without it, pre-migration rows keep the empty-string column
/// default and become invisible to search until next edited. Idempotent, so
/// it is also safe to call defensively. Batched into one round trip.
Future<void> backfillSearchText(AppDatabase db) async {
  final rows = await db.select(db.items).get();
  if (rows.isEmpty) return;
  await db.batch((b) {
    for (final r in rows) {
      b.update(
        db.items,
        ItemsCompanion(searchText: Value(searchTextFor(r.title, r.notes))),
        where: (t) => t.id.equals(r.id),
      );
    }
  });
}
