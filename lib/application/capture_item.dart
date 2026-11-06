import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/db/database.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import 'manage_tags.dart';

/// Captures fresh text into the inbox. Used by the capture sheet, the share
/// intent listener, and any onboarding-style flow that drops new items in.
///
/// Quick-capture parsing (ADR 0007) may supply a context, project, and start
/// or due date. The Item still lands in the Inbox — capture is not Clarify —
/// and those fields pre-fill Process Inbox. A dated capture reconciles its
/// reminders immediately (best effort), as the launch re-arm would.
///
/// `+tag` names (ADR 0010) attach existing tags or create missing ones in the
/// same transaction as the Item, so a failed save leaves nothing behind.
final class CaptureItem {
  CaptureItem({
    required ItemRepository items,
    required Clock clock,
    required IdGenerator ids,
    Future<void> Function(Item item)? reconcileReminders,
    int dueMinutesOfDay = 540,
    AppDatabase? database,
    ManageTags? tags,
  })  : _database = database,
        _tags = tags,
        _items = items,
        _clock = clock,
        _ids = ids,
        _reconcileReminders = reconcileReminders,
        _dueMinutesOfDay = dueMinutesOfDay;

  final AppDatabase? _database;
  final ManageTags? _tags;
  final ItemRepository _items;
  final Clock _clock;
  final IdGenerator _ids;
  final Future<void> Function(Item item)? _reconcileReminders;

  /// A parsed due date has no time; it lands at the configured reminder hour
  /// (the defer "Ready:" hour) so its Due reminder never fires at midnight.
  final int _dueMinutesOfDay;

  Future<Item> call({
    required String title,
    String? notes,
    String? contextId,
    String? projectId,
    DateTime? deferUntil,
    DateTime? dueAt,
    List<String> tagNames = const [],
  }) async {
    final now = _clock.now();
    final item = Item(
      id: _ids.newId(),
      title: title,
      notes: notes,
      status: ItemStatus.inbox,
      contextId: contextId,
      projectId: projectId,
      deferUntil: deferUntil,
      dueAt: dueAt == null
          ? null
          : DateTime(
              dueAt.year,
              dueAt.month,
              dueAt.day,
              _dueMinutesOfDay ~/ 60,
              _dueMinutesOfDay % 60,
            ),
      createdAt: now,
      updatedAt: now,
    );
    final database = _database;
    final tags = _tags;
    if (tagNames.isEmpty || database == null || tags == null) {
      await _items.upsert(item);
    } else {
      await database.transaction(() async {
        await _items.upsert(item);
        final ids = <String>{};
        for (final name in tagNames) {
          final tag = await tags.obtain(name);
          if (tag != null) ids.add(tag.id);
        }
        await tags.setItemTags(item.id, ids);
      });
    }
    if (item.deferUntil != null || item.dueAt != null) {
      try {
        await _reconcileReminders?.call(item);
      } catch (_) {
        // The Item is already saved; reporting failure would invite a
        // duplicate retry. The launch re-arm heals a missed reminder.
      }
    }
    return item;
  }
}
