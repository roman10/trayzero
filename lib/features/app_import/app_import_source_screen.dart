import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/microsoft_todo_gateway.dart';
import '../../domain/entities/entities.dart';
import '../../domain/import/import_plan.dart';
import '../../domain/import/import_resolution.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_entity_labels.dart';
import '../common/readable_page_body.dart';
import 'app_import_controller.dart';
import 'import_source_catalog.dart';

/// One source's page (`/settings/import/:source`, ADR 0008): its numbered
/// steps and a pinned primary action, then every later step of the flow
/// (list choice, preview, import, undo) in place.
class AppImportSourceScreen extends ConsumerWidget {
  const AppImportSourceScreen({super.key, required this.source});

  final ImportSourceApp source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The controller is autoDispose, so entering a source page usually starts
    // clean. If two source pages are stacked (fast double tap on the list),
    // they share the controller: ignore state that belongs to another source
    // so this page never shows that source's preview or result.
    final shared = ref.watch(appImportControllerProvider);
    final state = shared.source == null || shared.source == source
        ? shared
        : const AppImportState();
    final controller = ref.read(appImportControllerProvider.notifier);
    final inPreview =
        state.step == AppImportStep.preview ||
        state.step == AppImportStep.importing;
    return PopScope(
      // Back from the preview or list choice returns to the source page;
      // nothing is written. Back never interrupts a write in progress.
      canPop:
          !state.busy &&
          state.step != AppImportStep.preview &&
          state.step != AppImportStep.appleLists,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.busy) controller.reset();
      },
      child: Scaffold(
        appBar: inPreview
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.cancel,
                  onPressed: state.busy ? null : controller.reset,
                ),
                title: Text(l10n.importReviewTitle),
              )
            : AppBar(title: Text(importSpec(source).name(l10n))),
        body: ReadablePageBody(
          child: switch (state.step) {
            AppImportStep.appleLists => _AppleLists(state: state),
            AppImportStep.reading when state.appleLists.isNotEmpty =>
              _AppleLists(state: state),
            AppImportStep.sources ||
            AppImportStep.reading => _SourceSteps(source: source, state: state),
            AppImportStep.preview ||
            AppImportStep.importing => _Preview(state: state),
            AppImportStep.done ||
            AppImportStep.undoing => _Result(state: state),
            AppImportStep.undone => const _Undone(),
          },
        ),
      ),
    );
  }
}

/// Buttons in this flow meet the 48dp touch target at any text size.
const _tallButton = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(Size(64, 48)),
);

/// Finishing returns to the settings screen, past both import pages.
void _finish(BuildContext context) => context.go('/settings');

String _errorText(AppImportState state, AppLocalizations l10n) =>
    switch (state.error!) {
      AppImportError.unrecognized => l10n.importErrorUnrecognized(
        importSpec(state.source!).name(l10n),
      ),
      AppImportError.noTasks => l10n.importErrorNoTasks,
      AppImportError.unreadable => l10n.importErrorUnreadable,
      AppImportError.writeFailed => l10n.importErrorWrite,
      AppImportError.undoFailed => l10n.importErrorUndo,
      AppImportError.microsoftSignIn => l10n.importMicrosoftSignInError,
      AppImportError.microsoftPermission => l10n.importMicrosoftPermissionError,
      AppImportError.microsoftNetwork => l10n.importMicrosoftNetworkError,
      AppImportError.microsoftUnavailable => l10n.importMicrosoftUnavailable,
      AppImportError.appleDenied => l10n.importAppleDenied,
      AppImportError.appleUnavailable => l10n.importAppleUnavailable,
      AppImportError.appleListsChanged => l10n.importAppleListsChanged,
    };

String _warningText(ImportWarning w, int n, AppLocalizations l10n) =>
    switch (w) {
      ImportWarning.detailsInNotes => l10n.importWarnDetailsInNotes(n),
      ImportWarning.thingsRecurrence => l10n.importWarnThingsRecurrence,
      ImportWarning.sourceReminders => l10n.importWarnSourceReminders(n),
      ImportWarning.completedSkipped => l10n.importWarnCompleted(n),
      ImportWarning.datedToCalendar => l10n.importWarnCalendar(n),
      ImportWarning.unparsedDate => l10n.importWarnDates(n),
      ImportWarning.repeatInNotes => l10n.importWarnRepeats(n),
      ImportWarning.subtasksFlattened => l10n.importWarnSubtasks(n),
      ImportWarning.sectionsInNotes => l10n.importWarnSections(n),
      ImportWarning.notImported => l10n.importWarnNotImported(n),
      ImportWarning.sourceDetailsNotImported => l10n.importWarnSourceDetails(n),
      ImportWarning.unreadableRows => l10n.importWarnUnreadable(n),
    };

/// The pinned bottom bar every step of the flow puts its buttons in.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: child,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Card(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSteps extends ConsumerStatefulWidget {
  const _SourceSteps({required this.source, required this.state});
  final ImportSourceApp source;
  final AppImportState state;

  @override
  ConsumerState<_SourceSteps> createState() => _SourceStepsState();
}

class _SourceStepsState extends ConsumerState<_SourceSteps> {
  ThingsDevice _device = ThingsDevice.ios;

  Future<void> _paste() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _PasteDialog(),
    );
    if (text == null) return;
    await ref
        .read(appImportControllerProvider.notifier)
        .pasteText(widget.source, text);
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(const ClipboardData(text: thingsDiagnosticsCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).importCodeCopied)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final source = widget.source;
    final state = widget.state;
    final spec = importSpec(source);
    final controller = ref.read(appImportControllerProvider.notifier);
    final reading = state.step == AppImportStep.reading;
    final isThings = source == ImportSourceApp.things;
    final isMicrosoft = source == ImportSourceApp.microsoftToDo;
    final isApple = source == ImportSourceApp.appleReminders;
    final msAvailable =
        !isMicrosoft || ref.watch(microsoftTodoGatewayProvider).available;
    final steps = spec.resolveSteps(l10n, _device);
    final note = spec.note?.call(l10n);

    final VoidCallback? primary = reading || !msAvailable
        ? null
        : isMicrosoft
        ? controller.connectMicrosoftTodo
        : isApple
        ? controller.loadAppleLists
        : () => controller.chooseFile(source);

    return Column(
      children: [
        if (reading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.error != null && state.source == source) ...[
                _ErrorBanner(_errorText(state, l10n)),
                const SizedBox(height: 8),
              ],
              if (isThings) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (device, label) in [
                      (ThingsDevice.ios, l10n.importThingsDeviceIos),
                      (ThingsDevice.mac, l10n.importThingsDeviceMac),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _device == device,
                        onSelected: (_) => setState(() => _device = device),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              for (var i = 0; i < steps.length; i++)
                _StepRow(
                  number: i + 1,
                  text: steps[i],
                  trailing: isThings && _device == ThingsDevice.ios && i == 0
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.copy, size: 18),
                            label: Text(
                              thingsDiagnosticsCode,
                              style: theme.textTheme.titleMedium,
                            ),
                            tooltip: l10n.importCopyCode,
                            onPressed: _copyCode,
                          ),
                        )
                      : null,
                ),
              if (note != null) ...[
                const SizedBox(height: 8),
                _InfoCard(title: l10n.importGoodToKnow, text: note),
              ],
            ],
          ),
        ),
        _ActionBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!msAvailable) ...[
                Text(
                  l10n.importMicrosoftUnavailable,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
              ],
              FilledButton.icon(
                style: _tallButton,
                onPressed: primary,
                icon: Icon(
                  isMicrosoft
                      ? Icons.login
                      : isApple
                      ? Icons.checklist
                      : Icons.folder_open_outlined,
                ),
                label: Text(
                  isMicrosoft
                      ? l10n.importConnect
                      : isApple
                      ? l10n.importAppleChooseLists
                      : l10n.importChooseFile,
                ),
              ),
              if (spec.acceptsPaste) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: _tallButton,
                  onPressed: reading ? null : _paste,
                  icon: const Icon(Icons.content_paste),
                  label: Text(l10n.importPasteText),
                ),
              ],
              if (isMicrosoft && reading && state.source == source) ...[
                const SizedBox(height: 8),
                TextButton(
                  style: _tallButton,
                  onPressed: controller.cancelMicrosoftRead,
                  child: Text(l10n.cancel),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A numbered instruction: a circular badge and wrapping text.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text, this.trailing});
  final int number;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                ),
                child: Text(
                  '$number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(text, style: theme.textTheme.bodyLarge),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({this.title, required this.text});
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.info_outline,
                size: 20,
                color: scheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleLists extends ConsumerWidget {
  const _AppleLists({required this.state});
  final AppImportState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(appImportControllerProvider.notifier);
    return Column(
      children: [
        if (state.busy) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.importAppleChooseLists,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(l10n.importAppleLimits),
              if (state.error != null) _ErrorBanner(_errorText(state, l10n)),
              if (state.appleLists.isEmpty) Text(l10n.importAppleNoLists),
              for (final list in state.appleLists)
                CheckboxListTile(
                  key: ValueKey('apple-list-${list.id}'),
                  title: Text(list.title),
                  subtitle: list.account.isEmpty ? null : Text(list.account),
                  value: state.selectedAppleListIds.contains(list.id),
                  onChanged: state.busy
                      ? null
                      : (_) => controller.toggleAppleList(list.id),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              TextButton(
                onPressed: state.busy ? null : controller.loadAppleLists,
                style: _tallButton,
                child: Text(l10n.importAppleReloadLists),
              ),
            ],
          ),
        ),
        _ActionBar(
          child: Row(
            children: [
              TextButton(
                onPressed: state.busy ? null : controller.reset,
                style: _tallButton,
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: state.busy || state.selectedAppleListIds.isEmpty
                      ? null
                      : controller.previewAppleReminders,
                  style: _tallButton,
                  child: Text(l10n.importPasteContinue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasteDialog extends StatefulWidget {
  const _PasteDialog();

  @override
  State<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends State<_PasteDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.importPasteTitle),
      content: TextField(
        controller: _text,
        autofocus: true,
        minLines: 6,
        maxLines: 12,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: l10n.importPasteHint,
          hintMaxLines: 4,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          style: _tallButton,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ListenableBuilder(
          listenable: _text,
          builder: (context, _) => FilledButton(
            style: _tallButton,
            onPressed: _text.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_text.text),
            child: Text(l10n.importPasteContinue),
          ),
        ),
      ],
    );
  }
}

/// A label and its value, wrapping instead of truncating at large text.
class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.value, this.badge});
  final String label;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (badge != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    badge!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({required this.state});
  final AppImportState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ImportPreview p = state.preview!;
    final importing = state.step == AppImportStep.importing;
    final controller = ref.read(appImportControllerProvider.notifier);
    final statusTiles = [
      for (final status in ItemStatus.values)
        if (p.byStatus[status] case final n? when n > 0)
          (status.localizedLabel(l10n), n),
      if (p.projects.isNotEmpty)
        (l10n.importPreviewProjects, p.projects.length),
    ];
    final hasAreas = p.newAreas.isNotEmpty || p.existingAreas.isNotEmpty;
    final hasLabels =
        p.newContexts.isNotEmpty ||
        p.existingContexts.isNotEmpty ||
        p.newTags.isNotEmpty ||
        p.existingTags.isNotEmpty;
    return Column(
      children: [
        if (importing) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.importFromSource(importSpec(state.source!).name(l10n)),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Semantics(
                header: true,
                child: Text(
                  l10n.importTotalTasks(p.total),
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              Text(l10n.importPreviewNothingYet),
              if (state.previouslyImported) ...[
                const SizedBox(height: 12),
                _InfoCard(text: l10n.importDuplicateWarning),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(_errorText(state, l10n)),
              ],
              if (state.source == ImportSourceApp.appleReminders) ...[
                const SizedBox(height: 12),
                _InfoCard(text: l10n.importAppleLimits),
              ],
              if (statusTiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                _StatusGrid(tiles: statusTiles),
              ],
              if (p.projects.isNotEmpty) ...[
                const SizedBox(height: 16),
                _PreviewCard(
                  title: l10n.importPreviewProjects,
                  summary: l10n.importNewExistingSummary(
                    p.projects.where((x) => x.isNew).length,
                    p.projects.where((x) => !x.isNew).length,
                  ),
                  initiallyExpanded: true,
                  child: _ProjectList(projects: p.projects),
                ),
              ],
              if (hasAreas) ...[
                const SizedBox(height: 12),
                _PreviewCard(
                  title: l10n.areasTitle,
                  summary: l10n.importNewExistingSummary(
                    p.newAreas.length,
                    p.existingAreas.length,
                  ),
                  child: _NamesBlock(
                    newNames: p.newAreas,
                    existingNames: p.existingAreas,
                  ),
                ),
              ],
              if (hasLabels) ...[
                const SizedBox(height: 12),
                _PreviewCard(
                  title: l10n.importContextsAndTags,
                  summary: l10n.importNewExistingSummary(
                    p.newContexts.length + p.newTags.length,
                    p.existingContexts.length + p.existingTags.length,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.newContexts.isNotEmpty ||
                          p.existingContexts.isNotEmpty)
                        _NamesBlock(
                          heading: l10n.contextsTitle,
                          newNames: p.newContexts,
                          existingNames: p.existingContexts,
                        ),
                      if (p.newTags.isNotEmpty || p.existingTags.isNotEmpty)
                        _NamesBlock(
                          heading: l10n.tagsSection,
                          newNames: p.newTags,
                          existingNames: p.existingTags,
                        ),
                    ],
                  ),
                ),
              ],
              if (p.warnings.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PreviewCard(
                  title: l10n.importGoodToKnow,
                  summary: l10n.importNotesCount(p.warnings.length),
                  child: Column(
                    children: [
                      for (final MapEntry(key: w, value: n)
                          in p.warnings.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ExcludeSemantics(
                                child: Icon(Icons.info_outline, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_warningText(w, n, l10n))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _ActionBar(
          child: Row(
            children: [
              TextButton(
                style: _tallButton,
                onPressed: importing ? null : controller.reset,
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: _tallButton,
                  onPressed: importing ? null : controller.confirm,
                  icon: const Icon(Icons.download_done),
                  label: Text(
                    l10n.importActionCount(p.total),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Big-number tiles, three per row (two at large text), wrapping freely.
class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.tiles});
  final List<(String, int)> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const gap = 8.0;
    final columns = MediaQuery.textScalerOf(context).scale(16) > 22 ? 2 : 3;
    return LayoutBuilder(
      builder: (context, c) {
        final width = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (label, n) in tiles)
              SizedBox(
                width: width,
                child: MergeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$n', style: theme.textTheme.titleLarge),
                          Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A rounded, divider-free collapsible card with a one-line summary.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.summary,
    required this.child,
    this.initiallyExpanded = false,
  });
  final String title;
  final String summary;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        subtitle: Text(
          summary,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [child],
      ),
    );
  }
}

/// The first three projects, then a button revealing the rest.
class _ProjectList extends StatefulWidget {
  const _ProjectList({required this.projects});
  final List<({String title, int actions, bool isNew})> projects;

  @override
  State<_ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<_ProjectList> {
  static const _collapsedCount = 3;
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = widget.projects;
    final shown = _all ? projects : projects.take(_collapsedCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final project in shown)
          _CountRow(
            label: project.title,
            value: l10n.importProjectActions(project.actions),
            badge: project.isNew
                ? l10n.importProjectNew
                : l10n.importProjectExisting,
          ),
        if (!_all && projects.length > _collapsedCount)
          TextButton(
            style: _tallButton,
            onPressed: () => setState(() => _all = true),
            child: Text(l10n.importShowAll(projects.length)),
          ),
      ],
    );
  }
}

/// "New: …" and "Already yours: …" lines, optionally under a small heading.
class _NamesBlock extends StatelessWidget {
  const _NamesBlock({
    this.heading,
    required this.newNames,
    required this.existingNames,
  });
  final String? heading;
  final List<String> newNames;
  final List<String> existingNames;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null)
            Text(
              heading!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (newNames.isNotEmpty)
            Text(l10n.importContextsNew(newNames.join(', '))),
          if (existingNames.isNotEmpty)
            Text(l10n.importContextsExisting(existingNames.join(', '))),
        ],
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.state});
  final AppImportState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final working = state.step == AppImportStep.undoing;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (working) const LinearProgressIndicator(),
        const SizedBox(height: 16),
        Icon(
          Icons.check_circle_outline,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            l10n.importDoneTitle(state.receipt!.itemIds.length),
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.importDoneBody, textAlign: TextAlign.center),
        if (state.receipt!.remindersFailed) ...[
          const SizedBox(height: 8),
          Text(l10n.importRemindersFailed, textAlign: TextAlign.center),
        ],
        if (state.error != null) ...[
          const SizedBox(height: 8),
          _ErrorBanner(_errorText(state, l10n)),
        ],
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              style: _tallButton,
              onPressed: working
                  ? null
                  : ref.read(appImportControllerProvider.notifier).undo,
              icon: const Icon(Icons.undo),
              label: Text(l10n.importUndo),
            ),
            FilledButton(
              style: _tallButton,
              onPressed: working ? null : () => _finish(context),
              child: Text(l10n.importFinish),
            ),
          ],
        ),
      ],
    );
  }
}

class _Undone extends StatelessWidget {
  const _Undone();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Icon(Icons.undo, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            l10n.importUndoneTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.importUndoneBody, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Center(
          child: FilledButton(
            style: _tallButton,
            onPressed: () => _finish(context),
            child: Text(l10n.importFinish),
          ),
        ),
      ],
    );
  }
}
