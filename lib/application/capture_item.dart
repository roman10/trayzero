import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';

/// Captures fresh text into the inbox. Used by the capture sheet, the share
/// intent listener, and any onboarding-style flow that drops new items in.
final class CaptureItem {
  CaptureItem({
    required ItemRepository items,
    required Clock clock,
    required IdGenerator ids,
  })  : _items = items,
        _clock = clock,
        _ids = ids;

  final ItemRepository _items;
  final Clock _clock;
  final IdGenerator _ids;

  Future<Item> call({required String title, String? notes}) async {
    final now = _clock.now();
    final item = Item(
      id: _ids.newId(),
      title: title,
      notes: notes,
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    );
    await _items.upsert(item);
    return item;
  }
}
