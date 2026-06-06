import 'enums.dart';

class ReviewLog {
  const ReviewLog({
    required this.id,
    required this.type,
    required this.startedAt,
    this.completedAt,
    this.notes,
  });
  final String id;
  final ReviewType type;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;
}
