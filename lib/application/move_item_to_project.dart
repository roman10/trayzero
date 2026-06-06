import '../domain/entities/entities.dart';
import 'save_item.dart';

/// Re-files an existing item under a project (or detaches it when
/// [projectId] is null). Routed through [SaveItem] so the "edit → reconcile
/// reminders" wiring stays in one place, matching every other item mutation.
final class MoveItemToProject {
  MoveItemToProject({required SaveItem saveItem}) : _saveItem = saveItem;

  final SaveItem _saveItem;

  Future<Item> call(Item item, String? projectId) => _saveItem(
    item.copyWith(projectId: projectId, clearProject: projectId == null),
  );
}
