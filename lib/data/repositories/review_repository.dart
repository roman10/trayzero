import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class ReviewRepository {
  ReviewRepository(this._db);
  final AppDatabase _db;

  Stream<List<ReviewLog>> watchAll() {
    final query = _db.select(_db.reviews)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<void> insert(ReviewLog r) async {
    await _db.into(_db.reviews).insert(
          ReviewsCompanion.insert(
            id: r.id,
            type: r.type,
            startedAt: r.startedAt,
            completedAt: Value(r.completedAt),
            notes: Value(r.notes),
          ),
        );
  }

  Future<void> complete(String id, DateTime now, {String? notes}) async {
    await (_db.update(_db.reviews)..where((t) => t.id.equals(id))).write(
      ReviewsCompanion(
        completedAt: Value(now),
        notes: notes == null ? const Value.absent() : Value(notes),
      ),
    );
  }

  Future<ReviewLog?> latest() async {
    final row = await (_db.select(_db.reviews)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.toEntity();
  }
}
