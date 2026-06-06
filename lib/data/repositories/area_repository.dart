import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class AreaRepository {
  AreaRepository(this._db);
  final AppDatabase _db;

  Stream<List<Area>> watchAll() {
    final query = _db.select(_db.areas)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<Area?> getById(String id) async {
    final row = await (_db.select(_db.areas)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  Future<void> upsert(Area area) =>
      _db.into(_db.areas).insertOnConflictUpdate(area.toCompanion());

  /// Bulk upsert in a single batched transaction. See
  /// [ItemRepository.upsertAll].
  Future<void> upsertAll(List<Area> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.areas,
        rows.map((r) => r.toCompanion()).toList(),
      );
    });
  }

  Future<void> delete(String id) async {
    // Detach projects first to avoid orphaned area references.
    await (_db.update(_db.projects)..where((t) => t.areaId.equals(id)))
        .write(const ProjectsCompanion(areaId: Value(null)));
    await (_db.delete(_db.areas)..where((t) => t.id.equals(id))).go();
  }
}
