import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/notification_scheduler.dart';
import '../../domain/entities/entities.dart';
import '../../domain/item_invariants.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/error_view.dart';
import '../common/exact_alarm_permission_recovery.dart';
import '../common/notification_permission_recovery.dart';
import '../common/localized_entity_labels.dart';
import '../common/localized_recurrence.dart';
import '../common/undo_snack_bar.dart';
import '../common/tag_picker.dart';
import 'attachments_section.dart';
import 'item_edit_controller.dart';
import 'recurrence_section.dart';
import 'sections.dart';

class ItemEditScreen extends ConsumerStatefulWidget {
  const ItemEditScreen({required this.itemId, this.leading, super.key});
  final String itemId;
  final Widget? leading;

  @override
  ConsumerState<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends ConsumerState<ItemEditScreen> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _waitingOn;
  late final FocusNode _titleFocus;
  late final FocusNode _notesFocus;
  late final FocusNode _waitingFocus;
  bool _controllersSeeded = false;
  bool _justSaved = false;
  bool _remindersWarned = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _notes = TextEditingController();
    _waitingOn = TextEditingController();
    _titleFocus = FocusNode()..addListener(_onFocusChange);
    _notesFocus = FocusNode()..addListener(_onFocusChange);
    _waitingFocus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _title.dispose();
    _notes.dispose();
    _waitingOn.dispose();
    _titleFocus.dispose();
    _notesFocus.dispose();
    _waitingFocus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_titleFocus.hasFocus &&
        !_notesFocus.hasFocus &&
        !_waitingFocus.hasFocus) {
      _commit();
    }
  }

  void _scheduleDebouncedCommit() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _commit);
  }

  Future<void> _commit({bool propagateError = false}) async {
    final bool wrote;
    try {
      wrote = await ref
          .read(itemEditControllerProvider(widget.itemId).notifier)
          .commit();
    } catch (_) {
      if (propagateError) rethrow;
      if (!mounted) return;
      setState(() => _justSaved = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.saveError),
            action: SnackBarAction(
              label: l10n.retry,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                unawaited(_commit());
              },
            ),
          ),
        );
      return;
    }
    if (!mounted || !wrote) return;
    setState(() => _justSaved = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSaved = false);
    });
    await _warnIfRemindersBlocked();
  }

  /// If the item now carries a future reminder but Android / iOS would block
  /// delivery, surface it once per screen visit with a one-tap recovery.
  Future<void> _warnIfRemindersBlocked() async {
    if (_remindersWarned) return;
    final item = ref
        .read(itemEditControllerProvider(widget.itemId))
        .valueOrNull;
    if (item == null) return;
    final now = ref.read(clockProvider).now();
    final hasFutureReminder =
        (item.dueAt?.isAfter(now) ?? false) ||
        (item.deferUntil?.isAfter(now) ?? false);
    if (!hasFutureReminder) return;
    // Fail open: a read error defaults to granted so we never false-nag.
    final status =
        (await ref.read(checkNotificationPermissionProvider).call())
            .valueOrNull ??
        NotificationPermission.granted;
    if (!mounted) return;
    if (status != NotificationPermission.granted) {
      _remindersWarned = true;
      final blocked = status == NotificationPermission.permanentlyDenied;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              blocked ? l10n.remindersBlockedWarning : l10n.remindersOffWarning,
            ),
            duration: const Duration(seconds: 6),
            // Action snackbars otherwise persist for everyone. Keep recovery
            // available without a timeout when screen-reader navigation is on.
            persist: MediaQuery.accessibleNavigationOf(context),
            action: SnackBarAction(
              label: blocked ? l10n.settings : l10n.enable,
              onPressed: () => runNotificationPermissionRecovery(context, ref),
            ),
          ),
        );
      return;
    }
    if (!Platform.isAndroid) return;
    final exactAllowed =
        (await ref.read(checkExactAlarmPermissionProvider).call())
            .valueOrNull ??
        true;
    if (exactAllowed || !mounted) return;
    _remindersWarned = true;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.preciseReminderOffWarning),
          duration: const Duration(seconds: 6),
          persist: MediaQuery.accessibleNavigationOf(context),
          action: SnackBarAction(
            label: l10n.allowExactAlarms,
            onPressed: () => runExactAlarmPermissionRecovery(context, ref),
          ),
        ),
      );
  }

  void _updateDraft(Item Function(Item) f) {
    ref.read(itemEditControllerProvider(widget.itemId).notifier).updateDraft(f);
  }

  Future<bool> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.deleteItemConfirmTitle),
            content: Text(l10n.deleteItemConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onDelete() async {
    if (!await _confirmDelete() || !mounted) return;
    await ref.read(itemEditControllerProvider(widget.itemId).notifier).delete();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _onComplete() {
    // Resolved before the screen pops: the snackbar outlives this widget.
    final undo = ref.read(undoCompleteProvider);
    final id = widget.itemId;
    String? spawnedId;
    return _runStatusAction(
      (n) async => spawnedId = await n.complete(),
      onError: AppLocalizations.of(context).completeError,
      onSuccess: undoSnackBar(
        context,
        message: AppLocalizations.of(context).completed,
        onUndo: () => undo(id, spawnedRecurrenceId: spawnedId),
      ),
    );
  }

  Future<void> _onReopen() => _runStatusAction(
    (n) => n.reopen(),
    onError: AppLocalizations.of(context).reopenError,
  );

  /// Runs a terminal status change (complete / reopen) and always leaves the
  /// screen — popping on success, or popping with a SnackBar on failure.
  /// This is wired to a synchronous `onPressed`, so an uncaught throw here
  /// would surface as an invisible dead button; never let that happen.
  Future<void> _runStatusAction(
    Future<void> Function(ItemEditController) action, {
    required String onError,
    SnackBar? onSuccess,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _commit(propagateError: true);
      await action(
        ref.read(itemEditControllerProvider(widget.itemId).notifier),
      );
      if (onSuccess != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(onSuccess);
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(onError)));
    }
    if (mounted) navigator.pop();
  }

  void _seedControllers(Item item) {
    if (_controllersSeeded) return;
    _title.text = item.title;
    _notes.text = item.notes ?? '';
    _waitingOn.text = item.waitingOn ?? '';
    _controllersSeeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(itemEditControllerProvider(widget.itemId));
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _commit();
      },
      child: async.when(
        loading: () => Scaffold(
          appBar: widget.leading == null
              ? null
              : AppBar(leading: widget.leading),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => Scaffold(
          appBar: AppBar(leading: widget.leading),
          body: ErrorView(
            error: e,
            stackTrace: st,
            onRetry: () =>
                ref.invalidate(itemEditControllerProvider(widget.itemId)),
          ),
        ),
        data: (item) {
          _seedControllers(item);
          return _ItemEditView(
            leading: widget.leading,
            item: item,
            title: _title,
            notes: _notes,
            waitingOn: _waitingOn,
            titleFocus: _titleFocus,
            notesFocus: _notesFocus,
            waitingFocus: _waitingFocus,
            justSaved: _justSaved,
            onTextChange: _scheduleDebouncedCommit,
            onTitleChanged: (v) => _updateDraft(
              (c) => c.copyWith(title: v.trim().isEmpty ? c.title : v.trim()),
            ),
            onNotesChanged: (v) => _updateDraft(
              (c) => c.copyWith(
                notes: v.trim().isEmpty ? null : v.trim(),
                clearNotes: v.trim().isEmpty,
              ),
            ),
            onWaitingChanged: (v) => _updateDraft(
              (c) => c.copyWith(
                waitingOn: v.trim().isEmpty ? null : v.trim(),
                clearWaitingOn: v.trim().isEmpty,
              ),
            ),
            updateDraft: _updateDraft,
            commitNow: _commit,
            onDelete: _onDelete,
            onComplete: _onComplete,
            onReopen: _onReopen,
          );
        },
      ),
    );
  }
}

class _ItemEditView extends ConsumerWidget {
  const _ItemEditView({
    required this.leading,
    required this.item,
    required this.title,
    required this.notes,
    required this.waitingOn,
    required this.titleFocus,
    required this.notesFocus,
    required this.waitingFocus,
    required this.justSaved,
    required this.onTextChange,
    required this.onTitleChanged,
    required this.onNotesChanged,
    required this.onWaitingChanged,
    required this.updateDraft,
    required this.commitNow,
    required this.onDelete,
    required this.onComplete,
    required this.onReopen,
  });

  final Widget? leading;
  final Item item;
  final TextEditingController title;
  final TextEditingController notes;
  final TextEditingController waitingOn;
  final FocusNode titleFocus;
  final FocusNode notesFocus;
  final FocusNode waitingFocus;
  final bool justSaved;
  final VoidCallback onTextChange;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<String> onWaitingChanged;
  final void Function(Item Function(Item)) updateDraft;
  final Future<void> Function() commitNow;
  final VoidCallback onDelete;
  final VoidCallback onComplete;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final contexts = ref.watch(contextsProvider).valueOrNull ?? const [];
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? const [];
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: Text(l10n.editTitle),
        actions: [
          AnimatedOpacity(
            opacity: justSaved ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Tooltip(
                  message: l10n.savedIndicator,
                  excludeFromSemantics: true,
                  child: Semantics(
                    label: l10n.savedIndicator,
                    liveRegion: true,
                    child: Icon(
                      Icons.check_circle,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.delete),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            TextField(
              controller: title,
              focusNode: titleFocus,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.titleLabel),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (v) {
                onTitleChanged(v);
                onTextChange();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              focusNode: notesFocus,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l10n.notesLabel),
              onChanged: (v) {
                onNotesChanged(v);
                onTextChange();
              },
            ),
            const SizedBox(height: 20),
            SectionHeader(l10n.statusSection),
            StatusSelector(
              current: item.status,
              onChanged: (s) async {
                DateTime? due;
                if (s == ItemStatus.calendar && item.dueAt == null) {
                  due = await pickDateTime(context, ref);
                  if (due == null || !context.mounted) return;
                }
                updateDraft((c) => changeItemStatus(c, s, dueAt: due));
                await commitNow();
              },
            ),
            if (item.status == ItemStatus.nextAction ||
                item.status == ItemStatus.someday) ...[
              const SizedBox(height: 20),
              SectionHeader(l10n.contextSection),
              ContextSelector(
                contexts: contexts,
                currentId: item.contextId,
                onChanged: (id) async {
                  updateDraft(
                    (c) => c.copyWith(contextId: id, clearContext: id == null),
                  );
                  await commitNow();
                },
              ),
              const SizedBox(height: 20),
              SectionHeader(l10n.energySection),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in Energy.values)
                    ChoiceChip(
                      label: Text(switch (e) {
                        Energy.low => l10n.energyLow,
                        Energy.medium => l10n.energyMedium,
                        Energy.high => l10n.energyHigh,
                      }),
                      selected: item.energy == e,
                      onSelected: (sel) async {
                        updateDraft(
                          (c) => c.copyWith(
                            energy: sel ? e : null,
                            clearEnergy: !sel,
                          ),
                        );
                        await commitNow();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SectionHeader(l10n.timeEstimateSection),
              Wrap(
                spacing: 8,
                children: [
                  for (final mins in const [5, 15, 30, 60, 120])
                    ChoiceChip(
                      label: Text(l10n.minutesShort(mins)),
                      selected: item.timeEstimateMinutes == mins,
                      onSelected: (sel) async {
                        updateDraft(
                          (c) => c.copyWith(
                            timeEstimateMinutes: sel ? mins : null,
                            clearTimeEstimate: !sel,
                          ),
                        );
                        await commitNow();
                      },
                    ),
                ],
              ),
            ],
            if (item.status == ItemStatus.waiting) ...[
              const SizedBox(height: 20),
              SectionHeader(l10n.waitingOnSection),
              TextField(
                controller: waitingOn,
                focusNode: waitingFocus,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: l10n.waitingOnHint),
                onChanged: (v) {
                  onWaitingChanged(v);
                  onTextChange();
                },
              ),
            ],
            const SizedBox(height: 20),
            SectionHeader(l10n.projectSection),
            ProjectSelector(
              projects: projects,
              currentId: item.projectId,
              onChanged: (id) async {
                updateDraft(
                  (c) => c.copyWith(projectId: id, clearProject: id == null),
                );
                await commitNow();
              },
            ),
            const SizedBox(height: 8),
            ItemTagsField(itemId: item.id),
            const SizedBox(height: 20),
            SectionHeader(l10n.datesSection),
            // A next action lives off the calendar — its only date anchor is
            // "Defer until" (a tickler). Offering a hard "Due" here would let it
            // accrue a deadline that surfaces nowhere; the persistence layer
            // strips it anyway, so don't present a control that does nothing.
            if (item.status != ItemStatus.nextAction)
              DateTile(
                label: l10n.dueLabel,
                icon: Icons.event,
                value: item.dueAt,
                allowClear: item.status != ItemStatus.calendar,
                onChange: (d) async {
                  updateDraft(
                    (c) => c.copyWith(dueAt: d, clearDueAt: d == null),
                  );
                  await commitNow();
                },
              ),
            DateTile(
              label: l10n.deferUntilLabel,
              icon: Icons.snooze,
              dateOnly: true,
              value: item.deferUntil,
              onChange: (d) async {
                updateDraft(
                  (c) => c.copyWith(deferUntil: d, clearDeferUntil: d == null),
                );
                await commitNow();
              },
            ),
            const SizedBox(height: 20),
            SectionHeader(l10n.repeatSection),
            Builder(
              builder: (_) {
                final hasAnchor = item.dueAt != null || item.deferUntil != null;
                // Hard-block: recurrence shifts the due/defer date forward, so
                // it cannot be turned on without one. An item that already has
                // recurrence (e.g. its date was later cleared) keeps its chips
                // live so the user can still turn it Off — never trapped.
                final canSetRecurrence = hasAnchor || item.recurrence != null;
                return Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.recurrenceOff),
                      selected: item.recurrence == null,
                      onSelected: (_) async {
                        updateDraft((c) => c.copyWith(clearRecurrence: true));
                        await commitNow();
                      },
                    ),
                    for (final r in Recurrence.values)
                      ChoiceChip(
                        label: Text(r.localizedLabel(l10n)),
                        selected: item.recurrence == r,
                        onSelected: canSetRecurrence
                            ? (_) async {
                                updateDraft((c) => c.copyWith(recurrence: r));
                                await commitNow();
                              }
                            : null,
                      ),
                  ],
                );
              },
            ),
            if (item.recurrence == null &&
                item.dueAt == null &&
                item.deferUntil == null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  item.status == ItemStatus.nextAction
                      ? l10n.recurrenceNeedsDeferHint
                      : l10n.recurrenceNeedsDueDateHint,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (item.recurrence != null) ...[
              const SizedBox(height: 12),
              IntervalStepper(
                recurrence: item.recurrence!,
                interval: item.recurrenceInterval,
                onChanged: (n) async {
                  updateDraft((c) => c.copyWith(recurrenceInterval: n));
                  await commitNow();
                },
              ),
              RecurrencePatternEditor(
                recurrence: item.recurrence!,
                byWeekdays: item.recurrenceByWeekdays,
                monthlyWeek: item.recurrenceMonthlyWeek,
                monthlyWeekday: item.recurrenceMonthlyWeekday,
                onWeekdaysChanged: (days) async {
                  updateDraft((c) => c.copyWith(recurrenceByWeekdays: days));
                  await commitNow();
                },
                onDayOfMonth: () async {
                  updateDraft(
                    (c) => c.copyWith(clearRecurrenceMonthlyNth: true),
                  );
                  await commitNow();
                },
                onNthWeekday: (week, weekday) async {
                  updateDraft(
                    (c) => c.copyWith(
                      recurrenceMonthlyWeek: week,
                      recurrenceMonthlyWeekday: weekday,
                    ),
                  );
                  await commitNow();
                },
              ),
              const SizedBox(height: 16),
              RecurrenceEndPicker(
                until: item.recurrenceUntil,
                count: item.recurrenceCount,
                onNever: () async {
                  updateDraft(
                    (c) => c.copyWith(
                      clearRecurrenceUntil: true,
                      clearRecurrenceCount: true,
                    ),
                  );
                  await commitNow();
                },
                onUntil: (d) async {
                  updateDraft(
                    (c) => c.copyWith(
                      recurrenceUntil: d,
                      clearRecurrenceCount: true,
                    ),
                  );
                  await commitNow();
                },
                onCount: (n) async {
                  updateDraft(
                    (c) => c.copyWith(
                      recurrenceCount: n,
                      clearRecurrenceUntil: true,
                    ),
                  );
                  await commitNow();
                },
              ),
              const SizedBox(height: 8),
              if (item.dueAt == null && item.deferUntil == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 16, color: scheme.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.status == ItemStatus.nextAction
                              ? l10n.recurrenceNoDateNextActionError
                              : l10n.recurrenceNoDateError,
                          style: TextStyle(fontSize: 12.5, color: scheme.error),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat, size: 16, color: scheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.localizedRecurrenceSummary(l10n),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.recurrenceExplanation,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            SectionHeader(l10n.attachmentsSection),
            AttachmentsSection(itemId: item.id),
            const SizedBox(height: 20),
            if (item.status != ItemStatus.done)
              OutlinedButton.icon(
                onPressed: onComplete,
                icon: Icon(Icons.check_circle_outline, color: scheme.primary),
                label: Text(l10n.markComplete),
              )
            else
              OutlinedButton.icon(
                onPressed: onReopen,
                icon: Icon(Icons.refresh, color: scheme.primary),
                label: Text(l10n.reopen),
              ),
          ],
        ),
      ),
    );
  }
}
