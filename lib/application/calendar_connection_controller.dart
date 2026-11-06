import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendar_connection.dart';
import '../core/calendar_gateway.dart';
import '../core/clock.dart';
import '../data/mappers.dart';
import '../data/providers.dart';
import '../domain/entities/entities.dart';
import 'calendar_sync_service.dart';

enum CalendarConnectionIssue {
  permission,
  calendarMissing,
  updateFailed,
  removalFailed,
  storage,
}

class CalendarConnectionState {
  const CalendarConnectionState({
    this.settings = const CalendarConnectionSettings(),
    this.busy = false,
    this.pending = false,
    this.issue,
    this.linkedCount = 0,
  });
  final CalendarConnectionSettings settings;
  final bool busy;
  final bool pending;
  final CalendarConnectionIssue? issue;
  final int linkedCount;
}

/// Foreground one-way publication. Configuration, writes and disconnect are
/// serialized; a persisted removal intent can never re-enter publication.
class CalendarConnectionController
    extends StateNotifier<CalendarConnectionState> {
  CalendarConnectionController({
    required CalendarConnectionPreferences preferences,
    required CalendarSyncService sync,
    required CalendarGateway gateway,
    required Clock clock,
    required Stream<String> changes,
  }) : _preferences = preferences,
       _sync = sync,
       _gateway = gateway,
       _clock = clock,
       super(CalendarConnectionState(settings: preferences.load())) {
    _subscription = changes.listen(
      _changed,
      onError: (Object _) {
        if (mounted) {
          _emit(issue: CalendarConnectionIssue.updateFailed, pending: true);
        }
      },
    );
  }

  final CalendarConnectionPreferences _preferences;
  final CalendarSyncService _sync;
  final CalendarGateway _gateway;
  final Clock _clock;
  late final StreamSubscription<String> _subscription;
  Future<void> _tail = Future.value();
  void Function()? _cancel;
  bool _active = true;
  bool _stopping = false;
  String? _fingerprint;
  bool _autoQueued = false;

  void _emit({
    CalendarConnectionSettings? settings,
    bool? busy,
    bool? pending,
    CalendarConnectionIssue? issue,
    int? count,
  }) {
    if (!mounted) return;
    state = CalendarConnectionState(
      settings: settings ?? state.settings,
      busy: busy ?? state.busy,
      pending: pending ?? state.pending,
      issue: issue,
      linkedCount: count ?? state.linkedCount,
    );
  }

  Future<void> _serial(Future<void> Function() action) {
    final next = _tail.then((_) async {
      if (!mounted) return;
      _emit(busy: true, issue: state.issue);
      try {
        await action();
      } catch (_) {
        if (!mounted) return;
        _stopping = !state.settings.automatic || state.settings.removing;
        _emit(issue: CalendarConnectionIssue.storage, pending: true);
      } finally {
        if (mounted) _emit(busy: false, issue: state.issue);
      }
    });
    _tail = next;
    return next;
  }

  Future<void> _save(CalendarConnectionSettings settings) async {
    await _preferences.save(settings);
    if (!mounted) return;
    _emit(settings: settings, issue: state.issue);
  }

  void _changed(String fingerprint) {
    if (!mounted) return;
    if (_fingerprint == fingerprint) return;
    _fingerprint = fingerprint;
    final pending = state.settings.fingerprint != fingerprint;
    _emit(pending: pending, issue: state.issue);
    if (pending) _schedule();
  }

  void _schedule() {
    _cancel?.call();
    _cancel = null;
    if (!_active ||
        _stopping ||
        !state.settings.connected ||
        !state.settings.automatic ||
        state.settings.removing) {
      return;
    }
    _cancel = _clock.scheduleAt(
      _clock.now().add(const Duration(milliseconds: 600)),
      () {
        _cancel = null;
        unawaited(_automaticUpdate());
      },
    );
  }

  Future<void> _automaticUpdate() {
    if (_autoQueued) return _tail;
    _autoQueued = true;
    return _serial(() async {
      try {
        if (_active &&
            !_stopping &&
            state.settings.automatic &&
            state.pending &&
            !state.settings.removing) {
          await _update();
        }
      } finally {
        _autoQueued = false;
      }
    });
  }

  /// Launch/resume verifies native access and reconciles edits made before a
  /// crash. It never presents a permission prompt.
  Future<void> resume() {
    _active = true;
    return _serial(() async {
      if (!state.settings.connected) return;
      final count = await _sync.ownedCount();
      if (!mounted) return;
      _emit(count: count, issue: state.issue);
      if (state.settings.removing) {
        await _remove();
      } else if (state.settings.automatic && !_stopping) {
        await _update();
      }
    });
  }

  void background() {
    _active = false;
    _cancel?.call();
    _cancel = null;
  }

  Future<void> connect(CalendarInfo calendar) => _serial(() async {
    if (!calendar.writable || state.settings.removing) return;
    // Resolve legacy ownership before changing the saved destination.
    final old = state.settings.calendarId;
    final automatic = old == null || state.settings.automatic;
    if (old != null) await _sync.bindLegacyOwnership(calendarId: old);
    await _save(
      CalendarConnectionSettings(
        calendarId: calendar.id,
        calendarName: calendar.displayName,
        automatic: automatic,
      ),
    );
    if (!mounted) return;
    _stopping = !automatic;
    // Moving events is explicit; it must not silently resume a paused link.
    await _update(manual: !automatic);
  });

  Future<void> setAutomatic(bool value) {
    if (!value) {
      _stopping = true;
      _cancel?.call();
    }
    return _serial(() async {
      if (!state.settings.connected || state.settings.removing) return;
      await _save(state.settings.copyWith(automatic: value));
      _stopping = !value;
      if (value) await _update();
    });
  }

  /// An explicit update is available while paused; it does not resume automation.
  Future<void> updateNow() => _serial(() async {
    if (state.settings.removing) {
      await _remove();
    } else {
      await _update(manual: true);
    }
  });

  Future<bool> _checkAccess() async {
    try {
      if (!await _gateway.hasPermissions()) {
        _emit(issue: CalendarConnectionIssue.permission, pending: true);
        return false;
      }
      final calendars = await _gateway.listCalendars();
      if (!mounted) return false;
      if (!calendars.any(
        (c) => c.id == state.settings.calendarId && c.writable,
      )) {
        _emit(issue: CalendarConnectionIssue.calendarMissing, pending: true);
        return false;
      }
      return true;
    } catch (_) {
      _emit(issue: CalendarConnectionIssue.updateFailed, pending: true);
      return false;
    }
  }

  Future<void> _update({bool manual = false}) async {
    if (!mounted) return;
    final settings = state.settings;
    if (!settings.connected || settings.removing) return;
    if (!await _checkAccess()) return;
    final fingerprint = _fingerprint;
    bool allowed() => mounted && (manual || (_active && !_stopping));
    try {
      final result = await _sync.mirrorOut(
        calendarId: settings.calendarId!,
        shouldContinue: allowed,
      );
      if (!mounted) return;
      final count = await _sync.ownedCount();
      if (!allowed()) {
        _emit(pending: true, count: count);
        return;
      }
      if (!result.successful) {
        _emit(
          issue: CalendarConnectionIssue.updateFailed,
          pending: true,
          count: count,
        );
        return;
      }
      await _save(
        settings.copyWith(lastSuccess: _clock.now(), fingerprint: fingerprint),
      );
      if (!mounted) return;
      _emit(pending: _fingerprint != fingerprint, count: count);
      if (state.pending) _schedule();
    } catch (_) {
      _emit(issue: CalendarConnectionIssue.updateFailed, pending: true);
    }
  }

  Future<void> disconnect({required bool removeEvents}) {
    _stopping = true;
    _cancel?.call();
    return _serial(() async {
      if (!state.settings.connected) return;
      if (!removeEvents) {
        // Retain device-local links for a later reconnect without duplicates.
        await _save(const CalendarConnectionSettings());
        _emit(pending: false, count: 0);
      } else {
        // Persist before any deletion. A crash must resume removal, never export.
        await _save(state.settings.copyWith(automatic: false, removing: true));
        await _remove();
      }
    });
  }

  Future<void> _remove() async {
    if (!mounted) return;
    final settings = state.settings;
    if (!settings.removing || settings.calendarId == null) return;
    try {
      if (!await _gateway.hasPermissions()) {
        _emit(issue: CalendarConnectionIssue.permission, pending: true);
        return;
      }
      final result = await _sync.removeOwned(calendarId: settings.calendarId!);
      if (result.pendingRemovals > 0) {
        _emit(
          issue: CalendarConnectionIssue.removalFailed,
          pending: true,
          count: result.pendingRemovals,
        );
      } else {
        await _save(const CalendarConnectionSettings());
        _emit(pending: false, count: 0);
      }
    } catch (_) {
      _emit(issue: CalendarConnectionIssue.removalFailed, pending: true);
    }
  }

  @override
  void dispose() {
    _active = false;
    _stopping = true;
    _cancel?.call();
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

/// Only native-event content participates. Saving native IDs never schedules
/// another publication, and unrelated task edits don't churn calendar writes.
String calendarPublicationFingerprint(List<Item> items) {
  final scheduled =
      items
          .where(
            (i) =>
                i.status == ItemStatus.calendar &&
                i.completedAt == null &&
                i.dueAt != null &&
                !i.id.startsWith(CalendarSyncService.importedIdPrefix),
          )
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
  return sha256
      .convert(
        utf8.encode(
          jsonEncode([
            for (final i in scheduled)
              [
                i.id,
                i.title,
                i.notes,
                i.dueAt!.toIso8601String(),
                i.recurrence?.name,
                i.recurrenceInterval,
                i.recurrenceUntil?.toIso8601String(),
                i.recurrenceCount,
                i.recurrenceDoneCount,
                i.recurrenceByWeekdays,
                i.recurrenceMonthlyWeek,
                i.recurrenceMonthlyWeekday,
              ],
          ]),
        ),
      )
      .toString();
}

final calendarConnectionProvider =
    StateNotifierProvider<
      CalendarConnectionController,
      CalendarConnectionState
    >((ref) {
      final db = ref.watch(databaseProvider);
      return CalendarConnectionController(
        preferences: ref.watch(calendarConnectionPreferencesProvider),
        sync: ref.watch(calendarSyncServiceProvider),
        gateway: ref.watch(calendarGatewayProvider),
        clock: ref.watch(clockProvider),
        changes: db
            .select(db.items)
            .watch()
            .map(
              (rows) => calendarPublicationFingerprint(
                rows.map((r) => r.toEntity()).toList(),
              ),
            )
            .distinct(),
      );
    });
