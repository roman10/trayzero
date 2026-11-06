import '../core/clock.dart';
import '../data/repositories/review_repository.dart';

final class FinishWeeklyReview {
  FinishWeeklyReview({required this.reviews, required this.clock});
  final ReviewRepository reviews;
  final Clock clock;
  Future<void> call(String id) => reviews.finishWeekly(id, clock.now());
}
