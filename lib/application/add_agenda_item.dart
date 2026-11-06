import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/db/database.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/tag_repository.dart';
import '../domain/entities/entities.dart';

/// Adds a talking point to a person's Agenda (ADR 0010): a Next Action
/// tagged with the person. The user has already clarified it ("discuss with
/// Alice"), so it skips the Inbox, like adding an action to a Project. It
/// has no dates, so there are no reminders to reconcile.
final class AddAgendaItem {
  AddAgendaItem({
    required AppDatabase database,
    required ItemRepository items,
    required TagRepository tags,
    required Clock clock,
    required IdGenerator ids,
  }) : _database = database,
       _items = items,
       _tags = tags,
       _clock = clock,
       _ids = ids;

  final AppDatabase _database;
  final ItemRepository _items;
  final TagRepository _tags;
  final Clock _clock;
  final IdGenerator _ids;

  Future<Item> call(String personTagId, String title) async {
    final text = title.trim();
    if (text.isEmpty) throw ArgumentError('An agenda item needs a title');
    return _database.transaction(() async {
      if (await _tags.getById(personTagId) == null) {
        throw StateError('Person no longer exists');
      }
      final now = _clock.now();
      final item = Item(
        id: _ids.newId(),
        title: text,
        status: ItemStatus.nextAction,
        createdAt: now,
        updatedAt: now,
      );
      await _items.upsert(item);
      await _tags.replaceItemTags({
        item.id: [personTagId],
      });
      return item;
    });
  }
}
