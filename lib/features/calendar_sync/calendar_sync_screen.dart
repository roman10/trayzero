import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/calendar_connection_controller.dart';
import '../../application/calendar_sync_service.dart';
import '../../core/calendar_gateway.dart';
import '../../core/system_settings.dart';
import '../../l10n/gen/app_localizations.dart';

class CalendarSyncScreen extends ConsumerStatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  ConsumerState<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends ConsumerState<CalendarSyncScreen>
    with WidgetsBindingObserver {
  bool _choosing = false;
  bool _returningFromSettings = false;
  bool _importing = false;
  bool _restoring = false;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(calendarConnectionProvider.notifier).resume();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _returningFromSettings) {
      _returningFromSettings = false;
      ref.read(calendarConnectionProvider.notifier).updateNow();
    }
  }

  Future<void> _openSettings() async {
    _returningFromSettings = true;
    try {
      if (await ref.read(systemSettingsProvider).openAppSettings()) return;
    } catch (_) {
      // Present a recovery message without exposing provider internals.
    }
    _returningFromSettings = false;
    if (mounted) {
      setState(
        () =>
            _actionError = AppLocalizations.of(context).calendarSettingsFailed,
      );
    }
  }

  Future<void> _restoreAccess() async {
    if (_restoring) return;
    setState(() {
      _restoring = true;
      _actionError = null;
    });
    try {
      if (await ref.read(calendarSyncServiceProvider).requestPermissions()) {
        if (!mounted) return;
        await ref.read(calendarConnectionProvider.notifier).updateNow();
      } else if (mounted) {
        await _openSettings();
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _actionError = AppLocalizations.of(context).calendarLookupFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _chooseCalendar() async {
    setState(() {
      _choosing = true;
      _actionError = null;
    });
    try {
      final service = ref.read(calendarSyncServiceProvider);
      if (!await service.requestPermissions()) {
        if (mounted) {
          setState(
            () => _actionError = AppLocalizations.of(
              context,
            ).calendarPermissionHelp,
          );
        }
        return;
      }
      final calendars = (await service.listCalendars())
          .where((c) => c.writable)
          .toList();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (calendars.isEmpty) {
        setState(() => _actionError = l10n.calendarNoWritable);
        return;
      }
      final count = await service.scheduledCount();
      if (!mounted) return;
      final changing = ref.read(calendarConnectionProvider).settings.connected;
      setState(() => _choosing = false);
      final selected = await showDialog<CalendarInfo>(
        context: context,
        builder: (context) => _CalendarPicker(
          calendars: calendars,
          count: count,
          changing: changing,
        ),
      );
      if (selected == null || !mounted) return;
      setState(() => _choosing = true);
      await ref.read(calendarConnectionProvider.notifier).connect(selected);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _actionError = AppLocalizations.of(context).calendarLookupFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _choosing = false);
    }
  }

  Future<void> _disconnect() async {
    final state = ref.read(calendarConnectionProvider);
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => _DisconnectDialog(count: state.linkedCount),
    );
    if (remove != null && mounted) {
      await ref
          .read(calendarConnectionProvider.notifier)
          .disconnect(removeEvents: remove);
    }
  }

  Future<void> _manage() async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.calendarManage),
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
              ),
              if (!ref.read(calendarConnectionProvider).settings.removing)
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(l10n.calendarChangeDestination),
                  onTap: () => Navigator.pop(context, 'change'),
                ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.calendarHowItWorks),
                onTap: () => Navigator.pop(context, 'rules'),
              ),
              ListTile(
                leading: const Icon(Icons.link_off),
                title: Text(l10n.calendarDisconnect),
                onTap: () => Navigator.pop(context, 'disconnect'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'change':
        await _chooseCalendar();
      case 'disconnect':
        await _disconnect();
      case 'rules':
        await showDialog<void>(
          context: context,
          builder: (context) => _CalendarDialog(
            title: Text(l10n.calendarHowItWorks),
            content: Text(l10n.calendarRules),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.done),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _import() async {
    setState(() {
      _importing = true;
      _actionError = null;
    });
    try {
      final service = ref.read(calendarSyncServiceProvider);
      if (!await service.requestPermissions()) {
        if (mounted) {
          setState(
            () => _actionError = AppLocalizations.of(
              context,
            ).calendarPermissionHelp,
          );
        }
        return;
      }
      final calendars = await service.listCalendars();
      if (!mounted) return;
      if (calendars.isEmpty) {
        setState(
          () =>
              _actionError = AppLocalizations.of(context).noCalendarsAvailable,
        );
        return;
      }
      setState(() => _importing = false);
      final source = await showDialog<CalendarInfo>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text(AppLocalizations.of(context).calendarImportSource),
          children: [
            for (final c in calendars)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, c),
                child: Text(c.displayName),
              ),
          ],
        ),
      );
      if (source == null) return;
      if (!mounted) return;
      setState(() => _importing = true);
      final candidates = await service.importCandidates(calendarId: source.id);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (candidates.isEmpty) {
        setState(() => _actionError = l10n.calendarNoImportEvents);
        return;
      }
      setState(() => _importing = false);
      final choice = await showDialog<_ImportChoice>(
        context: context,
        builder: (context) => _ImportPicker(events: candidates),
      );
      if (choice == null || !mounted) return;
      setState(() => _importing = true);
      final count = await service.importSelected(
        calendarId: source.id,
        events: choice.events,
        toInbox: choice.toInbox,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importInSuccess(count))));
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _actionError = AppLocalizations.of(context).calendarImportFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(calendarConnectionProvider);
    final settings = state.settings;
    final busy = state.busy || _choosing || _importing || _restoring;
    final controller = ref.read(calendarConnectionProvider.notifier);
    final String status;
    if (settings.removing) {
      status = l10n.calendarRemovalPending;
    } else if (state.issue != null) {
      status = l10n.calendarNeedsAttention;
    } else if (!settings.automatic) {
      status = l10n.calendarPaused;
    } else {
      status = l10n.calendarConnected;
    }
    final String? issue = switch (state.issue) {
      CalendarConnectionIssue.permission => l10n.calendarAccessDenied,
      CalendarConnectionIssue.calendarMissing =>
        l10n.calendarSelectionUnavailable,
      CalendarConnectionIssue.updateFailed => l10n.calendarUpdateFailed,
      CalendarConnectionIssue.removalFailed => l10n.calendarRemoveFailed(
        state.linkedCount,
      ),
      CalendarConnectionIssue.storage => l10n.calendarSaveFailed,
      null => null,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarConnectionTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.calendarTogether,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.calendarConnectionIntro),
                  ],
                ),
              ),
              _ConnectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!settings.connected) ...[
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(Icons.calendar_month_outlined, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.calendarConnect,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.calendarScope),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: busy ? null : _chooseCalendar,
                        icon: const Icon(Icons.add_link),
                        label: Text(l10n.calendarConnect),
                      ),
                      if (issue != null) _Notice(text: issue, error: true),
                    ] else ...[
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Text(
                            l10n.calendarConnectionTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Semantics(
                            container: true,
                            liveRegion: true,
                            child: Text(
                              status,
                              style: TextStyle(
                                color: state.issue == null
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.calendar_month_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              settings.calendarName ?? l10n.targetCalendar,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      if (!settings.removing)
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.calendarAutomatic),
                          subtitle: Text(l10n.calendarAutomaticHelp),
                          value: settings.automatic,
                          onChanged: busy ? null : controller.setAutomatic,
                        ),
                      if (!settings.automatic && !settings.removing)
                        _Notice(text: l10n.calendarPauseHelp),
                      const SizedBox(height: 12),
                      Text(l10n.calendarLinkedCount(state.linkedCount)),
                      if (settings.lastSuccess != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.calendarLastUpdated(
                            DateFormat.yMMMd(
                              l10n.localeName,
                            ).add_jm().format(settings.lastSuccess!.toLocal()),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (state.pending && !settings.removing) ...[
                        const SizedBox(height: 4),
                        Text(l10n.calendarChangesWaiting),
                      ],
                      if (issue != null) _Notice(text: issue, error: true),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : state.issue ==
                                      CalendarConnectionIssue.permission
                                ? _restoreAccess
                                : controller.updateNow,
                            icon: const Icon(Icons.sync),
                            label: Text(
                              state.issue == CalendarConnectionIssue.permission
                                  ? l10n.calendarRestoreAccess
                                  : settings.removing
                                  ? l10n.retry
                                  : l10n.calendarUpdateNow,
                            ),
                          ),
                          TextButton(
                            onPressed: busy ? null : _manage,
                            child: Text(l10n.calendarManage),
                          ),
                        ],
                      ),
                    ],
                    if (busy) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        l10n.calendarWorking,
                        semanticsLabel: l10n.calendarWorking,
                      ),
                    ],
                  ],
                ),
              ),
              if (_actionError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Notice(text: _actionError!, error: true),
                      Wrap(
                        spacing: 16,
                        children: [
                          TextButton(
                            onPressed: busy ? null : _openSettings,
                            child: Text(l10n.calendarOpenSettings),
                          ),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => setState(() => _actionError = null),
                            child: Text(l10n.done),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              _ConnectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.calendarBringEvents,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.calendarImportCopies),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: busy ? null : _import,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(l10n.calendarChooseEvents),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  l10n.calendarDeviceHelp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: error
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
    child: Semantics(
      container: true,
      liveRegion: error,
      child: Text(
        text,
        style: TextStyle(
          color: error
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
  );
}

/// Keep title, choices and actions in one scrollable surface. Standard
/// AlertDialog can exhaust its height on translated titles at 3x text.
class _CalendarDialog extends StatelessWidget {
  const _CalendarDialog({
    required this.title,
    required this.content,
    required this.actions,
  });
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  namesRoute: true,
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: title,
                  ),
                ),
                const SizedBox(height: 16),
                content,
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CalendarPicker extends StatefulWidget {
  const _CalendarPicker({
    required this.calendars,
    required this.count,
    required this.changing,
  });
  final List<CalendarInfo> calendars;
  final int count;
  final bool changing;
  @override
  State<_CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<_CalendarPicker> {
  CalendarInfo? _selected;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CalendarDialog(
      title: Text(
        widget.changing
            ? l10n.calendarChangeDestination
            : l10n.calendarChooseDestination,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.changing ? l10n.calendarMoveHelp : l10n.calendarScope),
            const SizedBox(height: 16),
            DropdownButtonFormField<CalendarInfo>(
              itemHeight: null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.targetCalendar,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final c in widget.calendars)
                  DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (c) => setState(() => _selected = c),
            ),
            _Notice(text: l10n.calendarSetupCount(widget.count)),
            const SizedBox(height: 12),
            Text(l10n.calendarAutomaticHelp),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          child: Text(
            widget.changing
                ? l10n.calendarMoveEvents
                : l10n.calendarConnectAndAdd,
          ),
        ),
      ],
    );
  }
}

class _DisconnectDialog extends StatefulWidget {
  const _DisconnectDialog({required this.count});
  final int count;
  @override
  State<_DisconnectDialog> createState() => _DisconnectDialogState();
}

class _DisconnectDialogState extends State<_DisconnectDialog> {
  bool _remove = false;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CalendarDialog(
      title: Text(l10n.calendarDisconnectQuestion),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.calendarDisconnectHelp),
          const SizedBox(height: 12),
          RadioGroup<bool>(
            groupValue: _remove,
            onChanged: (v) => setState(() => _remove = v ?? false),
            child: Column(
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text(l10n.calendarKeepEvents),
                  subtitle: Text(l10n.calendarKeepHelp),
                ),
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  title: Text(l10n.calendarRemoveEvents(widget.count)),
                  subtitle: Text(l10n.calendarRemoveHelp),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _remove),
          child: Text(l10n.calendarDisconnect),
        ),
      ],
    );
  }
}

class _ImportChoice {
  const _ImportChoice(this.events, this.toInbox);
  final List<CalendarEventView> events;
  final bool toInbox;
}

class _ImportPicker extends StatefulWidget {
  const _ImportPicker({required this.events});
  final List<CalendarEventView> events;
  @override
  State<_ImportPicker> createState() => _ImportPickerState();
}

class _ImportPickerState extends State<_ImportPicker> {
  final _selected = <CalendarEventView>{};
  bool _toInbox = true;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CalendarDialog(
      title: Text(l10n.calendarChooseEvents),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.calendarImportCopies),
            for (final e in widget.events)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.title),
                subtitle: e.start == null
                    ? null
                    : Text(
                        DateFormat.yMMMd(
                          l10n.localeName,
                        ).add_jm().format(e.start!.toLocal()),
                      ),
                value: _selected.contains(e),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selected.add(e);
                  } else {
                    _selected.remove(e);
                  }
                }),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<bool>(
              initialValue: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.calendarImportDestination,
              ),
              items: [
                DropdownMenuItem(value: true, child: Text(l10n.inbox)),
                DropdownMenuItem(value: false, child: Text(l10n.calendar)),
              ],
              onChanged: (v) => setState(() => _toInbox = v ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  _ImportChoice(_selected.toList(), _toInbox),
                ),
          child: Text(l10n.calendarAddSelected(_selected.length)),
        ),
      ],
    );
  }
}
