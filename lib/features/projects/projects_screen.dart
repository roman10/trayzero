import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/empty_state.dart';
import 'project_movement.dart';
import 'project_picker.dart';
import 'projects_controller.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsProvider);
    final sections = ref.watch(projectSectionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectsTitle),
        actions: [
          IconButton(
            tooltip: l10n.organizeLooseActionsTooltip,
            icon: const Icon(Icons.drive_file_move_outlined),
            onPressed: () => context.push('/organize'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects-fab',
        onPressed: () => showNewProjectSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newProject),
      ),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.folder_outlined,
              title: l10n.projectsEmptyTitle,
              message: l10n.projectsEmptyMessage,
              action: FilledButton.icon(
                onPressed: () => showNewProjectSheet(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.newProject),
              ),
            );
          }

          final secs =
              sections.valueOrNull ?? const <ProjectSection>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final s in secs)
                _Section(label: s.label, projects: s.projects),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.label, required this.projects});
  final String label;
  final List<Project> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          ...projects.map((p) => _ProjectTile(project: p)),
        ],
      ),
    );
  }
}

class _ProjectTile extends ConsumerWidget {
  const _ProjectTile({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(projectItemsProvider(project.id)).valueOrNull ?? const [];
    final movement = projectMovement(items);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/project/${project.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.folder_outlined,
                          color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (project.status == ProjectStatus.active)
                      switch (movement) {
                        ProjectMovement.healthy => const SizedBox.shrink(),
                        ProjectMovement.awaiting => Tooltip(
                            message:
                                'Awaiting — in motion via waiting or scheduled items',
                            child: Icon(Icons.hourglass_bottom_rounded,
                                color: scheme.tertiary, size: 20),
                          ),
                        ProjectMovement.stalled => Tooltip(
                            message:
                                'Stalled — no next action, waiting, or scheduled item',
                            child: Icon(Icons.warning_amber_rounded,
                                color: scheme.error, size: 20),
                          ),
                      },
                  ],
                ),
                if (project.outcome != null && project.outcome!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    project.outcome!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MiniChip(
                      label: AppLocalizations.of(context)
                          .projectActionCount(items.length),
                      icon: Icons.task_alt,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
