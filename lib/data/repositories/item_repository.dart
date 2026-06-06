import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../../core/search_text.dart';
import '../../domain/entities/entities.dart';
import '../../domain/item_invariants.dart';
import '../db/database.dart';
import '../mappers.dart';

class ItemRepository {
  ItemRepository(this._db, this._clock);
  final AppDatabase _db;
  final Clock _clock;

  Stream<List<Item>> watchInbox() {
    final query = _db.select(_db.items)
      ..where((t) => t.status.equals(ItemStatus.inbox.name))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Stream<List<Item>> watchByStatus(ItemStatus status, {DateTime? now}) {
    final query = _db.select(_db.items)
      ..where((t) => t.status.equals(status.name))
      ..where((t) => t.completedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.dueAt),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().map((rows) {
      final mapped = rows.map((r) => r.toEntity()).toList();
      if (now != null) {
        return mapped.where((i) {
          if (i.deferUntil == null) return true;
          return !i.deferUntil!.isAfter(now);
        }).toList();
      }
      return mapped;
    });
  }

  Stream<List<Item>> watchNextActions() =>
      watchByStatus(ItemStatus.nextAction, now: _clock.now());

  Stream<List<Item>> watchForProject(String projectId) {
    final query = _db.select(_db.items)
      ..where((t) => t.projectId.equals(projectId))
      ..where((t) => t.completedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.projectSortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// Items finished while assigned to [projectId], most recently completed
  /// first. The completion history counterpart to [watchForProject] (which
  /// only ever surfaces *open* items): the project detail screen renders this
  /// as a separate, collapsed "Completed" section so progress is visible
  /// without the active lists carrying done rows.
  Stream<List<Item>> watchCompletedForProject(String projectId) {
    final query = _db.select(_db.items)
      ..where((t) => t.projectId.equals(projectId))
      ..where((t) => t.completedAt.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// The GTD hard landscape: items explicitly committed to a day
  /// (`status == calendar`). `dueAt` is a pure attribute here — it orders the
  /// list and is split into past-due vs upcoming downstream, but it is never
  /// what makes an item a calendar item. A dated next-action or someday item
  /// stays on its own list and does NOT surface here. The `dueAt IS NOT NULL`
  /// clause is defensive: a calendar item should always have a date, and
  /// keeping it guarantees the `dueAt!` reads in the calendar providers can
  /// never throw.
  Stream<List<Item>> watchCalendar() {
    final query = _db.select(_db.items)
      ..where((t) =>
          t.status.equals(ItemStatus.calendar.name) &
          t.completedAt.isNull() &
          t.dueAt.isNotNull())
      ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Stream<int> watchInboxCount() {
    final query = _db.selectOnly(_db.items)
      ..addColumns([_db.items.id.count()])
      ..where(_db.items.status.equals(ItemStatus.inbox.name));
    return query
        .map((row) => row.read(_db.items.id.count()) ?? 0)
        .watchSingle();
  }

  Future<Item?> getById(String id) async {
    final row = await (_db.select(_db.items)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  /// Builds the search select. Matches against the pre-normalised
  /// [Items.searchText] (folded title+notes) so search is accent- and
  /// case-insensitive across scripts; the query is folded through the same
  /// [normalizeForSearch] so the two sides can never diverge. Trashed items
  /// are never surfaced — a hard invariant enforced here in the query (same
  /// idiom as [allActive]/[watchCalendar]), not a tunable filter. `done`
  /// rows *are* returned so callers can opt them in via their own filtering.
  SimpleSelectStatement<$ItemsTable, ItemRow> _searchQuery(String query) {
    final pattern = '%${normalizeForSearch(query)}%';
    return _db.select(_db.items)
      ..where((t) =>
          t.searchText.like(pattern) &
          t.status.equals(ItemStatus.trashed.name).not());
  }

  /// One-shot search. See [_searchQuery] for the surfaced/excluded rules.
  Future<List<Item>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final rows = await _searchQuery(query).get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// Reactive search: re-emits whenever any `items` row changes, so a
  /// delete/edit/complete made elsewhere (e.g. the item detail screen
  /// opened from a result) is reflected without re-querying. The reactive
  /// counterpart to [search], mirroring [watchInbox]/[watchByStatus].
  Stream<List<Item>> watchSearch(String query) {
    if (query.trim().isEmpty) return Stream.value(const []);
    return _searchQuery(query)
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<void> upsert(Item item) async {
    // Defensive backstop for the next-action / `dueAt` invariant. SaveItem
    // already normalises, but the recurrence rollover in CompleteItem writes
    // here directly without going through it, so the rule must also hold at
    // this — the true — persistence chokepoint.
    await _db
        .into(_db.items)
        .insertOnConflictUpdate(enforceStatusDateInvariant(item).toCompanion());
  }

  /// Bulk upsert in a single batched transaction. Restoring a large backup
  /// (e.g. thousands of imported Google tasks) one row at a time is far too
  /// slow; [batch] collapses it into one round trip.
  Future<void> upsertAll(List<Item> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.items,
        rows
            .map((r) => enforceStatusDateInvariant(r).toCompanion())
            .toList(),
      );
    });
  }

  /// Rewrites the manual within-project order for the given items in one
  /// batched round trip. Each entry sets `projectSortOrder` (and stamps
  /// `updatedAt`) for one row.
  ///
  /// This deliberately writes only those two columns via a targeted
  /// `b.update` and does NOT route through [upsert]/`toCompanion()`, so it
  /// also bypasses [enforceStatusDateInvariant]. That is safe *only* because
  /// it touches no invariant-bearing column (status / dueAt / deferUntil).
  /// Do not widen this method to other columns without going through
  /// [upsert] instead.
  Future<void> reorderProjectActions(
    List<({String id, int order})> updates,
    DateTime now,
  ) async {
    if (updates.isEmpty) return;
    await _db.batch((b) {
      for (final u in updates) {
        b.update(
          _db.items,
          ItemsCompanion(
            projectSortOrder: Value(u.order),
            updatedAt: Value(now),
          ),
          where: (t) => t.id.equals(u.id),
        );
      }
    });
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
  }

  /// Bulk delete in a single batched transaction. Triaging a large imported
  /// backlog (e.g. thousands of Google tasks) one row at a time is far too
  /// slow; [batch] collapses it into one round trip — the delete counterpart
  /// to [upsertAll].
  Future<void> deleteAll(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.batch((b) {
      b.deleteWhere(_db.items, (t) => t.id.isIn(ids));
    });
  }

  /// Marks the row as done. Recurrence rollover is the responsibility of
  /// the `CompleteItem` use case in `lib/application/` — the repo only owns
  /// the persistent write.
  Future<void> markCompleted(String id, DateTime now) async {
    final current = await getById(id);
    // Don't clobber a captured prior status if the row is somehow already
    // done — only remember the status we're completing *from*.
    final prior = (current != null && current.status != ItemStatus.done)
        ? current.status
        : null;
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: const Value(ItemStatus.done),
        completedAt: Value(now),
        previousStatus: Value(prior),
        updatedAt: Value(now),
      ),
    );
  }

  /// Reverses a completion: restores the item to whatever list it was on
  /// before (captured in [Item.previousStatus]), falling back to
  /// `nextAction` for rows completed before this was tracked.
  Future<void> reopen(String id, DateTime now) async {
    final current = await getById(id);
    final restored = current?.previousStatus ?? ItemStatus.nextAction;
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: Value(restored),
        completedAt: const Value(null),
        previousStatus: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  /// Items finished on or after [since], most recently completed first.
  /// Used by the Review screen's "Completed this week" section.
  Stream<List<Item>> watchCompletedSince(DateTime since) {
    final query = _db.select(_db.items)
      ..where((t) => t.status.equals(ItemStatus.done.name))
      ..where((t) => t.completedAt.isBiggerOrEqualValue(since))
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// Items that currently hold a mirrored calendar event id, regardless of
  /// status. Calendar sync uses this to find events to delete when their
  /// item was completed, trashed, or had its due date cleared.
  Future<List<Item>> withCalendarEventId() async {
    final rows = await (_db.select(_db.items)
          ..where((t) => t.calendarEventId.isNotNull()))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// Stores (or clears, when [eventId] is null) the mirrored calendar event
  /// id for [id]. A sync-bookkeeping write — deliberately does not touch
  /// `updatedAt` so it is not mistaken for a user edit.
  Future<void> setCalendarEventId(String id, String? eventId) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id)))
        .write(ItemsCompanion(calendarEventId: Value(eventId)));
  }

  Future<List<Item>> allActive() async {
    final rows = await (_db.select(_db.items)
          ..where((t) =>
              t.status.equals(ItemStatus.trashed.name).not() &
              t.status.equals(ItemStatus.done.name).not()))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }
}
