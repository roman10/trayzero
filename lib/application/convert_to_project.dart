import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/repositories/project_repository.dart';
import '../domain/entities/entities.dart';
import 'save_item.dart';

/// Turns a captured inbox row into a project plus its first next-action.
///
/// The original item is reshaped (status → nextAction, title prefixed with
/// "Define next action for …") and attached to a new project carrying the
/// captured title as the outcome shell. The follow-on save goes through
/// [SaveItem] so any notification reconciliation lives in one place.
final class ConvertToProject {
  ConvertToProject({
    required ProjectRepository projects,
    required SaveItem saveItem,
    required Clock clock,
    required IdGenerator ids,
  })  : _projects = projects,
        _saveItem = saveItem,
        _clock = clock,
        _ids = ids;

  final ProjectRepository _projects;
  final SaveItem _saveItem;
  final Clock _clock;
  final IdGenerator _ids;

  Future<({Project project, Item firstAction})> call(Item original) async {
    final now = _clock.now();
    final project = Project(
      id: _ids.newId(),
      title: original.title,
      outcome: original.notes,
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _projects.upsert(project);
    final firstAction = await _saveItem(original.copyWith(
      title: 'Define next action for "${original.title}"',
      status: ItemStatus.nextAction,
      projectId: project.id,
    ));
    return (project: project, firstAction: firstAction);
  }
}
