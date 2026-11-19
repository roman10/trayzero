import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/db/database.dart';
import '../data/repositories/project_repository.dart';
import '../domain/entities/entities.dart';
import 'save_item.dart';

/// Turns a captured inbox row into a project plus its first next-action.
///
/// The original item is reshaped (status → nextAction, title prefixed with
/// "Define next action for …") and attached to a new project carrying the
/// captured title as the outcome shell. The project and the reshaped item
/// are written in one transaction, so a failure leaves no orphan project and
/// a retry cannot duplicate it. The item save goes through [SaveItem], and
/// its reminders are reconciled only after the transaction commits.
final class ConvertToProject {
  ConvertToProject({
    required AppDatabase database,
    required ProjectRepository projects,
    required SaveItem saveItem,
    required Clock clock,
    required IdGenerator ids,
  })  : _database = database,
        _projects = projects,
        _saveItem = saveItem,
        _clock = clock,
        _ids = ids;

  final AppDatabase _database;
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
    final firstAction = await _database.transaction(() async {
      await _projects.upsert(project);
      return _saveItem.write(original.copyWith(
        title: 'Define next action for "${original.title}"',
        status: ItemStatus.nextAction,
        projectId: project.id,
      ));
    });
    await _saveItem.reconcileReminders(firstAction);
    return (project: project, firstAction: firstAction);
  }
}
