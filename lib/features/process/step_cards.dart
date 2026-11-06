import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_dates.dart';
import '../common/notes_text.dart';
import '../common/localized_entity_labels.dart';

class CapturedCard extends StatefulWidget {
  const CapturedCard({required this.item, super.key});
  final Item item;

  @override
  State<CapturedCard> createState() => _CapturedCardState();
}

class _CapturedCardState extends State<CapturedCard> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    // Keep long captures bounded so reaching a decision does not require
    // scrolling through the whole note. The card and page scroll independently.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.4;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            primary: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).capturedLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  NotesText(
                    text: item.notes!,
                    baseStyle: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StepQuestion extends StatelessWidget {
  const StepQuestion(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class StepActionable extends StatelessWidget {
  const StepActionable({
    required this.onYes,
    required this.onReference,
    required this.onSomeday,
    required this.onTrash,
    super.key,
  });
  final VoidCallback onYes;
  final VoidCallback onReference;
  final VoidCallback onSomeday;
  final VoidCallback onTrash;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepQuestion(l10n.actionableQuestion),
        const SizedBox(height: 28),
        FilledButton.icon(
          icon: const Icon(Icons.bolt),
          label: Text(l10n.actionableYes),
          onPressed: onYes,
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          icon: const Icon(Icons.bookmark_outline),
          label: Text(l10n.actionableReference),
          onPressed: onReference,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.cloud_outlined),
          label: Text(l10n.actionableSomeday),
          onPressed: onSomeday,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.actionableTrash),
          onPressed: onTrash,
        ),
      ],
    );
  }
}

class StepTwoMin extends StatelessWidget {
  const StepTwoMin({required this.onYes, required this.onNo, super.key});
  final VoidCallback onYes;
  final VoidCallback onNo;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepQuestion(l10n.twoMinQuestion),
        const SizedBox(height: 28),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: Text(l10n.twoMinYes),
          onPressed: onYes,
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onNo, child: Text(l10n.processTwoMinNo)),
        const SizedBox(height: 18),
        Center(
          child: Text(
            l10n.twoMinRule,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class StepDelegate extends StatelessWidget {
  const StepDelegate({required this.onYes, required this.onNo, super.key});
  final VoidCallback onYes;
  final VoidCallback onNo;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepQuestion(l10n.delegateQuestion),
        const SizedBox(height: 28),
        FilledButton.icon(
          icon: const Icon(Icons.person_add_outlined),
          label: Text(l10n.delegateYes),
          onPressed: onYes,
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onNo, child: Text(l10n.delegateNo)),
      ],
    );
  }
}

class StepSingleStep extends StatelessWidget {
  const StepSingleStep({
    required this.onProject,
    required this.onSingle,
    super.key,
  });
  final VoidCallback onProject;
  final VoidCallback onSingle;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepQuestion(l10n.singleStepQuestion),
        const SizedBox(height: 28),
        FilledButton(onPressed: onSingle, child: Text(l10n.singleStepYes)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.folder_outlined),
          label: Text(l10n.singleStepProject),
          onPressed: onProject,
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            l10n.projectRule,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class StepDefer extends StatelessWidget {
  const StepDefer({
    required this.onCalendar,
    required this.onSetDefer,
    required this.onSkip,
    this.capturedStart,
    this.capturedDue,
    this.onUseCapturedStart,
    this.onUseCapturedDue,
    super.key,
  });
  final VoidCallback onCalendar;
  final VoidCallback onSetDefer;
  final VoidCallback onSkip;

  /// Start and due dates recognized at capture (ADR 0007), offered as
  /// one-tap answers above the generic choices.
  final DateTime? capturedStart;
  final DateTime? capturedDue;
  final VoidCallback? onUseCapturedStart;
  final VoidCallback? onUseCapturedDue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String date(DateTime d) => DateFormat.MMMEd(l10n.dateLocaleName).format(d);
    final start = capturedStart;
    final due = capturedDue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepQuestion(l10n.deferQuestion),
        const SizedBox(height: 28),
        if (due != null && onUseCapturedDue != null) ...[
          FilledButton.tonalIcon(
            icon: const Icon(Icons.event),
            label: Text(l10n.deferUseDueDate(date(due))),
            onPressed: onUseCapturedDue,
          ),
          const SizedBox(height: 8),
        ],
        if (start != null && onUseCapturedStart != null) ...[
          FilledButton.tonalIcon(
            icon: const Icon(Icons.schedule_send_outlined),
            label: Text(l10n.deferUseStartDate(date(start))),
            onPressed: onUseCapturedStart,
          ),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          icon: const Icon(Icons.bolt),
          label: Text(l10n.deferAsap),
          onPressed: onSkip,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: Text(l10n.deferCalendar),
          onPressed: onCalendar,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.snooze),
          label: Text(l10n.deferChooseDate),
          onPressed: onSetDefer,
        ),
      ],
    );
  }
}

class StepDetail extends StatelessWidget {
  const StepDetail({
    required this.contexts,
    required this.projects,
    required this.selectedContextId,
    required this.selectedProjectId,
    required this.energy,
    required this.timeEstimate,
    required this.deferUntil,
    required this.recurrence,
    required this.onContext,
    required this.onProject,
    required this.onCreateProject,
    required this.onEnergy,
    required this.onTime,
    required this.onConfirm,
    required this.onBack,
    this.tags,
    super.key,
  });
  final List<GtdContext> contexts;
  final List<Project> projects;
  final String? selectedContextId;
  final String? selectedProjectId;
  final Energy? energy;
  final int? timeEstimate;
  final DateTime? deferUntil;
  final Recurrence? recurrence;
  final ValueChanged<String?> onContext;
  final ValueChanged<String?> onProject;
  final VoidCallback onCreateProject;
  final ValueChanged<Energy?> onEnergy;
  final ValueChanged<int?> onTime;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  /// The optional Tags row (ADR 0010); null hides it, as when no tag exists.
  final Widget? tags;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepQuestion(l10n.processDetailsTitle),
        const SizedBox(height: 20),
        StepSection(
          label: l10n.contextSection,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final c in contexts)
                ChoiceChip(
                  label: Text(c.name),
                  selected: selectedContextId == c.id,
                  onSelected: (sel) => onContext(sel ? c.id : null),
                ),
            ],
          ),
        ),
        StepSection(
          label: l10n.energySection,
          child: Wrap(
            spacing: 8,
            children: [
              for (final e in Energy.values)
                ChoiceChip(
                  label: Text(e.localizedLabel(l10n)),
                  selected: energy == e,
                  onSelected: (sel) => onEnergy(sel ? e : null),
                ),
            ],
          ),
        ),
        StepSection(
          label: l10n.timeEstimateSection,
          child: Wrap(
            spacing: 8,
            children: [
              for (final mins in const [5, 15, 30, 60, 120])
                ChoiceChip(
                  label: Text(l10n.minutesShort(mins)),
                  selected: timeEstimate == mins,
                  onSelected: (sel) => onTime(sel ? mins : null),
                ),
            ],
          ),
        ),
        StepSection(
          label: l10n.projectSection,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text(l10n.none),
                selected: selectedProjectId == null,
                onSelected: (_) => onProject(null),
              ),
              for (final p in projects)
                ChoiceChip(
                  label: Text(p.title),
                  selected: selectedProjectId == p.id,
                  onSelected: (sel) => onProject(sel ? p.id : null),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: Text(l10n.newProject),
                onPressed: onCreateProject,
              ),
            ],
          ),
        ),
        if (tags != null) StepSection(label: l10n.tagsSection, child: tags!),
        if (deferUntil != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.snooze, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recurrence == null
                        ? l10n.deferredUntilSummary(
                            localizedDeferLabel(deferUntil!, l10n),
                          )
                        : l10n.deferredRepeatingSummary(
                            localizedDeferLabel(deferUntil!, l10n),
                            recurrence!.localizedLabel(l10n),
                          ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(AppLocalizations.of(context).back),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: Text(l10n.processFileNextAction),
              onPressed: onConfirm,
            ),
          ],
        ),
      ],
    );
  }
}

class StepSection extends StatelessWidget {
  const StepSection({required this.label, required this.child, super.key});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Semantics(
              header: true,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
