import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../../domain/tags.dart';
import '../db/database.dart';
import '../mappers.dart';

/// Tags and their Item links (ADR 0010). Link writes are targeted and never
/// stamp `items.updatedAt`: labelling is organization, not an edit.
class TagRepository {
  TagRepository(this._db);
  final AppDatabase _db;

  Stream<List<Tag>> watchAll() => _db
      .select(_db.tags)
      .watch()
      .map((rows) => sortTags(rows.map((r) => r.toEntity())));

  Future<List<Tag>> all() async =>
      sortTags((await _db.select(_db.tags).get()).map((r) => r.toEntity()));

  Future<Tag?> getById(String id) async {
    final row = await (_db.select(
      _db.tags,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toEntity();
  }

  /// Inserts [tag], or updates its name and person flag. [createdAt] is kept
  /// on an existing row.
  Future<void> upsert(Tag tag, {required DateTime createdAt}) =>
      upsertAll([tag], createdAt: createdAt);

  Future<void> upsertAll(List<Tag> tags, {required DateTime createdAt}) async {
    if (tags.isEmpty) return;
    await _db.batch((b) {
      for (final t in tags) {
        b.insert(
          _db.tags,
          TagsCompanion.insert(
            id: t.id,
            name: t.name,
            isPerson: Value(t.isPerson),
            createdAt: createdAt,
          ),
          onConflict: DoUpdate(
            (_) =>
                TagsCompanion(name: Value(t.name), isPerson: Value(t.isPerson)),
          ),
        );
      }
    });
  }

  /// Deletes the tag; its links cascade. The explicit link delete lets Drift
  /// streams over `item_tags` notice.
  Future<void> delete(String id) => _db.transaction(() async {
    await (_db.delete(_db.itemTags)..where((t) => t.tagId.equals(id))).go();
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  });

  /// Every Item's tag ids, keyed by Item id. One app-wide stream that cards
  /// read, like attachment summaries.
  Stream<Map<String, List<String>>> watchItemTagIds() =>
      _db.select(_db.itemTags).watch().map(_group);

  Future<Map<String, List<String>>> allItemTagIds() async =>
      _group(await _db.select(_db.itemTags).get());

  static Map<String, List<String>> _group(List<ItemTagRow> rows) {
    final out = <String, List<String>>{};
    for (final r in rows) {
      (out[r.itemId] ??= []).add(r.tagId);
    }
    return out;
  }

  Future<List<String>> tagIdsFor(String itemId) async {
    final rows = await (_db.select(
      _db.itemTags,
    )..where((t) => t.itemId.equals(itemId))).get();
    return [for (final r in rows) r.tagId];
  }

  /// Replaces the tags of each Item in [byItem] with exactly the given set.
  /// Items not in the map keep theirs.
  Future<void> replaceItemTags(Map<String, Iterable<String>> byItem) async {
    if (byItem.isEmpty) return;
    await _db.batch((b) {
      b.deleteWhere(_db.itemTags, (t) => t.itemId.isIn(byItem.keys));
      for (final MapEntry(key: itemId, value: tagIds) in byItem.entries) {
        for (final tagId in tagIds.toSet()) {
          b.insert(
            _db.itemTags,
            ItemTagsCompanion.insert(itemId: itemId, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }

  /// Moves every link from [sourceId] to [targetId] (duplicates collapse)
  /// and deletes the source tag.
  Future<void> mergeInto(String sourceId, String targetId) =>
      _db.transaction(() async {
        await _db.customStatement(
          'INSERT OR IGNORE INTO item_tags (item_id, tag_id) '
          'SELECT item_id, ? FROM item_tags WHERE tag_id = ?',
          [targetId, sourceId],
        );
        // The Drift delete below also tells `item_tags` watchers.
        await delete(sourceId);
      });

  /// Open (not done, not trashed) Items per tag id, for the Tags screen and
  /// the delete confirmation.
  Stream<Map<String, int>> watchOpenCounts() {
    final count = _db.itemTags.itemId.count();
    final query =
        _db.selectOnly(_db.itemTags).join([
            innerJoin(_db.items, _db.items.id.equalsExp(_db.itemTags.itemId)),
          ])
          ..addColumns([_db.itemTags.tagId, count])
          ..where(
            _db.items.completedAt.isNull() &
                _db.items.status.isNotIn([
                  ItemStatus.done.name,
                  ItemStatus.trashed.name,
                ]),
          )
          ..groupBy([_db.itemTags.tagId]);
    return query.watch().map(
      (rows) => {
        for (final r in rows) r.read(_db.itemTags.tagId)!: r.read(count) ?? 0,
      },
    );
  }

  /// Whether any Item still carries [tagId]. Lets an import Undo keep a tag
  /// the user has started using meanwhile.
  Future<bool> isUsed(String tagId) async {
    final query = _db.selectOnly(_db.itemTags)
      ..addColumns([_db.itemTags.itemId])
      ..where(_db.itemTags.tagId.equals(tagId))
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }
}
