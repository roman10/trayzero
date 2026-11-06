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
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<List<ReviewLog>> all() async =>
      (await _db.select(_db.reviews).get()).map((r) => r.toEntity()).toList();

  Future<void> upsertAll(List<ReviewLog> rows) async {
    if (rows.isEmpty) return;
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(
        _db.reviews,
        rows
            .map(
              (r) => ReviewsCompanion.insert(
                id: r.id,
                type: r.type,
                startedAt: r.startedAt,
                completedAt: Value(r.completedAt),
                notes: Value(r.notes),
                currentStep: Value(r.currentStep.name),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> insert(ReviewLog r) async {
    await _db
        .into(_db.reviews)
        .insert(
          ReviewsCompanion.insert(
            id: r.id,
            type: r.type,
            startedAt: r.startedAt,
            completedAt: Value(r.completedAt),
            notes: Value(r.notes),
            currentStep: Value(r.currentStep.name),
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
    final row =
        await (_db.select(_db.reviews)
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.toEntity();
  }

  Stream<ReviewLog?> watchIncompleteWeekly() =>
      (_db.select(_db.reviews)
            ..where(
              (t) =>
                  t.type.equals(ReviewType.weekly.name) &
                  t.completedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.startedAt),
              (t) => OrderingTerm.asc(t.id),
            ])
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row?.toEntity());

  /// The most recently finished daily plan, if any (ADR 0007).
  Stream<ReviewLog?> watchLatestCompletedDaily() =>
      (_db.select(_db.reviews)
            ..where(
              (t) =>
                  t.type.equals(ReviewType.daily.name) &
                  t.completedAt.isNotNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row?.toEntity());

  /// A transaction also prevents overlapping start requests from creating
  /// separate sessions. Existing incomplete Reviews (including restored ones)
  /// are resumed without changing their start time.
  Future<ReviewLog> startOrResume(ReviewLog fresh) => _db.transaction(() async {
    final existing =
        await (_db.select(_db.reviews)
              ..where(
                (t) =>
                    t.type.equals(ReviewType.weekly.name) &
                    t.completedAt.isNull(),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.startedAt),
                (t) => OrderingTerm.asc(t.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return existing.toEntity();
    await insert(fresh);
    return fresh;
  });

  Future<void> saveStep(String id, WeeklyReviewStep step) async {
    final count =
        await (_db.update(_db.reviews)..where(
              (t) =>
                  t.id.equals(id) &
                  t.type.equals(ReviewType.weekly.name) &
                  t.completedAt.isNull(),
            ))
            .write(ReviewsCompanion(currentStep: Value(step.name)));
    if (count != 1) throw StateError('Review is no longer in progress');
  }

  Future<void> finishWeekly(String id, DateTime now) async {
    final count =
        await (_db.update(_db.reviews)..where(
              (t) =>
                  t.id.equals(id) &
                  t.type.equals(ReviewType.weekly.name) &
                  t.completedAt.isNull(),
            ))
            .write(ReviewsCompanion(completedAt: Value(now)));
    if (count != 1) throw StateError('Review is no longer in progress');
  }
}
