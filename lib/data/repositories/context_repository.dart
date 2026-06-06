import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class ContextRepository {
  ContextRepository(this._db);
  final AppDatabase _db;

  Stream<List<GtdContext>> watchAll() {
    final query = _db.select(_db.contexts)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<List<GtdContext>> all() async {
    final rows = await (_db.select(_db.contexts)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  Future<GtdContext?> getById(String id) async {
    final row = await (_db.select(_db.contexts)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  Future<void> upsert(GtdContext ctx) async {
    await _db
        .into(_db.contexts)
        .insertOnConflictUpdate(ctx.toCompanion());
  }

  /// Bulk upsert in a single batched transaction. See
  /// [ItemRepository.upsertAll].
  Future<void> upsertAll(List<GtdContext> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.contexts,
        rows.map((r) => r.toCompanion()).toList(),
      );
    });
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.contexts)..where((t) => t.id.equals(id))).go();
  }
}
