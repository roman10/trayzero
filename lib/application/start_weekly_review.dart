import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/repositories/review_repository.dart';
import '../domain/entities/entities.dart';

final class StartWeeklyReview {
  StartWeeklyReview({
    required this.reviews,
    required this.clock,
    required this.ids,
  });
  final ReviewRepository reviews;
  final Clock clock;
  final IdGenerator ids;

  Future<ReviewLog> call() => reviews.startOrResume(
    ReviewLog(id: ids.newId(), type: ReviewType.weekly, startedAt: clock.now()),
  );
}
