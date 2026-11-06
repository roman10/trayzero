import '../core/clock.dart';
import '../data/repositories/project_repository.dart';

final class MarkProjectReviewed {
  MarkProjectReviewed({required this.projects, required this.clock});
  final ProjectRepository projects;
  final Clock clock;

  Future<void> call(String id) => projects.markReviewed(id, clock.now());
}
