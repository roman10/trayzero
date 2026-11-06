import 'package:drift/drift.dart';

import '../db/database.dart';

/// Device-local ownership survives Item deletion and is never backed up.
/// A superseded mirror remains recorded until native deletion succeeds.
class CalendarMirrorRepository {
  CalendarMirrorRepository(this._db);
  final AppDatabase _db;

  Future<List<CalendarMirrorRow>> all() =>
      _db.select(_db.calendarMirrors).get();

  /// Older databases knew event ids but not calendar ids. Bind those records
  /// once, to the previously selected calendar supplied by the mirror run.
  Future<void> bindLegacyCalendar(String calendarId) async {
    final legacy = await (_db.select(
      _db.calendarMirrors,
    )..where((t) => t.calendarId.equals(''))).get();
    await _db.transaction(() async {
      for (final row in legacy) {
        await _db
            .into(_db.calendarMirrors)
            .insertOnConflictUpdate(
              CalendarMirrorsCompanion.insert(
                calendarId: calendarId,
                eventId: row.eventId,
                itemId: row.itemId,
                isCurrent: Value(row.isCurrent),
              ),
            );
        await (_db.delete(_db.calendarMirrors)..where(
              (t) => t.calendarId.equals('') & t.eventId.equals(row.eventId),
            ))
            .go();
      }
    });
  }

  Future<void> record({
    required String itemId,
    required String calendarId,
    required String eventId,
    String? replacingEventId,
  }) => _db.transaction(() async {
    await (_db.update(_db.calendarMirrors)
          ..where((t) => t.itemId.equals(itemId)))
        .write(const CalendarMirrorsCompanion(isCurrent: Value(false)));
    await _db
        .into(_db.calendarMirrors)
        .insertOnConflictUpdate(
          CalendarMirrorsCompanion.insert(
            calendarId: calendarId,
            eventId: eventId,
            itemId: itemId,
            isCurrent: const Value(true),
          ),
        );
    // Recurrence instances inherit one native series id. Move their pointers
    // together, including a successor created while the native write awaited.
    if (replacingEventId != null && replacingEventId != eventId) {
      await (_db.update(_db.items)
            ..where((t) => t.calendarEventId.equals(replacingEventId)))
          .write(ItemsCompanion(calendarEventId: Value(eventId)));
    }
    await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(calendarEventId: Value(eventId)),
    );
  });

  Future<void> forget(CalendarMirrorRow row) => _db.transaction(() async {
    await (_db.delete(_db.calendarMirrors)..where(
          (t) =>
              t.calendarId.equals(row.calendarId) &
              t.eventId.equals(row.eventId),
        ))
        .go();
    final another =
        await (_db.select(_db.calendarMirrors)..where(
              (t) => t.eventId.equals(row.eventId) & t.isCurrent.equals(true),
            ))
            .get();
    if (another.isEmpty) {
      await (_db.update(_db.items)
            ..where((t) => t.calendarEventId.equals(row.eventId)))
          .write(const ItemsCompanion(calendarEventId: Value(null)));
    }
  });
}
