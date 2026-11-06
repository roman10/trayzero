import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../../core/search_text.dart';
import '../../domain/entities/entities.dart';
import '../../domain/item_invariants.dart';
import '../../domain/today_focus.dart';
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

  /// Weekly Review includes deferred Next Actions as well as available ones.
  Stream<List<Item>> watchActiveForReview() {
    final query = _db.select(_db.items)
      ..where(
        (t) =>
            t.completedAt.isNull() &
            t.status.isNotIn([ItemStatus.done.name, ItemStatus.trashed.name]),
      )
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

  /// Re-evaluate against the current clock on every database emission.
  /// Application read models also refresh when time passes without a write.
  Stream<List<Item>> watchNextActions() =>
      watchByStatus(ItemStatus.nextAction).map((items) {
        final now = _clock.now();
        return items
            .where((i) => i.deferUntil == null || !i.deferUntil!.isAfter(now))
            .toList();
      });

  Stream<List<Item>> watchForProject(String projectId) {
    final query = _db.select(_db.items)
      ..where((t) => t.projectId.equals(projectId))
      ..where((t) => t.completedAt.isNull())
      ..where((t) => t.status.equals(ItemStatus.trashed.name).not())
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
      ..where((t) => t.status.equals(ItemStatus.trashed.name).not())
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

  /// Everything the user has captured and kept, done items included: not
  /// trashed and not a project's umbrella row. Used to judge whether there is
  /// enough data to be worth backing up (ADR 0013).
  Stream<int> watchKeptCount() {
    final query = _db.selectOnly(_db.items)
      ..addColumns([_db.items.id.count()])
      ..where(
        _db.items.status.isNotIn([
          ItemStatus.trashed.name,
          ItemStatus.project.name,
        ]),
      );
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
  ///
  /// Items carrying any of [tagIds] also match (ADR 0010: a query matches
  /// tag names; the caller resolves which tags those are).
  SimpleSelectStatement<$ItemsTable, ItemRow> _searchQuery(
    String query, {
    Iterable<String> tagIds = const [],
  }) {
    final pattern = '%${normalizeForSearch(query)}%';
    return _db.select(_db.items)
      ..where((t) {
        Expression<bool> matches = t.searchText.like(pattern);
        if (tagIds.isNotEmpty) {
          matches = matches |
              t.id.isInQuery(
                _db.selectOnly(_db.itemTags)
                  ..addColumns([_db.itemTags.itemId])
                  ..where(_db.itemTags.tagId.isIn(tagIds)),
              );
        }
        return matches & t.status.equals(ItemStatus.trashed.name).not();
      });
  }

  /// One-shot search. See [_searchQuery] for the surfaced/excluded rules.
  Future<List<Item>> search(
    String query, {
    Iterable<String> tagIds = const [],
  }) async {
    if (query.trim().isEmpty) return const [];
    final rows = await _searchQuery(query, tagIds: tagIds).get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// Reactive search: re-emits whenever any `items` row changes, so a
  /// delete/edit/complete made elsewhere (e.g. the item detail screen
  /// opened from a result) is reflected without re-querying. The reactive
  /// counterpart to [search], mirroring [watchInbox]/[watchByStatus].
  Stream<List<Item>> watchSearch(
    String query, {
    Iterable<String> tagIds = const [],
  }) {
    if (query.trim().isEmpty) return Stream.value(const []);
    return _searchQuery(query, tagIds: tagIds)
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// Inserts or saves an ordinary edit of [item].
  ///
  /// An existing row keeps its stored Today focus: callers save from an
  /// in-memory copy (an open edit screen, a list snapshot) that may predate a
  /// star tapped elsewhere, so `focusedAt` is written only by [setFocusedAt].
  /// The one exception is the focus invariant — moving the row to a status
  /// that cannot hold focus still clears it. A new row is inserted whole.
  Future<void> upsert(Item item) async {
    // Defensive backstop for the next-action / `dueAt` invariant. SaveItem
    // already normalises, but the recurrence rollover in CompleteItem writes
    // here directly without going through it, so the rule must also hold at
    // this — the true — persistence chokepoint.
    final row = enforceItemInvariants(item);
    final companion = row.toCompanion();
    await _db.into(_db.items).insert(
      companion,
      onConflict: DoUpdate(
        (_) => companion.copyWith(
          focusedAt: canHoldFocus(row.status)
              ? const Value.absent()
              : const Value(null),
        ),
      ),
    );
  }

  /// Bulk upsert in a single batched transaction, writing every column
  /// including Today focus: a restore replaces rows wholesale. Restoring a
  /// large backup (e.g. thousands of imported Google tasks) one row at a time
  /// is far too slow; [batch] collapses it into one round trip.
  Future<void> upsertAll(List<Item> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.items,
        rows
            .map((r) => enforceItemInvariants(r).toCompanion())
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
  /// also bypasses [enforceItemInvariants]. That is safe *only* because
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

  /// Sets or clears Today focus (ADR 0007) for several Items in one batch.
  /// Like [reorderProjectActions] this writes a single non-invariant column
  /// and deliberately does not stamp `updatedAt`: focus is daily planning
  /// state, not an edit, so it neither reorders lists nor counts as Project
  /// activity. A non-null stamp only lands on statuses that can hold focus,
  /// so a stale tap on an Item filed to Someday meanwhile is a no-op.
  Future<void> setFocusedAt(Map<String, DateTime?> updates) async {
    if (updates.isEmpty) return;
    final focusable = ItemStatus.values
        .where(canHoldFocus)
        .map((s) => s.name)
        .toList();
    await _db.batch((b) {
      for (final MapEntry(key: id, value: at) in updates.entries) {
        b.update(
          _db.items,
          ItemsCompanion(focusedAt: Value(at)),
          where: (t) => at == null
              ? t.id.equals(id)
              : t.id.equals(id) & t.status.isIn(focusable),
        );
      }
    });
  }

  /// Items carrying a Today focus stamp (ADR 0007): open ones of any day, so
  /// carry-over stays visible, plus those completed since [since] for the
  /// "done today" count. Older done rows keep their stamp for Undo but are
  /// excluded so the stream does not grow with history.
  Stream<List<Item>> watchFocused({required DateTime since}) {
    final focusable = ItemStatus.values
        .where(canHoldFocus)
        .map((s) => s.name)
        .toList();
    final query = _db.select(_db.items)
      ..where(
        (t) =>
            t.focusedAt.isNotNull() &
            t.status.isIn(focusable) &
            (t.completedAt.isNull() | t.completedAt.isBiggerOrEqualValue(since)),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.focusedAt),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// Latest `updatedAt` per Project across its non-trashed Items, open or
  /// done. Creation and completion both stamp `updatedAt`, so this is the
  /// Project's last action activity for stalled-project detection.
  Stream<Map<String, DateTime>> watchProjectActivity() {
    final latest = _db.items.updatedAt.max();
    final query = _db.selectOnly(_db.items)
      ..addColumns([_db.items.projectId, latest])
      ..where(
        _db.items.projectId.isNotNull() &
            _db.items.status.equals(ItemStatus.trashed.name).not(),
      )
      ..groupBy([_db.items.projectId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          if (row.read(latest) != null)
            row.read(_db.items.projectId)!: row.read(latest)!,
      },
    );
  }

  /// Deletes the row. Its tag links cascade; deleting them explicitly too
  /// lets Drift streams over `item_tags` notice (ADR 0010).
  Future<void> delete(String id) => _db.transaction(() async {
    await (_db.delete(_db.itemTags)..where((t) => t.itemId.equals(id))).go();
    await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
  });

  /// Whether any Item (in any status) still points at [projectId] or
  /// [contextId]. Lets an import Undo keep a Project or Context the user
  /// has started using meanwhile.
  Future<bool> anyReferencing({String? projectId, String? contextId}) async {
    final query = _db.selectOnly(_db.items)
      ..addColumns([_db.items.id])
      ..where(
        projectId != null
            ? _db.items.projectId.equals(projectId)
            : _db.items.contextId.equals(contextId ?? ''),
      )
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  /// Bulk delete in a single batched transaction. Triaging a large imported
  /// backlog (e.g. thousands of Google tasks) one row at a time is far too
  /// slow; [batch] collapses it into one round trip — the delete counterpart
  /// to [upsertAll].
  Future<void> deleteAll(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.batch((b) {
      b.deleteWhere(_db.itemTags, (t) => t.itemId.isIn(ids));
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

  /// Completion and its optional successor are one durable change. The
  /// callback supplies recurrence policy from the application layer;
  /// device effects run only after this transaction commits.
  Future<({Item original, Item? successor})?> completeWithSuccessor(
    String id,
    DateTime now,
    Item? Function(Item current) successorOf,
  ) => _db.transaction(() async {
    final current = await getById(id);
    if (current == null || current.status == ItemStatus.done) return null;
    final successor = successorOf(current);
    await markCompleted(id, now);
    if (successor != null) {
      await upsert(successor);
      // The next occurrence carries the same tags (ADR 0010).
      await _db.customStatement(
        'INSERT OR IGNORE INTO item_tags (item_id, tag_id) '
        'SELECT ?, tag_id FROM item_tags WHERE item_id = ?',
        [successor.id, id],
      );
      _db.notifyUpdates({TableUpdate.onTable(_db.itemTags)});
    }
    return (original: current, successor: successor);
  });

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

  /// Ids of soft-deleted rows awaiting `PurgeTrash`.
  Future<List<String>> trashedIds() async {
    final rows = await (_db.select(_db.items)
          ..where((t) => t.status.equals(ItemStatus.trashed.name)))
        .get();
    return rows.map((r) => r.id).toList();
  }

  Future<List<Item>> allActive() async {
    final rows = await (_db.select(_db.items)
          ..where((t) =>
              t.status.equals(ItemStatus.trashed.name).not() &
              t.status.equals(ItemStatus.done.name).not()))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// Rows that should survive an export/import round trip. Completed items
  /// are user history, so they belong in backups; trashed items remain
  /// excluded because every user-facing surface treats trash as discarded.
  Future<List<Item>> allRestorable() async {
    final rows = await (_db.select(_db.items)
          ..where((t) => t.status.equals(ItemStatus.trashed.name).not()))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }
}
