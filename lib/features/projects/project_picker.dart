import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';

/// Outcome of [showProjectPicker]. `null` from the future means the user
/// dismissed the sheet; an explicit [ProjectPickNone] means "detach from any
/// project", which is distinct from cancelling.
sealed class ProjectPick {
  const ProjectPick();
}

class ProjectPickNone extends ProjectPick {
  const ProjectPickNone();
}

class ProjectPickId extends ProjectPick {
  const ProjectPickId(this.id);
  final String id;
}

/// Bottom sheet to create a project. Persists it and returns the created
/// [Project], or `null` if cancelled. Single source for the new-project form
/// so the Projects list, the picker and the clarify flow stay in sync.
Future<Project?> showNewProjectSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final areas = ref.read(areasProvider).valueOrNull ?? const <Area>[];

  final result = await showModalBottomSheet<_NewProjectResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _NewProjectSheet(areas: areas),
  );
  if (result == null) return null;

  final now = ref.read(clockProvider).now();
  final project = Project(
    id: ref.read(idGeneratorProvider).newId(),
    title: result.title,
    outcome: result.outcome.isEmpty ? null : result.outcome,
    areaId: result.areaId,
    status: ProjectStatus.active,
    createdAt: now,
    updatedAt: now,
  );
  await ref.read(projectRepositoryProvider).upsert(project);
  return project;
}

/// What [_NewProjectSheet] hands back on "Create". Carries plain values so the
/// sheet can own (and dispose) its own controllers — disposing them in the
/// async caller raced the route's dismiss animation, which rebuilt the
/// TextField against an already-disposed controller (use-after-dispose).
class _NewProjectResult {
  const _NewProjectResult({
    required this.title,
    required this.outcome,
    required this.areaId,
  });
  final String title;
  final String outcome;
  final String? areaId;
}

/// The new-project form. A StatefulWidget so its [TextEditingController]s are
/// disposed in [dispose] — after the route fully unmounts — not synchronously
/// when the sheet future resolves while the close animation is still running.
class _NewProjectSheet extends StatefulWidget {
  const _NewProjectSheet({required this.areas});
  final List<Area> areas;

  @override
  State<_NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends State<_NewProjectSheet> {
  final _titleCtrl = TextEditingController();
  final _outcomeCtrl = TextEditingController();
  String? _areaId;
  String? _titleError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _outcomeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = AppLocalizations.of(context).projectNameRequired);
      return;
    }
    Navigator.pop(
      context,
      _NewProjectResult(
        title: title,
        outcome: _outcomeCtrl.text.trim(),
        areaId: _areaId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final areas = widget.areas;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.newProject,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.projectName,
                hintText: l10n.projectNameHint,
                errorText: _titleError,
              ),
              onChanged: _titleError == null
                  ? null
                  : (_) => setState(() => _titleError = null),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _outcomeCtrl,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Outcome — what does "done" look like?',
              ),
            ),
            if (areas.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _areaId,
                decoration: InputDecoration(
                  labelText: l10n.areaOfFocusOptional,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.unfiledOption),
                  ),
                  for (final a in areas)
                    DropdownMenuItem<String?>(
                      value: a.id,
                      child: Text(a.name),
                    ),
                ],
                onChanged: (v) => setState(() => _areaId = v),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Prompts for a project and re-files [item] under it (or detaches it on
/// "No project"). Shared by every "move to project" affordance so the
/// pick → move → feedback sequence is identical everywhere. No-ops on
/// dismiss.
Future<void> pickAndMoveToProject(
  BuildContext context,
  WidgetRef ref,
  Item item,
) async {
  final pick = await showProjectPicker(context, ref, currentId: item.projectId);
  if (pick == null) return;
  final projectId = switch (pick) {
    ProjectPickNone() => null,
    ProjectPickId(:final id) => id,
  };
  await ref.read(moveItemToProjectProvider).call(item, projectId);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        projectId == null ? 'Removed from project.' : 'Moved to project.',
      ),
    ),
  );
}

/// Bottom sheet to choose a project for an action. Lists active projects,
/// an optional "No project" row, and a "New project…" shortcut that funnels
/// through [showNewProjectSheet]. Returns `null` when dismissed.
Future<ProjectPick?> showProjectPicker(
  BuildContext context,
  WidgetRef ref, {
  String? currentId,
  bool allowNone = true,
}) async {
  final projects =
      ref.read(activeProjectsProvider).valueOrNull ?? const <Project>[];

  return showModalBottomSheet<ProjectPick>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Move to project',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                    onPressed: () async {
                      final created = await showNewProjectSheet(
                        sheetContext,
                        ref,
                      );
                      if (created == null || !sheetContext.mounted) return;
                      Navigator.pop(sheetContext, ProjectPickId(created.id));
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  if (allowNone)
                    ListTile(
                      leading: const Icon(Icons.not_interested),
                      title: const Text('No project'),
                      trailing: currentId == null
                          ? Icon(Icons.check, color: scheme.primary)
                          : null,
                      onTap: () =>
                          Navigator.pop(sheetContext, const ProjectPickNone()),
                    ),
                  if (projects.isEmpty && !allowNone)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Text(
                        'No active projects yet. Use "New" to create one.',
                      ),
                    ),
                  for (final p in projects)
                    ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(p.title),
                      subtitle: (p.outcome != null && p.outcome!.isNotEmpty)
                          ? Text(
                              p.outcome!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: currentId == p.id
                          ? Icon(Icons.check, color: scheme.primary)
                          : null,
                      onTap: () =>
                          Navigator.pop(sheetContext, ProjectPickId(p.id)),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
