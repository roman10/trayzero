import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../core/calendar_gateway.dart';
import '../core/clock.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';

/// Outcome of a [CalendarSyncService.mirrorOut] run.
class MirrorOutResult {
  const MirrorOutResult({required this.written, required this.removed});

  /// Events created or updated.
  final int written;

  /// Stale events deleted (item completed / trashed / due date cleared).
  final int removed;
}

/// Two-way bridge between Trayzero items and the device's system calendar.
///
/// **Mirror-out:** every active item with a `dueAt` is mirrored as an event
/// in the user-chosen target calendar. The platform event id the calendar
/// assigns is stored back on the item ([Item.calendarEventId]) so the next
/// run updates the same event in place instead of creating a duplicate, and
/// so events can be deleted when the item no longer qualifies.
///
/// **Import-in:** events whose title contains `#gtd` are imported as
/// Calendar items into the Trayzero inbox, idempotent on the event id.
///
/// Off by default. Wired through `calendarSyncEnabledProvider` (see
/// settings_controller.dart). The user picks a target calendar in
/// Settings → Calendar sync. All platform/timezone concerns live behind
/// [CalendarGateway].
class CalendarSyncService {
  CalendarSyncService(this._items, this._clock, this._gateway);

  final ItemRepository _items;
  final Clock _clock;
  final CalendarGateway _gateway;

  /// Title prefix used to tag Trayzero-owned events. Idempotency is keyed on
  /// the stored [Item.calendarEventId], not this label, so renaming it just
  /// rewrites the visible title in place on the next mirror-out — existing
  /// `[Cleartray] …` events are re-titled, not orphaned or duplicated.
  static const tagPrefix = '[Trayzero] ';

  /// Title substring expected to import system events back as inbox items.
  /// Kept as `#gtd` (the ecosystem-standard hashtag) so users coming from
  /// other GTD tools find it familiar.
  static const importPrefix = '#gtd';

  /// Id prefix for items created by [importIn]. Such items came *from* the
  /// calendar, so mirror-out skips them to avoid round-tripping a second
  /// `[Trayzero] …` event back onto the same calendar.
  static const importedIdPrefix = 'cal-';

  Future<bool> requestPermissions() => _gateway.requestPermissions();

  Future<List<CalendarInfo>> listCalendars() => _gateway.listCalendars();

  /// Mirror every active calendar item (`status == calendar`, with a
  /// `dueAt`) into [calendarId], and remove events for items that were
  /// previously mirrored but no longer qualify (completed, trashed, due date
  /// cleared, or moved off the calendar). Only true hard-landscape items
  /// reach the OS calendar — a soft due date on a next-action stays in-app.
  ///
  /// Idempotent: the platform event id is stored on the item and reused, so
  /// re-running updates the same event rather than duplicating it.
  Future<MirrorOutResult> mirrorOut({required String calendarId}) async {
    final active = await _items.allActive();
    final shouldMirror = <String, Item>{
      for (final i in active)
        if (i.status == ItemStatus.calendar &&
            i.dueAt != null &&
            !i.id.startsWith(importedIdPrefix))
          i.id: i,
    };

    var written = 0;
    // A recurring series shares one event id across its instances; only
    // write it once per run even if a just-completed instance briefly
    // co-exists with its successor.
    final seenEventIds = <String>{};
    for (final i in shouldMirror.values) {
      if (i.calendarEventId != null &&
          !seenEventIds.add(i.calendarEventId!)) {
        continue;
      }
      final start = i.dueAt!;
      final eventId = await _gateway.upsertEvent(CalendarEventDraft(
        calendarId: calendarId,
        id: i.calendarEventId,
        title: '$tagPrefix${i.title}',
        description: i.notes,
        start: start,
        end: start.add(const Duration(hours: 1)),
        recurrence: calendarRecurrenceOf(i),
      ));
      if (eventId == null) continue;
      written++;
      seenEventIds.add(eventId);
      if (eventId != i.calendarEventId) {
        await _items.setCalendarEventId(i.id, eventId);
      }
    }

    // Event ids still owned by an instance we mirrored this run. Used so a
    // completed recurring instance doesn't delete the live series its
    // successor now drives.
    final liveEventIds = {
      for (final i in shouldMirror.values)
        if (i.calendarEventId != null) i.calendarEventId!,
    };

    // Reconcile: events we mirrored before that shouldn't exist anymore.
    var removed = 0;
    for (final i in await _items.withCalendarEventId()) {
      if (shouldMirror.containsKey(i.id)) continue;
      if (liveEventIds.contains(i.calendarEventId)) {
        // The series continues on a live instance — keep the event, just
        // detach this stale (e.g. completed) owner so it isn't revisited.
        await _items.setCalendarEventId(i.id, null);
        continue;
      }
      final ok = await _gateway.deleteEvent(
        calendarId: calendarId,
        eventId: i.calendarEventId!,
      );
      if (ok) removed++;
      // Clear the id either way: a failed delete almost always means the
      // event is already gone, and a stale id would retry forever.
      await _items.setCalendarEventId(i.id, null);
    }

    return MirrorOutResult(written: written, removed: removed);
  }

  /// Pull events whose title contains `#gtd` from [calendarId] within the
  /// lookback window into the GTD inbox. Idempotent on the event id.
  Future<int> importIn({
    required String calendarId,
    Duration lookback = const Duration(days: 7),
  }) async {
    final now = _clock.now();
    final events = await _gateway.eventsInRange(
      calendarId: calendarId,
      from: now.subtract(lookback),
      to: now.add(const Duration(days: 365)),
    );
    var imported = 0;
    for (final e in events) {
      if (!e.title.toLowerCase().contains(importPrefix)) continue;
      final cleaned = e.title
          .replaceAll(
              RegExp(RegExp.escape(importPrefix), caseSensitive: false), '')
          .trim();
      final id = '$importedIdPrefix${e.id}';
      if (await _items.getById(id) != null) continue; // already imported
      final ts = _clock.now();
      await _items.upsert(Item(
        id: id,
        title: cleaned.isEmpty ? '(untitled calendar event)' : cleaned,
        status: ItemStatus.calendar,
        dueAt: e.start,
        createdAt: ts,
        updatedAt: ts,
      ));
      imported++;
    }
    return imported;
  }
}

/// Map an item's structured recurrence + end condition to the
/// platform-agnostic [CalendarRecurrence], or null when the item does not
/// recur. Pure; the single place item recurrence becomes a calendar series.
///
/// A recurring series is mirrored as one native RRULE event carried across
/// instances by [Item.calendarEventId]; each completion re-anchors that
/// event to the live instance's `dueAt`. That re-anchor is deliberate, not
/// a leak: it is what lets a single carried event represent "the rest of
/// the series" at any point. For it to stay correct, a `COUNT`-bounded
/// series must export the *remaining* occurrences from the live instance
/// forward — `recurrenceCount` is the original total, so we subtract the
/// occurrences already done ([Item.recurrenceDoneCount]). Without this the
/// calendar would show the full total from every instance and a counted
/// series would never terminate. `UNTIL` needs no adjustment (a fixed end
/// instant shrinks naturally as the start re-anchors).
CalendarRecurrence? calendarRecurrenceOf(Item item) {
  final rule = item.recurrenceRule;
  if (rule == null) return null;
  final total = item.recurrenceCount;
  // Remaining occurrences from this instance forward, floored at 1 so an
  // over-completed / edited-down series (or corrupt imported data) still
  // exports a valid RRULE rather than an invalid COUNT<=0. No upper cap is
  // needed: recurrenceDoneCount is non-negative, so the difference never
  // exceeds the original total.
  final int? remainingCount;
  if (total == null) {
    remainingCount = null;
  } else {
    final remaining = total - item.recurrenceDoneCount;
    remainingCount = remaining < 1 ? 1 : remaining;
  }
  return CalendarRecurrence(
    frequency: switch (rule.frequency) {
      Recurrence.daily => CalendarFrequency.daily,
      Recurrence.weekly => CalendarFrequency.weekly,
      Recurrence.monthly => CalendarFrequency.monthly,
      Recurrence.yearly => CalendarFrequency.yearly,
    },
    interval: rule.interval,
    byWeekdays: (rule.byWeekdays.toList()..sort()),
    monthlyWeek: rule.monthlyWeek,
    monthlyWeekday: rule.monthlyWeekday,
    until: item.recurrenceUntil,
    count: remainingCount,
  );
}

final calendarSyncServiceProvider = Provider<CalendarSyncService>(
  (ref) => CalendarSyncService(
    ref.watch(itemRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(calendarGatewayProvider),
  ),
);
