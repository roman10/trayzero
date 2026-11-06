import '../core/clock.dart';
import '../data/repositories/project_repository.dart';
import '../domain/entities/entities.dart';

final class ChangeProjectStatus {
  ChangeProjectStatus({required this.projects, required this.clock});
  final ProjectRepository projects;
  final Clock clock;

  Future<void> call(String id, ProjectStatus status) =>
      projects.changeStatus(id, status, clock.now());
}
