import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/db/database.dart';
import '../data/repositories/tag_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/tags.dart';

/// Outcome of a rename (ADR 0010). A name taken by another tag is not an
/// error: the UI offers to merge into [existing].
sealed class RenameTagResult {
  const RenameTagResult();
}

final class TagRenamed extends RenameTagResult {
  const TagRenamed();
}

final class TagNameTaken extends RenameTagResult {
  const TagNameTaken(this.existing);
  final Tag existing;
}

final class TagNameInvalid extends RenameTagResult {
  const TagNameInvalid();
}

/// Creates, renames, merges, deletes, and assigns tags (ADR 0010). Names are
/// unique ignoring case; every path resolves a clash to the existing tag.
final class ManageTags {
  ManageTags({
    required AppDatabase database,
    required TagRepository tags,
    required Clock clock,
    required IdGenerator ids,
  }) : _database = database,
       _tags = tags,
       _clock = clock,
       _ids = ids;

  final AppDatabase _database;
  final TagRepository _tags;
  final Clock _clock;
  final IdGenerator _ids;

  /// The tag named [name] (ignoring case), created when missing. Asking for
  /// a person makes an existing plain tag a person too. Null when [name] has
  /// nothing usable.
  Future<Tag?> obtain(String name, {bool isPerson = false}) =>
      _database.transaction(() async {
        final clean = cleanTagName(name);
        if (clean == null) return null;
        final existing = findTagByName(await _tags.all(), clean);
        if (existing != null) {
          if (isPerson && !existing.isPerson) {
            final person = existing.copyWith(isPerson: true);
            await _tags.upsert(person, createdAt: _clock.now());
            return person;
          }
          return existing;
        }
        final tag = Tag(id: _ids.newId(), name: clean, isPerson: isPerson);
        await _tags.upsert(tag, createdAt: _clock.now());
        return tag;
      });

  Future<RenameTagResult> rename(String id, String name) =>
      _database.transaction(() async {
        final clean = cleanTagName(name);
        if (clean == null) return const TagNameInvalid();
        final all = await _tags.all();
        final current = all.where((t) => t.id == id).firstOrNull;
        if (current == null) return const TagRenamed();
        final clash = findTagByName(all.where((t) => t.id != id), clean);
        if (clash != null) return TagNameTaken(clash);
        await _tags.upsert(
          current.copyWith(name: clean),
          createdAt: _clock.now(),
        );
        return const TagRenamed();
      });

  Future<void> setPerson(String id, bool isPerson) async {
    final tag = await _tags.getById(id);
    if (tag == null || tag.isPerson == isPerson) return;
    await _tags.upsert(
      tag.copyWith(isPerson: isPerson),
      createdAt: _clock.now(),
    );
  }

  /// Moves every Item from [sourceId] to [targetId] and deletes the source.
  /// The result is a person when either tag was.
  Future<void> merge(String sourceId, String targetId) async {
    if (sourceId == targetId) return;
    await _database.transaction(() async {
      final source = await _tags.getById(sourceId);
      final target = await _tags.getById(targetId);
      if (source == null || target == null) return;
      if (source.isPerson && !target.isPerson) {
        await _tags.upsert(
          target.copyWith(isPerson: true),
          createdAt: _clock.now(),
        );
      }
      await _tags.mergeInto(sourceId, targetId);
    });
  }

  /// Deletes the tag; Items keep everything else.
  Future<void> delete(String id) => _tags.delete(id);

  /// Sets exactly [tagIds] on the Item.
  Future<void> setItemTags(String itemId, Iterable<String> tagIds) =>
      _tags.replaceItemTags({itemId: tagIds});
}
