import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/db/database.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/review_repository.dart';
import '../domain/entities/entities.dart';

/// Finishes the daily plan (ADR 0007): carried-over Items the user did not
/// keep go back to their lists, and a completed `daily` Review is logged so
/// Today stops offering the plan card. Both happen in one transaction. The
/// cleared stamps are returned for Undo via `SetTodayFocus.restore`.
final class FinishDailyReview {
  FinishDailyReview({
    required this.database,
    required this.items,
    required this.reviews,
    required this.clock,
    required this.ids,
  });
  final AppDatabase database;
  final ItemRepository items;
  final ReviewRepository reviews;
  final Clock clock;
  final IdGenerator ids;

  Future<Map<String, DateTime?>> call({required Iterable<Item> notKept}) {
    final now = clock.now();
    final cleared = {for (final i in notKept) i.id: i.focusedAt};
    return database.transaction(() async {
      await items.setFocusedAt({for (final id in cleared.keys) id: null});
      await reviews.insert(
        ReviewLog(
          id: ids.newId(),
          type: ReviewType.daily,
          startedAt: now,
          completedAt: now,
        ),
      );
      return cleared;
    });
  }
}
