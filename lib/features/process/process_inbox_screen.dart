import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/maybe_request_app_review.dart';
import '../../application/providers.dart';
import '../../application/process_inbox_decision.dart';
import '../../core/clock.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/adaptive_workspace.dart';
import '../common/empty_state.dart';
import '../common/localized_entity_labels.dart';
import '../common/reminder_delivery_recovery.dart';
import '../common/tag_picker.dart';
import '../common/undo_snack_bar.dart';
import '../projects/project_picker.dart';
import '../settings/settings_controller.dart';
import 'process_inbox_controller.dart';
import 'step_cards.dart';

/// The Process Inbox flow — a card-stack walking each captured item through
/// GTD's clarify decision tree. State lives in [ProcessInboxController];
/// terminal decisions go through the [ProcessInboxDecisionUseCase] so the
/// "save → schedule reminders" wiring lives in one place.
class ProcessInboxScreen extends ConsumerStatefulWidget {
  const ProcessInboxScreen({super.key});

  @override
  ConsumerState<ProcessInboxScreen> createState() => _ProcessInboxScreenState();
}

/// Items a session must clarify before Inbox Zero counts as a success
/// moment for the store-rating prompt (ADR 0007).
const _reviewPromptMinProcessed = 5;

class _ProcessInboxScreenState extends ConsumerState<ProcessInboxScreen> {
  bool _askedForReview = false;

  void _haptic([HapticFeedbackKind k = HapticFeedbackKind.selection]) {
    final on = ref.read(hapticsEnabledProvider);
    if (!on) return;
    switch (k) {
      case HapticFeedbackKind.selection:
        HapticFeedback.selectionClick();
      case HapticFeedbackKind.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackKind.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackKind.heavy:
        HapticFeedback.heavyImpact();
    }
  }

  Future<void> _createProjectInline(ProcessInboxController controller) async {
    final project = await showNewProjectSheet(context, ref);
    if (project == null) return;
    controller.setSelectedProject(project.id);
  }

  /// True while a decision is being saved: the step buttons ignore taps so a
  /// double tap can't file (or trash) the same item twice.
  bool _busy = false;

  Future<void> _decide(Item current, ProcessingDecision d) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(processInboxControllerProvider.notifier);
    final purge = ref.read(purgeTrashProvider);
    setState(() => _busy = true);
    final String? spawnedId;
    try {
      spawnedId = await controller.decide(current, d);
    } catch (_) {
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.saveError)));
        setState(() => _busy = false);
      }
      return;
    }
    if (!mounted) {
      // Left the screen mid-save: no Undo to offer, so finish a trash now.
      if (d is TrashDecision) await purge(ids: [current.id]);
      return;
    }
    setState(() => _busy = false);
    // Every decision but Convert-to-Project can be taken back: the item goes
    // back to the inbox exactly as it was. (Undoing a Project conversion
    // would also have to unwind the Project row it created.)
    messenger.hideCurrentSnackBar();
    final bar = messenger.showSnackBar(
      undoSnackBar(
        context,
        message: switch (d) {
          TrashDecision() => l10n.deletedItemsSnackbar(1),
          DoItNowDecision() => l10n.completed,
          _ => l10n.processFiledSnackbar,
        },
        onUndo: d.isUndoable
            ? () => controller.undoDecision(
                current,
                d,
                spawnedRecurrenceId: spawnedId,
              )
            : null,
      ),
    );
    if (d is TrashDecision) {
      // The trashed row is only hard-deleted once Undo is no longer possible.
      unawaited(
        bar.closed
            .then((reason) async {
              if (reason != SnackBarClosedReason.action) {
                await purge(ids: [current.id]);
              }
            })
            .catchError((Object _) {}),
      );
    }
    final now = ref.read(clockProvider).now();
    final needsReminderCheck = switch (d) {
      ToCalendarDecision(:final deferUntil) =>
        (deferUntil ?? current.dueAt)?.isAfter(now) ?? false,
      ToNextActionDecision(:final deferUntil) =>
        deferUntil?.isAfter(now) ?? false,
      _ => false,
    };
    if (needsReminderCheck && mounted) {
      await ensureReminderDeliveryReachable(context, ref);
    }
    _haptic(switch (d) {
      TrashDecision() => HapticFeedbackKind.light,
      DoItNowDecision() => HapticFeedbackKind.medium,
      _ => HapticFeedbackKind.medium,
    });
  }

  /// Inbox Zero after a real processing session is a success moment; the
  /// policy decides whether to actually ask for a store rating (ADR 0007).
  void _maybeAskForReview() {
    if (_askedForReview) return;
    final s = ref.read(processInboxControllerProvider);
    final empty = ref.read(inboxItemsProvider).valueOrNull?.isEmpty ?? false;
    if (!empty || s.filed + s.doneNow + s.trashed < _reviewPromptMinProcessed) {
      return;
    }
    _askedForReview = true;
    unawaited(
      ref.read(maybeRequestAppReviewProvider).call(ReviewMoment.inboxZero),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The inbox stream and the session tally update in either order, so
    // check whenever either changes.
    ref.listen(inboxItemsProvider, (_, _) => _maybeAskForReview());
    ref.listen(processInboxControllerProvider, (_, _) => _maybeAskForReview());
    final items = ref.watch(inboxItemsProvider).valueOrNull ?? const [];
    final state = ref.watch(processInboxControllerProvider);
    final controller = ref.read(processInboxControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.processTitle)),
        body: EmptyState(
          icon: Icons.celebration_outlined,
          title: l10n.processCompleteTitle,
          message: state.filed + state.doneNow + state.trashed == 0
              ? l10n.processCompleteNoItems
              : l10n.processCompleteStats(
                  state.filed,
                  state.doneNow,
                  state.trashed,
                ),
          action: FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.back),
          ),
        ),
      );
    }

    final current = items.first;
    final stepNumber = state.stepIndex + 1;
    return Scaffold(
      appBar: AppBar(
        leading: state.canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.previousStepTooltip,
                onPressed: controller.back,
              )
            : null,
        title: Text(l10n.processTitle),
        actions: [
          IconButton(
            tooltip: l10n.skipItemTooltip,
            icon: const Icon(Icons.skip_next),
            onPressed: () async {
              await controller.skip(current);
              _haptic();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: stepNumber / processStepCount,
            minHeight: 3,
          ),
        ),
      ),
      body: SafeArea(
        child: AdaptiveWorkbench(
          key: ValueKey((current.id, state.step)),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          primary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(l10n.processStepCounter(stepNumber, processStepCount)),
                  Text(l10n.processItemsRemaining(items.length)),
                ],
              ),
              const SizedBox(height: 12),
              CapturedCard(item: current, key: ValueKey(current.id)),
            ],
          ),
          detail: AbsorbPointer(
            absorbing: _busy,
            child: _buildStep(state, current),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(ProcessInboxState state, Item current) {
    final controller = ref.read(processInboxControllerProvider.notifier);
    switch (state.step) {
      case ProcessStep.actionable:
        return StepActionable(
          onYes: controller.advance,
          onReference: () => _decide(current, const ReferenceDecision()),
          onSomeday: () => _decide(current, const SomedayDecision()),
          onTrash: () => _decide(current, const TrashDecision()),
        );
      case ProcessStep.twoMin:
        return StepTwoMin(
          onYes: () => _decide(current, const DoItNowDecision()),
          onNo: controller.advance,
        );
      case ProcessStep.delegate:
        final l10n = AppLocalizations.of(context);
        return StepDelegate(
          onYes: () async {
            final who = await _askForText(
              title: l10n.waitingOnPromptTitle,
              hint: l10n.waitingOnPromptHint,
            );
            if (who == null) return;
            await _decide(current, WaitingDecision(who));
          },
          onNo: controller.advance,
        );
      case ProcessStep.singleStep:
        return StepSingleStep(
          onProject: () => _decide(current, const ToProjectDecision()),
          onSingle: controller.advance,
        );
      case ProcessStep.defer:
        final captured = current.deferUntil;
        final capturedDue = current.dueAt;
        return StepDefer(
          // Dates recognized at capture (ADR 0007) become one-tap choices.
          capturedStart: captured,
          capturedDue: capturedDue,
          onUseCapturedStart: captured == null
              ? null
              : () {
                  controller.setDefer(captured);
                  controller.setRecurrence(null);
                  controller.advance();
                },
          onUseCapturedDue: capturedDue == null
              ? null
              : () => _decide(current, const ToCalendarDecision()),
          onCalendar: () async {
            final when = await _pickDateTime();
            if (when == null) return;
            if (!mounted) return;
            final repeat = await _pickRecurrence();
            if (!mounted) return;
            await _decide(
              current,
              ToCalendarDecision(deferUntil: when, recurrence: repeat),
            );
          },
          onSetDefer: () async {
            final when = await _pickDate();
            if (when == null) return;
            if (!mounted) return;
            final repeat = await _pickRecurrence();
            if (!mounted) return;
            controller.setDefer(when);
            controller.setRecurrence(repeat);
            controller.advance();
          },
          // "Do it ASAP" files a next action with no date anchor, so any
          // cadence picked on the defer branch before backing out here can
          // never apply — drop it so it doesn't ride along into the file.
          // It also drops a defer date, picked earlier or captured, because
          // ASAP means available now.
          onSkip: () {
            controller.setDefer(null);
            controller.setRecurrence(null);
            controller.advance();
          },
        );
      case ProcessStep.detail:
        return StepDetail(
          contexts: ref.watch(contextsProvider).valueOrNull ?? const [],
          projects: ref.watch(activeProjectsProvider).valueOrNull ?? const [],
          selectedContextId: state.selectedContextId,
          selectedProjectId: state.selectedProjectId,
          energy: state.energy,
          timeEstimate: state.timeEstimate,
          deferUntil: state.defer,
          recurrence: state.recurrence,
          onContext: controller.setSelectedContext,
          onProject: controller.setSelectedProject,
          onCreateProject: () => _createProjectInline(controller),
          onEnergy: controller.setEnergy,
          onTime: controller.setTimeEstimate,
          onConfirm: () => _decide(
            current,
            ToNextActionDecision(
              contextId: state.selectedContextId,
              energy: state.energy,
              timeEstimateMinutes: state.timeEstimate,
              projectId: state.selectedProjectId,
              deferUntil: state.defer,
              recurrence: state.recurrence,
            ),
          ),
          onBack: controller.back,
          tags: (ref.watch(tagsProvider).valueOrNull ?? const []).isEmpty
              ? null
              : ItemTagsField(itemId: current.id),
        );
    }
  }

  Future<String?> _askForText({required String title, required String hint}) =>
      showDialog<String>(
        context: context,
        builder: (_) => _AskTextDialog(title: title, hint: hint),
      );

  /// Date-only defer (GTD tickler). Returns local start-of-day so the item
  /// is visible in Next Actions for the whole target day; the "Ready:"
  /// reminder hour is decided separately at save time
  /// (see `deferReminderAt` / `deferSurfaceMinutesProvider`).
  Future<DateTime?> _pickDate() async {
    final now = ref.read(clockProvider).now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDate: now,
    );
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }

  /// Quick cadence pick shown right after a date is set on the calendar /
  /// defer-until paths — the only triage branches that establish the date
  /// anchor recurrence requires. Returns null for a one-off (also the
  /// result of dismissing the sheet, the safe default); advanced tuning
  /// (interval, weekdays, end condition) stays in the item editor.
  Future<Recurrence?> _pickRecurrence() {
    return showModalBottomSheet<Recurrence?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final l10n = AppLocalizations.of(sheetContext);
        ListTile option(String label, IconData icon, Recurrence? value) =>
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              onTap: () => Navigator.pop(sheetContext, value),
            );
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.recurrencePrompt,
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                option(l10n.recurrenceOff, Icons.block, null),
                for (final r in Recurrence.values)
                  option(r.localizedLabel(l10n), Icons.repeat, r),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime() async {
    final now = ref.read(clockProvider).now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDate: now,
    );
    if (date == null) return null;
    if (!mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

enum HapticFeedbackKind { selection, light, medium, heavy }

/// Single-field prompt. OK stays disabled until something is typed, so it
/// never closes the dialog without a result.
class _AskTextDialog extends StatefulWidget {
  const _AskTextDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_AskTextDialog> createState() => _AskTextDialogState();
}

class _AskTextDialogState extends State<_AskTextDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint),
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty ? null : _submit,
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
