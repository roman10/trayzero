import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';

/// Outcome of [showProjectFilterPicker]. `null` from the future means the
/// user dismissed the sheet (keep the current selection); [ProjectFilterAll]
/// clears the project constraint; [ProjectFilterId] narrows to one project.
///
/// This is intentionally a separate type from `project_picker.dart`'s
/// `ProjectPick`: filtering and moving have different semantics (no "New
/// project", no side effects, all projects rather than active-only), so the
/// two pickers evolve independently.
sealed class ProjectFilterPick {
  const ProjectFilterPick();
}

class ProjectFilterAll extends ProjectFilterPick {
  const ProjectFilterAll();
}

class ProjectFilterId extends ProjectFilterPick {
  const ProjectFilterId(this.id);
  final String id;
}

/// Bottom sheet to choose a project to filter search results by. Lists every
/// project (any status) plus an "All projects" row at the top. Pure
/// selection — no creation, no mutation. Returns `null` when dismissed.
Future<ProjectFilterPick?> showProjectFilterPicker(
  BuildContext context,
  WidgetRef ref, {
  String? selectedId,
}) {
  final projects = ref.read(projectsProvider).valueOrNull ?? const <Project>[];

  return showModalBottomSheet<ProjectFilterPick>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter by project',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.all_inclusive),
                    title: Text(l10n.filterAllProjects),
                    trailing: selectedId == null
                        ? Icon(Icons.check, color: scheme.primary)
                        : null,
                    onTap: () => Navigator.pop(
                        sheetContext, const ProjectFilterAll()),
                  ),
                  if (projects.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Text('No projects yet.'),
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
                      trailing: selectedId == p.id
                          ? Icon(Icons.check, color: scheme.primary)
                          : null,
                      onTap: () => Navigator.pop(
                          sheetContext, ProjectFilterId(p.id)),
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
