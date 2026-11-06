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

  /// Inserts or saves an ordinary edit of [project]. An existing row keeps
  /// its stored `lastReviewedAt`: an edit screen's copy may predate a review
  /// mark made meanwhile, so only [markReviewed] writes it.
  Future<void> upsert(Project project) async {
    final companion = project.toCompanion();
    await _db.into(_db.projects).insert(
      companion,
      onConflict: DoUpdate(
        (_) => companion.copyWith(lastReviewedAt: const Value.absent()),
      ),
    );
  }

  /// Change only lifecycle status; a stale review card cannot overwrite edits
  /// to the Project's outcome or recreate a Project that has been deleted.
  Future<void> changeStatus(String id, ProjectStatus status, DateTime now) async {
    final count = await (_db.update(_db.projects)..where((t) => t.id.equals(id)))
        .write(ProjectsCompanion(status: Value(status), updatedAt: Value(now)));
    if (count != 1) throw StateError('Project no longer exists');
  }

  /// Save an inline outcome without overwriting a newer metadata or status edit.
  Future<void> updateOutcome(String id, String? outcome, DateTime now) async {
    final count = await (_db.update(_db.projects)..where((t) => t.id.equals(id)))
        .write(ProjectsCompanion(outcome: Value(outcome), updatedAt: Value(now)));
    if (count != 1) throw StateError('Project no longer exists');
  }

  /// Save the fields from Edit project without rewriting the inline outcome.
  Future<void> updateDetails(
    String id, {
    required String title,
    required String? areaId,
    required DateTime? dueAt,
    required DateTime now,
  }) async {
    final count = await (_db.update(_db.projects)..where((t) => t.id.equals(id)))
        .write(
          ProjectsCompanion(
            title: Value(title),
            areaId: Value(areaId),
            dueAt: Value(dueAt),
            updatedAt: Value(now),
          ),
        );
    if (count != 1) throw StateError('Project no longer exists');
  }

  /// Records a Weekly Review pass. Does not stamp `updatedAt`, so marking a
  /// Project reviewed never reorders the Projects list.
  Future<void> markReviewed(String id, DateTime now) async {
    final count = await (_db.update(_db.projects)..where((t) => t.id.equals(id)))
        .write(ProjectsCompanion(lastReviewedAt: Value(now)));
    if (count != 1) throw StateError('Project no longer exists');
  }

  /// Bulk upsert in a single batched transaction, writing every column
  /// (a restore replaces rows wholesale). See [ItemRepository.upsertAll].
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
    await _db.transaction(() async {
      await (_db.update(_db.items)..where((t) => t.projectId.equals(id)))
          .write(const ItemsCompanion(projectId: Value(null)));
      await (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();
    });
  }
}
