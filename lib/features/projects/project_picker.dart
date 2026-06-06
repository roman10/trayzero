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
  final l10n = AppLocalizations.of(context);
  final areas = ref.read(areasProvider).valueOrNull ?? const <Area>[];
  final titleCtrl = TextEditingController();
  final outcomeCtrl = TextEditingController();
  String? areaId;
  String? titleError;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => Padding(
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
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.projectName,
                  hintText: l10n.projectNameHint,
                  errorText: titleError,
                ),
                onChanged: titleError == null
                    ? null
                    : (_) => setState(() => titleError = null),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: outcomeCtrl,
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
                  initialValue: areaId,
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
                  onChanged: (v) => setState(() => areaId = v),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) {
                        setState(() => titleError = l10n.projectNameRequired);
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  final title = titleCtrl.text.trim();
  final outcome = outcomeCtrl.text.trim();
  titleCtrl.dispose();
  outcomeCtrl.dispose();
  if (ok != true || title.isEmpty) return null;

  final now = ref.read(clockProvider).now();
  final project = Project(
    id: ref.read(idGeneratorProvider).newId(),
    title: title,
    outcome: outcome.isEmpty ? null : outcome,
    areaId: areaId,
    status: ProjectStatus.active,
    createdAt: now,
    updatedAt: now,
  );
  await ref.read(projectRepositoryProvider).upsert(project);
  return project;
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
