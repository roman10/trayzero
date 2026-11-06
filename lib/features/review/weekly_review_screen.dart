import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/maybe_request_app_review.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../domain/project_movement.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/complete_with_undo.dart';
import '../common/adaptive_workspace.dart';
import '../common/error_view.dart';
import '../common/item_card.dart';
import '../common/undo_snack_bar.dart';
import '../common/localized_dates.dart';
import 'weekly_review_controller.dart';

String _stepTitle(AppLocalizations l, WeeklyReviewStep step) => switch (step) {
  WeeklyReviewStep.capture => l.reviewStep1Title,
  WeeklyReviewStep.inbox => l.reviewStep2Title,
  WeeklyReviewStep.actions => l.reviewStep3Title,
  WeeklyReviewStep.waiting => l.reviewStep4Title,
  WeeklyReviewStep.projects => l.reviewStep5Title,
  WeeklyReviewStep.calendar => l.reviewStep6Title,
  WeeklyReviewStep.someday => l.reviewStep7Title,
};
String _stepBody(AppLocalizations l, WeeklyReviewStep step) => switch (step) {
  WeeklyReviewStep.capture => l.reviewStep1Body,
  WeeklyReviewStep.inbox => l.reviewStep2Body,
  WeeklyReviewStep.actions => l.reviewStep3Body,
  WeeklyReviewStep.waiting => l.reviewStep4Body,
  WeeklyReviewStep.projects => l.reviewStep5Body,
  WeeklyReviewStep.calendar => l.reviewStep6Body,
  WeeklyReviewStep.someday => l.reviewStep7Body,
};

class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key});
  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  bool _saving = false;
  bool _finished = false;
  bool _capturing = false;
  bool get _busy => _saving || _capturing;

  Future<void> _navigate(WeeklyReviewStep step, {bool finish = false}) async {
    if (_busy) return;
    setState(() => _saving = true);
    final l = AppLocalizations.of(context);
    try {
      final controller = ref.read(weeklyReviewControllerProvider.notifier);
      final saved = finish
          ? await controller.finish()
          : await controller.moveTo(step);
      if (!mounted) return;
      if (saved && finish) {
        // A finished Weekly Review is a success moment; the policy decides
        // whether to actually ask for a store rating (ADR 0007).
        unawaited(
          ref
              .read(maybeRequestAppReviewProvider)
              .call(ReviewMoment.weeklyReviewFinished),
        );
        // Let the completed route pop after PopScope rebuilds, while keeping
        // Finish disabled so a second tap cannot submit the same session.
        setState(() => _finished = true);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.reviewCompleteSnackbar)));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.weeklyReviewSaveError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(weeklyReviewControllerProvider);
    return PopScope(
      canPop: !_busy || _finished,
      child: session.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l.weeklyReviewCardTitle)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => Scaffold(
          appBar: AppBar(title: Text(l.weeklyReviewCardTitle)),
          body: ErrorView(
            error: e,
            stackTrace: st,
            onRetry: () => ref.invalidate(weeklyReviewControllerProvider),
          ),
        ),
        data: (review) {
          final step = review.currentStep;
          final index = step.index;
          final isLast = step == WeeklyReviewStep.someday;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                l.reviewStepCounter(index + 1, WeeklyReviewStep.values.length),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (index > 0)
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () =>
                                  _navigate(WeeklyReviewStep.values[index - 1]),
                        child: Text(l.back),
                      ),
                    const Spacer(),
                    Flexible(
                      child: FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _navigate(
                                isLast
                                    ? step
                                    : WeeklyReviewStep.values[index + 1],
                                finish: isLast,
                              ),
                        icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                        label: Text(isLast ? l.finishReview : l.next),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: AdaptiveWorkspace(
                primary: WeeklyReviewSteps(
                  step: step,
                  onSelected: _busy ? null : _navigate,
                ),
                detail: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (index + 1) / WeeklyReviewStep.values.length,
                    ),
                    Expanded(
                      child: ListView(
                        key: PageStorageKey(step),
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            _stepTitle(l, step),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _stepBody(l, step),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.weeklyReviewProgressSaved,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 20),
                          if (step == WeeklyReviewStep.capture)
                            _CapturePanel(
                              onSavingChanged: (saving) {
                                setState(() => _capturing = saving);
                              },
                            ),
                          if (step == WeeklyReviewStep.inbox)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: FilledButton.icon(
                                onPressed: () => context.push('/process'),
                                icon: const Icon(Icons.inbox_outlined),
                                label: Text(l.processInbox),
                              ),
                            ),
                          if (step == WeeklyReviewStep.projects)
                            const _ProjectsPanel()
                          else
                            _ItemsPanel(step: step),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shared with the route composition when a task is opened above the review.
/// The selected step is position, not a claim that earlier steps are complete.
class WeeklyReviewSteps extends StatelessWidget {
  const WeeklyReviewSteps({required this.step, this.onSelected, super.key});
  final WeeklyReviewStep step;
  final ValueChanged<WeeklyReviewStep>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      key: const PageStorageKey('weekly-review-steps'),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l.weeklyReviewCardTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 16),
        for (final entry in WeeklyReviewStep.values)
          ListTile(
            key: ValueKey('review-step-${entry.name}'),
            selected: entry == step,
            leading: Text('${entry.index + 1}'),
            title: Text(_stepTitle(l, entry)),
            onTap: onSelected == null ? null : () => onSelected!(entry),
          ),
      ],
    );
  }
}

class _CapturePanel extends ConsumerStatefulWidget {
  const _CapturePanel({required this.onSavingChanged});
  final ValueChanged<bool> onSavingChanged;
  @override
  ConsumerState<_CapturePanel> createState() => _CapturePanelState();
}

class _CapturePanelState extends ConsumerState<_CapturePanel>
    with AutomaticKeepAliveClientMixin {
  // The checklist is lazy. Scrolling or resizing must not dispose a draft or
  // interrupt the parent's capture-in-flight guard.
  @override
  bool get wantKeepAlive => true;
  final _title = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final title = _title.text.trim();
    if (_saving || title.isEmpty) return;
    setState(() => _saving = true);
    widget.onSavingChanged(true);
    try {
      await ref.read(captureItemProvider).call(title: title);
      if (mounted) _title.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).weeklyReviewActionError),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        widget.onSavingChanged(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            enabled: !_saving,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.captureHint),
            onSubmitted: (_) => _capture(),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _capture,
            icon: const Icon(Icons.add),
            label: Text(l.captureSubmit),
          ),
        ],
      ),
    );
  }
}

class _ItemsPanel extends ConsumerWidget {
  const _ItemsPanel({required this.step});
  final WeeklyReviewStep step;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(weeklyReviewItemsProvider(step));
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => ErrorView(
        error: e,
        stackTrace: st,
        onRetry: () => ref.invalidate(reviewItemsProvider),
      ),
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.bucketCount(list.length),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          if (list.isEmpty) Text(l.weeklyReviewListEmpty),
          for (final item in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ItemCard(
                key: ValueKey(item.id),
                item: item,
                onTap: () => context.push('/item/${item.id}?review=weekly'),
                onComplete:
                    step == WeeklyReviewStep.capture ||
                        step == WeeklyReviewStep.inbox
                    ? null
                    : () async {
                        try {
                          await completeWithUndo(context, ref, item.id);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.weeklyReviewActionError),
                              ),
                            );
                          }
                        }
                      },
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectsPanel extends ConsumerWidget {
  const _ProjectsPanel();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final startedAt = ref
        .watch(weeklyReviewControllerProvider)
        .valueOrNull
        ?.startedAt;
    bool reviewed(Project p) =>
        startedAt != null &&
        p.lastReviewedAt != null &&
        !p.lastReviewedAt!.isBefore(startedAt);
    return ref
        .watch(weeklyReviewProjectsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => ErrorView(
            error: e,
            stackTrace: st,
            onRetry: () {
              ref.invalidate(projectsProvider);
              ref.invalidate(reviewItemsProvider);
            },
          ),
          data: (projects) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (projects.isEmpty)
                Text(l.weeklyReviewListEmpty)
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l.weeklyReviewReviewedProgress(
                        projects.where((e) => reviewed(e.project)).length,
                        projects.length,
                      ),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              for (final project in projects)
                _ReviewProjectCard(
                  key: ValueKey(project.project.id),
                  entry: project,
                  reviewed: reviewed(project.project),
                ),
            ],
          ),
        );
  }
}

class _ReviewProjectCard extends ConsumerStatefulWidget {
  const _ReviewProjectCard({
    required this.entry,
    required this.reviewed,
    super.key,
  });
  final ReviewProject entry;

  /// Marked reviewed during this Weekly Review session.
  final bool reviewed;
  @override
  ConsumerState<_ReviewProjectCard> createState() => _ReviewProjectCardState();
}

class _ReviewProjectCardState extends ConsumerState<_ReviewProjectCard> {
  bool _saving = false;
  Future<void> _changeStatus(ProjectStatus status) {
    final change = ref.read(changeProjectStatusProvider);
    final id = widget.entry.project.id;
    final previous = widget.entry.project.status;
    // Closing a project is hard to spot as a mistake right beside "On hold",
    // so offer Undo. The card leaves the list once the status changes, so the
    // snackbar and its callback must not depend on this widget staying alive.
    final snackBar = status == ProjectStatus.done
        ? undoSnackBar(
            context,
            message: AppLocalizations.of(context).completed,
            onUndo: () => change(id, previous),
          )
        : null;
    final messenger = ScaffoldMessenger.of(context);
    return _run(() async {
      await change(id, status);
      if (snackBar != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).weeklyReviewActionError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _markReviewed() => _run(
    () => ref.read(markProjectReviewedProvider).call(widget.entry.project.id),
  );

  Future<void> _addAction() async {
    final add = ref.read(addProjectNextActionProvider);
    final projectId = widget.entry.project.id;
    await showDialog<void>(
      context: context,
      builder: (_) =>
          _NextActionDialog(onSave: (title) => add(projectId, title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = widget.entry.project;
    final stalled =
        p.status == ProjectStatus.active &&
        widget.entry.movement == ProjectMovement.stalled;
    final scheme = Theme.of(context).colorScheme;
    final lastReviewed = p.lastReviewedAt;
    final status = switch (p.status) {
      ProjectStatus.active =>
        stalled
            ? l.projectMissingNextAction
            : widget.entry.movement == ProjectMovement.awaiting
            ? l.weeklyReviewProjectAwaiting
            : l.weeklyReviewProjectMoving,
      ProjectStatus.onHold => l.projectSectionOnHold,
      ProjectStatus.someday => l.somedayMaybe,
      ProjectStatus.done => l.done,
      ProjectStatus.dropped => l.projectStatusDropped,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.title, style: Theme.of(context).textTheme.titleMedium),
            if (p.outcome != null && p.outcome!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(p.outcome!),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  stalled ? Icons.warning_amber_rounded : Icons.folder_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(status)),
              ],
            ),
            if (widget.entry.inactive) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.hourglass_empty, size: 20, color: scheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.weeklyReviewProjectInactive(inactiveProjectDays),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Text(
              lastReviewed == null
                  ? l.weeklyReviewNeverReviewed
                  : l.weeklyReviewLastReviewed(
                      DateFormat.yMMMd(l.dateLocaleName).format(lastReviewed),
                    ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.reviewed)
                  // Not a button: the project is done for this session.
                  Semantics(
                    container: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: scheme.primary),
                          const SizedBox(width: 6),
                          Flexible(child: Text(l.weeklyReviewReviewed)),
                        ],
                      ),
                    ),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: _saving ? null : _markReviewed,
                    icon: const Icon(Icons.check),
                    label: Text(l.weeklyReviewMarkReviewed),
                  ),
                OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => context.push('/project/${p.id}'),
                  child: Text(l.weeklyReviewOpenProject),
                ),
                if (stalled) ...[
                  FilledButton.icon(
                    onPressed: _saving ? null : _addAction,
                    icon: const Icon(Icons.add),
                    label: Text(l.addNextActionTitle),
                  ),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => _changeStatus(ProjectStatus.onHold),
                    child: Text(l.projectSectionOnHold),
                  ),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => _changeStatus(ProjectStatus.done),
                    child: Text(l.done),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextActionDialog extends StatefulWidget {
  const _NextActionDialog({required this.onSave});
  final Future<void> Function(String title) onSave;
  @override
  State<_NextActionDialog> createState() => _NextActionDialogState();
}

class _NextActionDialogState extends State<_NextActionDialog> {
  final _title = TextEditingController();
  bool _saving = false;
  bool _failed = false;
  bool _saved = false;
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (_saving || title.isEmpty) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onSave(title);
      if (!mounted) return;
      setState(() => _saved = true);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: !_saving || _saved,
      child: AlertDialog(
        title: Text(l.addNextActionTitle),
        content: TextField(
          controller: _title,
          enabled: !_saving,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l.addNextActionHint,
            errorText: _failed ? l.weeklyReviewActionError : null,
            errorMaxLines: 3,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: _saving || _title.text.trim().isEmpty ? null : _submit,
            child: Text(l.add),
          ),
        ],
      ),
    );
  }
}
