import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/empty_state.dart';
import '../common/error_view.dart';
import 'project_movement.dart';
import 'project_picker.dart';
import 'projects_controller.dart';

/// Resolves a section's localized header. Area sections use the user-defined
/// area name; built-in kinds map to translated strings.
String _sectionLabel(AppLocalizations l10n, ProjectSection s) {
  return switch (s.kind) {
    ProjectSectionKind.area => s.areaName ?? '',
    ProjectSectionKind.unfiled => l10n.projectSectionUnfiled,
    ProjectSectionKind.active => l10n.projectSectionActive,
    ProjectSectionKind.onHold => l10n.projectSectionOnHold,
    ProjectSectionKind.someday => l10n.someday,
    ProjectSectionKind.completed => l10n.completed,
  };
}

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({
    this.selectedProjectId,
    this.showBackButton = true,
    this.initialScrollOffset = 0,
    super.key,
  });

  final String? selectedProjectId;
  final bool showBackButton;
  final double initialScrollOffset;

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: widget.initialScrollOffset,
  );

  final _selectedTitleKey = GlobalKey();
  (String, Size, Size, List<ProjectSection>)? _revealedSelection;

  void _revealSelection(
    BoxConstraints constraints,
    List<ProjectSection> sections,
  ) {
    final id = widget.selectedProjectId;
    if (id == null) return;
    final selection = (
      id,
      constraints.biggest,
      MediaQuery.sizeOf(context),
      sections,
    );
    if (_revealedSelection == selection) return;
    _revealedSelection = selection;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.selectedProjectId != id ||
          _revealedSelection != selection) {
        return;
      }
      final selected = _selectedTitleKey.currentContext;
      if (selected == null ||
          !_scroll.hasClients ||
          context.findAncestorWidgetOfExactType<Offstage>()?.offstage == true) {
        _revealedSelection = null;
        return;
      }
      final target = selected.findRenderObject();
      if (target == null || !target.attached) return;
      final position = _scroll.position;
      final viewport = RenderAbstractViewport.of(target);
      final start = viewport.getOffsetToReveal(target, 0).offset;
      final end = viewport.getOffsetToReveal(target, 1).offset;
      final offset = start < position.pixels
          ? start
          : end > position.pixels
          ? end
          : position.pixels;
      // Preserve the user's scroll position when the selected title is already
      // visible. Pixel offsets alone cannot anchor a list after title reflow.
      final clamped = offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (clamped != position.pixels) position.jumpTo(clamped);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openProject(String id) {
    final offset = _scroll.hasClients ? _scroll.offset : 0.0;
    if (widget.selectedProjectId == null) {
      context.push('/project/$id', extra: offset);
    } else {
      context.replace('/project/$id', extra: offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsProvider);
    final sections = ref.watch(projectSectionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectsTitle),
        automaticallyImplyLeading: widget.showBackButton,
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
        error: (e, st) => ErrorView(
          error: e,
          stackTrace: st,
          onRetry: () => ref.invalidate(projectsProvider),
        ),
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

          final secs = sections.valueOrNull ?? const <ProjectSection>[];
          return LayoutBuilder(
            builder: (context, constraints) {
              _revealSelection(constraints, secs);
              return ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  for (final s in secs)
                    _Section(
                      label: _sectionLabel(l10n, s),
                      projects: s.projects,
                      selectedProjectId: widget.selectedProjectId,
                      selectedTitleKey: _selectedTitleKey,
                      onSelected: _openProject,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({
    required this.label,
    required this.projects,
    required this.onSelected,
    this.selectedProjectId,
    this.selectedTitleKey,
  });
  final GlobalKey? selectedTitleKey;
  final String? selectedProjectId;
  final String label;
  final List<Project> projects;
  final ValueChanged<String> onSelected;

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
          ...projects.map(
            (p) => _ProjectTile(
              project: p,
              selected: p.id == selectedProjectId,
              titleKey: p.id == selectedProjectId ? selectedTitleKey : null,
              onTap: () => onSelected(p.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// Open next actions in a project's items. Waiting, someday, reference and
/// calendar items are not actions the user can do now, so they are excluded
/// from the count shown on the project tile.
int projectNextActionCount(Iterable<Item> items) =>
    items.where((i) => i.status == ItemStatus.nextAction).length;

class _ProjectTile extends ConsumerWidget {
  const _ProjectTile({
    required this.project,
    required this.onTap,
    this.selected = false,
    this.titleKey,
  });
  final GlobalKey? titleKey;
  final VoidCallback onTap;
  final bool selected;
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(projectItemsProvider(project.id)).valueOrNull ?? const [];
    final movement = projectMovement(items);
    final nextCount = projectNextActionCount(items);
    final waitingCount = items
        .where((i) => i.status == ItemStatus.waiting)
        .length;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        child: Material(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: selected ? null : onTap,
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
                        child: Icon(
                          Icons.folder_outlined,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          project.title,
                          key: titleKey,
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
                            message: AppLocalizations.of(
                              context,
                            ).projectAwaitingTooltip,
                            child: Icon(
                              Icons.hourglass_bottom_rounded,
                              color: scheme.tertiary,
                              size: 20,
                            ),
                          ),
                          ProjectMovement.stalled => Tooltip(
                            message: AppLocalizations.of(
                              context,
                            ).projectStalledTooltip,
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: scheme.error,
                              size: 20,
                            ),
                          ),
                        },
                    ],
                  ),
                  if (project.outcome != null &&
                      project.outcome!.isNotEmpty) ...[
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MiniChip(
                        label: AppLocalizations.of(
                          context,
                        ).projectNextActionCount(nextCount),
                        icon: Icons.task_alt,
                      ),
                      if (waitingCount > 0)
                        _MiniChip(
                          label: AppLocalizations.of(
                            context,
                          ).projectWaitingCount(waitingCount),
                          icon: Icons.hourglass_bottom_rounded,
                        ),
                    ],
                  ),
                ],
              ),
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
