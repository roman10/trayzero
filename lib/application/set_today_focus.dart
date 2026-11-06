import '../core/clock.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';

/// Commits Items to Today, or removes them (ADR 0007). Returns each Item's
/// previous stamp so callers can offer Undo through [restore].
final class SetTodayFocus {
  SetTodayFocus({required this.items, required this.clock});
  final ItemRepository items;
  final Clock clock;

  Future<Map<String, DateTime?>> call(
    Iterable<Item> targets, {
    required bool focused,
  }) async {
    final now = clock.now();
    final previous = {for (final i in targets) i.id: i.focusedAt};
    await items.setFocusedAt({
      for (final id in previous.keys) id: focused ? now : null,
    });
    return previous;
  }

  Future<void> restore(Map<String, DateTime?> previous) =>
      items.setFocusedAt(previous);
}
