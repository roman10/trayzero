import '../core/clock.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';

/// Pushes an inbox item to the back of the Process queue without changing
/// its status. Used by the "Skip" affordance in the Process flow.
final class SkipInboxItem {
  SkipInboxItem({required ItemRepository items, required Clock clock})
      : _items = items,
        _clock = clock;
  final ItemRepository _items;
  final Clock _clock;

  Future<void> call(Item current) async {
    final now = _clock.now();
    await _items.upsert(current.copyWith(
      sortOrder: now.millisecondsSinceEpoch,
      updatedAt: now,
    ));
  }
}
