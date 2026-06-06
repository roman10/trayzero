import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calendar_gateway.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_controller.dart';
import '../../application/calendar_sync_service.dart';

class CalendarSyncScreen extends ConsumerStatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  ConsumerState<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

enum _LoadState { loading, denied, ready }

class _CalendarSyncScreenState extends ConsumerState<CalendarSyncScreen> {
  _LoadState _state = _LoadState.loading;
  List<CalendarInfo> _calendars = const [];
  String? _busyMessage;

  @override
  void initState() {
    super.initState();
    // Deferred a frame so _load()'s synchronous setState doesn't run during
    // initState (the default _state already shows the spinner).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    if (mounted) setState(() => _state = _LoadState.loading);
    final svc = ref.read(calendarSyncServiceProvider);
    final ok = await svc.requestPermissions();
    if (!mounted) return;
    if (!ok) {
      setState(() => _state = _LoadState.denied);
      return;
    }
    final cals = await svc.listCalendars();
    if (!mounted) return;
    setState(() {
      _calendars = cals;
      _state = _LoadState.ready;
    });
  }

  Future<void> _runWith(Future<void> Function() block, String label) async {
    setState(() => _busyMessage = label);
    try {
      await block();
    } finally {
      if (mounted) setState(() => _busyMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(calendarSyncEnabledProvider);
    final calendarId = ref.watch(calendarSyncCalendarIdProvider);
    final svc = ref.watch(calendarSyncServiceProvider);
    final canSync = _state == _LoadState.ready &&
        calendarId != null &&
        _busyMessage == null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarSyncTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.calendarSyncIntro,
            style: const TextStyle(fontSize: 13.5),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(l10n.enableCalendarSync),
            value: enabled,
            onChanged: (v) =>
                ref.read(calendarSyncEnabledProvider.notifier).set(v),
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Text(l10n.targetCalendar,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            switch (_state) {
              _LoadState.loading => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              _LoadState.denied => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.calendarAccessDenied),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.lock_open),
                      label: Text(l10n.grantCalendarAccess),
                    ),
                  ],
                ),
              _LoadState.ready when _calendars.isEmpty => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.noCalendarsAvailable),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              _LoadState.ready => DropdownButtonFormField<String>(
                  initialValue: calendarId,
                  items: [
                    for (final c in _calendars)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => ref
                      .read(calendarSyncCalendarIdProvider.notifier)
                      .set(v),
                ),
            },
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: !canSync
                  ? null
                  : () => _runWith(
                        () async {
                          final r =
                              await svc.mirrorOut(calendarId: calendarId);
                          if (!context.mounted) return;
                          final innerL10n = AppLocalizations.of(context);
                          final msg = r.removed > 0
                              ? innerL10n.mirrorOutSuccessWithStale(
                                  r.written, r.removed)
                              : innerL10n.mirrorOutSuccess(r.written);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        },
                        l10n.mirroringProgress,
                      ),
              icon: const Icon(Icons.upload),
              label: Text(l10n.mirrorOutAction),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: !canSync
                  ? null
                  : () => _runWith(
                        () async {
                          final n = await svc.importIn(calendarId: calendarId);
                          if (!context.mounted) return;
                          final innerL10n = AppLocalizations.of(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(innerL10n.importInSuccess(n)),
                            ),
                          );
                        },
                        l10n.importingProgress,
                      ),
              icon: const Icon(Icons.download),
              label: Text(l10n.importInAction),
            ),
            if (_busyMessage != null) ...[
              const SizedBox(height: 12),
              Center(child: Text(_busyMessage!)),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.calendarSyncTip,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
