import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

void main() {
  late AppDatabase db;
  late ReviewRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ReviewRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  ReviewLog log(
    String id, {
    ReviewType type = ReviewType.weekly,
    required DateTime startedAt,
    DateTime? completedAt,
    String? notes,
  }) =>
      ReviewLog(
        id: id,
        type: type,
        startedAt: startedAt,
        completedAt: completedAt,
        notes: notes,
      );

  test('inserting a review makes it visible to watchAll', () async {
    await repo.insert(log('a', startedAt: DateTime(2026, 5, 14, 9)));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.id, 'a');
    expect(all.single.completedAt, isNull);
  });

  test('watchAll orders by startedAt descending', () async {
    await repo.insert(log('mon', startedAt: DateTime(2026, 5, 11, 9)));
    await repo.insert(log('wed', startedAt: DateTime(2026, 5, 13, 9)));
    await repo.insert(log('tue', startedAt: DateTime(2026, 5, 12, 9)));
    final all = await repo.watchAll().first;
    expect(all.map((r) => r.id), ['wed', 'tue', 'mon']);
  });

  test('insert persists the review type', () async {
    await repo.insert(
        log('d', type: ReviewType.daily, startedAt: DateTime(2026, 5, 14)));
    final all = await repo.watchAll().first;
    expect(all.single.type, ReviewType.daily);
  });

  test('complete sets the completedAt timestamp', () async {
    await repo.insert(log('a', startedAt: DateTime(2026, 5, 14, 9)));
    final finishedAt = DateTime(2026, 5, 14, 10, 30);
    await repo.complete('a', finishedAt);
    final fetched = (await repo.watchAll().first).single;
    expect(fetched.completedAt, finishedAt);
  });

  test('complete with notes records the notes', () async {
    await repo.insert(log('a', startedAt: DateTime(2026, 5, 14, 9)));
    await repo.complete('a', DateTime(2026, 5, 14, 10),
        notes: 'Cleared inbox; deferred two items.');
    final fetched = (await repo.watchAll().first).single;
    expect(fetched.notes, 'Cleared inbox; deferred two items.');
  });

  test('complete without notes leaves an existing note untouched', () async {
    await repo.insert(log('a',
        startedAt: DateTime(2026, 5, 14, 9), notes: 'original note'));
    await repo.complete('a', DateTime(2026, 5, 14, 10));
    final fetched = (await repo.watchAll().first).single;
    expect(fetched.notes, 'original note');
    expect(fetched.completedAt, DateTime(2026, 5, 14, 10));
  });

  test('latest returns the most recently started review', () async {
    await repo.insert(log('old', startedAt: DateTime(2026, 5, 10, 9)));
    await repo.insert(log('new', startedAt: DateTime(2026, 5, 14, 9)));
    expect((await repo.latest())?.id, 'new');
  });

  test('latest returns null when no reviews exist', () async {
    expect(await repo.latest(), isNull);
  });
}
