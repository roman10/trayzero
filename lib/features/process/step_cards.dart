import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/notes_text.dart';

class CapturedCard extends StatelessWidget {
  const CapturedCard({required this.item, super.key});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Cap the card so a long title/notes can't push the GTD step buttons off
    // screen; the content scrolls within this bound while short items stay
    // compact (the Column is still mainAxisSize.min).
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
          child: SingleChildScrollView(
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
    return Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
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
        OutlinedButton(
          onPressed: onNo,
          child: const Text('No — keep clarifying'),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'The Two-Minute Rule: if it takes less time to do than to track, '
            'just do it.',
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
          label: const Text('Yes — delegate & wait for them'),
          onPressed: onYes,
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onNo,
          child: const Text("No — it's on me"),
        ),
      ],
    );
  }
}

class StepSingleStep extends StatelessWidget {
  const StepSingleStep({required this.onProject, required this.onSingle, super.key});
  final VoidCallback onProject;
  final VoidCallback onSingle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepQuestion('Is this a single physical action?'),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: onSingle,
          child: const Text('Yes — single next action'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.folder_outlined),
          label: const Text('No — this is a project'),
          onPressed: onProject,
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'A project is any outcome that needs more than one action step '
            'and can finish within a year.',
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
    super.key,
  });
  final VoidCallback onCalendar;
  final VoidCallback onSetDefer;
  final VoidCallback onSkip;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepQuestion('Does it have a specific day or time?'),
        const SizedBox(height: 28),
        FilledButton.icon(
          icon: const Icon(Icons.bolt),
          label: const Text('No — do it as soon as I can'),
          onPressed: onSkip,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: const Text('Yes — put it on the calendar'),
          onPressed: onCalendar,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.snooze),
          label: const Text('Defer until a date'),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        const StepQuestion('Add details'),
        const SizedBox(height: 20),
        StepSection(
          label: 'CONTEXT',
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
          label: 'ENERGY',
          child: Wrap(
            spacing: 8,
            children: [
              for (final e in Energy.values)
                ChoiceChip(
                  label: Text(e.label),
                  selected: energy == e,
                  onSelected: (sel) => onEnergy(sel ? e : null),
                ),
            ],
          ),
        ),
        StepSection(
          label: 'TIME ESTIMATE',
          child: Wrap(
            spacing: 8,
            children: [
              for (final mins in const [5, 15, 30, 60, 120])
                ChoiceChip(
                  label: Text('${mins}m'),
                  selected: timeEstimate == mins,
                  onSelected: (sel) => onTime(sel ? mins : null),
                ),
            ],
          ),
        ),
        StepSection(
          label: 'PROJECT',
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
        if (deferUntil != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              const Icon(Icons.snooze, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deferred until '
                  '${DateFormat.yMMMd().add_jm().format(deferUntil!)}'
                  '${recurrence == null ? '' : ' · repeats '
                      '${recurrence!.label.toLowerCase()}'}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(AppLocalizations.of(context).back),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('File as next action'),
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
          child,
        ],
      ),
    );
  }
}
