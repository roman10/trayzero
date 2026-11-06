import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../core/calendar_gateway.dart';
import '../core/clock.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/calendar_mirror_repository.dart';
import '../domain/entities/entities.dart';

/// Outcome of a [CalendarSyncService.mirrorOut] run.
class MirrorOutResult {
  const MirrorOutResult({
    required this.written,
    required this.removed,
    this.pendingRemovals = 0,
    this.failedWrites = 0,
  });

  /// Events created or updated.
  final int written;

  /// Stale events deleted (item completed / trashed / due date cleared).
  final int removed;

  /// Events still owned locally because native cleanup could not be confirmed.
  final int pendingRemovals;
  final int failedWrites;
  bool get successful => pendingRemovals == 0 && failedWrites == 0;
}

/// Device-calendar publication plus explicit one-time event imports.
/// Automatic scheduling and connection lifecycle belong to
/// CalendarConnectionController; native ownership is persisted independently
/// of Items so removal remains retryable after deletion or process death.
class CalendarSyncService {
  CalendarSyncService(
    this._items,
    this._clock,
    this._gateway, {
    required CalendarMirrorRepository mirrors,
  }) : _mirrors = mirrors;

  final ItemRepository _items;
  final Clock _clock;
  final CalendarGateway _gateway;
  final CalendarMirrorRepository _mirrors;
  Future<void> _mirrorTail = Future.value();

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

  /// Resolve pre-v10 ownership against the saved selection before the user
  /// can pick another calendar. Already-bound records are unchanged.
  Future<void> bindLegacyOwnership({required String calendarId}) =>
      _mirrors.bindLegacyCalendar(calendarId);

  /// Mirror every active calendar item (`status == calendar`, with a
  /// `dueAt`) into [calendarId], and remove events for items that were
  /// previously mirrored but no longer qualify (completed, trashed, due date
  /// cleared, or moved off the calendar). Only true hard-landscape items
  /// reach the OS calendar — a soft due date on a next-action stays in-app.
  ///
  /// Idempotent: the platform event id is stored on the item and reused, so
  /// re-running updates the same event rather than duplicating it.
  Future<MirrorOutResult> mirrorOut({
    required String calendarId,
    bool Function()? shouldContinue,
  }) async {
    final previous = _mirrorTail;
    final done = Completer<void>();
    _mirrorTail = done.future;
    try {
      await previous;
      return await _mirrorOut(calendarId, shouldContinue ?? () => true);
    } finally {
      done.complete();
    }
  }

  bool _qualifies(Item i) =>
      i.status == ItemStatus.calendar &&
      i.completedAt == null &&
      i.dueAt != null &&
      !i.id.startsWith(importedIdPrefix);

  Future<MirrorOutResult> _mirrorOut(
    String calendarId,
    bool Function() shouldContinue,
  ) async {
    if (calendarId.isEmpty) throw ArgumentError.value(calendarId, 'calendarId');
    await _mirrors.bindLegacyCalendar(calendarId);
    var ownership = await _mirrors.all();
    // Adopt existing ids written before ownership was tracked (including
    // a recurrence successor that inherited its predecessor's event).
    for (final i in await _items.withCalendarEventId()) {
      if (ownership.any((o) => o.eventId == i.calendarEventId)) continue;
      await _mirrors.record(
        itemId: i.id,
        calendarId: calendarId,
        eventId: i.calendarEventId!,
      );
      ownership = await _mirrors.all();
    }

    var written = 0;
    var failedWrites = 0;
    final seen = <String>{};
    for (final snapshot in (await _items.allActive()).where(_qualifies)) {
      if (!shouldContinue()) break;
      // Edits/deletion made during native calendar writes take precedence.
      final i = await _items.getById(snapshot.id);
      if (i == null || !_qualifies(i)) continue;
      // A series may briefly have multiple live instances. Deduplicate its
      // inherited id even when switching calendars creates a replacement id.
      if (i.calendarEventId != null && !seen.add(i.calendarEventId!)) continue;
      ownership = await _mirrors.all();
      final matches = ownership
          .where(
            (o) =>
                (o.itemId == i.id || o.eventId == i.calendarEventId) &&
                o.isCurrent,
          )
          .toList();
      final old = matches.isEmpty ? null : matches.first;
      final previousId = old?.calendarId == calendarId ? old!.eventId : null;
      String? eventId;
      try {
        eventId = await _gateway.upsertEvent(
          CalendarEventDraft(
            calendarId: calendarId,
            id: previousId,
            title: '$tagPrefix${i.title}',
            description: i.notes,
            start: i.dueAt!,
            end: i.dueAt!.add(const Duration(hours: 1)),
            recurrence: calendarRecurrenceOf(i),
          ),
        );
      } catch (_) {
        failedWrites++;
        continue;
      }
      if (eventId == null) {
        failedWrites++;
        continue;
      }
      written++;
      seen.add(eventId);
      await _mirrors.record(
        itemId: i.id,
        calendarId: calendarId,
        eventId: eventId,
        replacingEventId: i.calendarEventId,
      );
    }

    var removed = 0;
    var pending = 0;
    for (final row in await _mirrors.all()) {
      if (!shouldContinue()) break;
      // Re-read before cleanup so a newly-created recurrence successor can
      // claim its predecessor's event even if completion overlapped the run.
      final live = (await _items.allActive())
          .where((i) => _qualifies(i) && i.calendarEventId == row.eventId)
          .toList();
      if (live.isNotEmpty) {
        final owner = live.firstWhere(
          (i) => i.id == row.itemId,
          orElse: () => live.first,
        );
        if (owner.id != row.itemId || !row.isCurrent) {
          await _mirrors.record(
            itemId: owner.id,
            calendarId: row.calendarId,
            eventId: row.eventId,
          );
        }
        for (final stale in await _items.withCalendarEventId()) {
          if (stale.calendarEventId == row.eventId && !_qualifies(stale)) {
            await _items.setCalendarEventId(stale.id, null);
          }
        }
        continue;
      }
      var ok = false;
      try {
        ok = await _gateway.deleteEvent(
          calendarId: row.calendarId,
          eventId: row.eventId,
        );
      } catch (_) {
        // Permission/provider outages retain ownership for the next run.
      }
      if (ok) {
        await _mirrors.forget(row);
        removed++;
      } else {
        pending++;
      }
    }
    return MirrorOutResult(
      written: written,
      removed: removed,
      pendingRemovals: pending,
      failedWrites: failedWrites,
    );
  }

  /// Remove only recorded native events, preserving failed ownership for retry.
  /// Shares the mirror queue so disconnect cannot race a slow publication.
  Future<MirrorOutResult> removeOwned({required String calendarId}) async {
    final previous = _mirrorTail;
    final done = Completer<void>();
    _mirrorTail = done.future;
    try {
      await previous;
      await _mirrors.bindLegacyCalendar(calendarId);
      // Include old installs whose event pointers predate the ownership ledger.
      final owned = await _mirrors.all();
      for (final item in await _items.withCalendarEventId()) {
        if (!owned.any((o) => o.eventId == item.calendarEventId)) {
          await _mirrors.record(
            itemId: item.id,
            calendarId: calendarId,
            eventId: item.calendarEventId!,
          );
        }
      }
      var removed = 0;
      var pending = 0;
      for (final row in await _mirrors.all()) {
        var ok = false;
        try {
          ok = await _gateway.deleteEvent(
            calendarId: row.calendarId,
            eventId: row.eventId,
          );
        } catch (_) {
          // Keep ownership so permission/provider failures can be retried.
        }
        if (ok) {
          await _mirrors.forget(row);
          removed++;
        } else {
          pending++;
        }
      }
      return MirrorOutResult(
        written: 0,
        removed: removed,
        pendingRemovals: pending,
      );
    } finally {
      done.complete();
    }
  }

  Future<int> ownedCount() async {
    final rows = await _mirrors.all();
    final legacyIds = (await _items.withCalendarEventId())
        .map((i) => i.calendarEventId!)
        .where((id) => !rows.any((r) => r.eventId == id))
        .toSet();
    return rows.length + legacyIds.length;
  }

  Future<int> scheduledCount() async =>
      (await _items.allActive()).where(_qualifies).length;

  String _importId(String calendarId, CalendarEventView event) =>
      '$importedIdPrefix${sha256.convert(utf8.encode(jsonEncode([calendarId, event.id, event.start?.toUtc().toIso8601String()])))}';

  /// One-time copies, separate from publishing. Recurring occurrences have
  /// distinct identities; owned events and previously imported events are omitted.
  Future<List<CalendarEventView>> importCandidates({
    required String calendarId,
  }) async {
    final now = _clock.now();
    final events = await _gateway.eventsInRange(
      calendarId: calendarId,
      from: now.subtract(const Duration(days: 7)),
      to: now.add(const Duration(days: 365)),
    );
    final ownership = await _mirrors.all();
    final candidates = <CalendarEventView>[];
    final seen = <String>{};
    for (final event in events) {
      final key = _importId(calendarId, event);
      if (!seen.add(key)) continue;
      if (ownership.any(
        (o) => o.calendarId == calendarId && o.eventId == event.id,
      )) {
        continue;
      }
      if (await _items.getById(key) != null ||
          await _items.getById('$importedIdPrefix${event.id}') != null) {
        continue;
      }
      candidates.add(event);
    }
    candidates.sort((a, b) => (a.start ?? now).compareTo(b.start ?? now));
    return candidates;
  }

  Future<int> importSelected({
    required String calendarId,
    required List<CalendarEventView> events,
    required bool toInbox,
  }) async {
    var imported = 0;
    for (final event in events) {
      final id = _importId(calendarId, event);
      if (await _items.getById(id) != null) continue;
      final now = _clock.now();
      await _items.upsert(
        Item(
          id: id,
          title: event.title,
          status: toInbox ? ItemStatus.inbox : ItemStatus.calendar,
          dueAt: event.start,
          createdAt: now,
          updatedAt: now,
        ),
      );
      imported++;
    }
    return imported;
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
            RegExp(RegExp.escape(importPrefix), caseSensitive: false),
            '',
          )
          .trim();
      final id = '$importedIdPrefix${e.id}';
      if (await _items.getById(id) != null) continue; // already imported
      final ts = _clock.now();
      await _items.upsert(
        Item(
          id: id,
          title: cleaned.isEmpty ? '(untitled calendar event)' : cleaned,
          status: ItemStatus.calendar,
          dueAt: e.start,
          createdAt: ts,
          updatedAt: ts,
        ),
      );
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
    mirrors: ref.watch(calendarMirrorRepositoryProvider),
  ),
);
