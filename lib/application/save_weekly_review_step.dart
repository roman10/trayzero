import '../data/repositories/review_repository.dart';
import '../domain/entities/entities.dart';

final class SaveWeeklyReviewStep {
  SaveWeeklyReviewStep(this.reviews);
  final ReviewRepository reviews;
  Future<void> call(String id, WeeklyReviewStep step) =>
      reviews.saveStep(id, step);
}
