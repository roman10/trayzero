import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/repositories/project_repository.dart';
import '../domain/entities/entities.dart';
import 'save_item.dart';

final class AddProjectNextAction {
  AddProjectNextAction({
    required this.projects,
    required this.saveItem,
    required this.clock,
    required this.ids,
  });
  final ProjectRepository projects;
  final SaveItem saveItem;
  final Clock clock;
  final IdGenerator ids;

  Future<void> call(String projectId, String title) async {
    final text = title.trim();
    if (text.isEmpty) throw ArgumentError('An action needs a title');
    if (await projects.getById(projectId) == null) {
      throw StateError('Project no longer exists');
    }
    final now = clock.now();
    await saveItem(
      Item(
        id: ids.newId(),
        title: text,
        status: ItemStatus.nextAction,
        projectId: projectId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
