import 'enums.dart';

class ReviewLog {
  const ReviewLog({
    required this.id,
    required this.type,
    required this.startedAt,
    this.completedAt,
    this.notes,
    this.currentStep = WeeklyReviewStep.capture,
  });
  final String id;
  final ReviewType type;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;
  final WeeklyReviewStep currentStep;
}
