import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class ProjectRepository {
  ProjectRepository(this._db);
  final AppDatabase _db;

  Stream<List<Project>> watchAll() {
    final query = _db.select(_db.projects)
      ..orderBy([
        (t) => OrderingTerm.asc(t.status),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Stream<List<Project>> watchByStatus(ProjectStatus status) {
    final query = _db.select(_db.projects)
      ..where((t) => t.status.equals(status.name))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<Project?> getById(String id) async {
    final row =
        await (_db.select(_db.projects)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    return row?.toEntity();
  }

  Future<void> upsert(Project project) async {
    await _db
        .into(_db.projects)
        .insertOnConflictUpdate(project.toCompanion());
  }

  /// Bulk upsert in a single batched transaction. See
  /// [ItemRepository.upsertAll].
  Future<void> upsertAll(List<Project> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.projects,
        rows.map((r) => r.toCompanion()).toList(),
      );
    });
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();
  }
}
