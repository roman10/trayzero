import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';

/// The kind of a projects-screen section. Built-in kinds resolve their header
/// text from localizations at render time; [ProjectSectionKind.area] carries a
/// user-defined [ProjectSection.areaName] instead.
enum ProjectSectionKind { area, unfiled, active, onHold, someday, completed }

/// A group of projects rendered as one section on the Projects screen. The
/// header label is not stored here so grouping stays locale-independent and
/// unit-testable; the widget layer resolves [kind] (and [areaName]) to text.
class ProjectSection {
  const ProjectSection({
    required this.kind,
    required this.projects,
    this.areaName,
  });
  final ProjectSectionKind kind;
  final List<Project> projects;

  /// The area's display name, set only when [kind] is
  /// [ProjectSectionKind.area].
  final String? areaName;
}

/// Pure grouping logic for the Projects screen. Active projects are grouped
/// by area (in the supplied area order, then an "Unfiled" bucket) when any
/// areas exist; otherwise under a single "Active" section. On-hold, someday
/// and completed projects follow as flat sections. Dropped projects are not
/// shown. Kept Riverpod-free so it is unit-testable.
List<ProjectSection> groupProjects(
  List<Project> projects,
  List<Area> areas,
) {
  List<Project> byStatus(ProjectStatus s) =>
      projects.where((p) => p.status == s).toList();

  final active = byStatus(ProjectStatus.active);
  final onHold = byStatus(ProjectStatus.onHold);
  final someday = byStatus(ProjectStatus.someday);
  final done = byStatus(ProjectStatus.done);

  final sections = <ProjectSection>[];

  if (areas.isNotEmpty && active.isNotEmpty) {
    for (final area in areas) {
      final inArea = active.where((p) => p.areaId == area.id).toList();
      if (inArea.isEmpty) continue;
      sections.add(ProjectSection(
        kind: ProjectSectionKind.area,
        areaName: area.name,
        projects: inArea,
      ));
    }
    final unfiled = active.where((p) => p.areaId == null).toList();
    if (unfiled.isNotEmpty) {
      sections.add(ProjectSection(
        kind: ProjectSectionKind.unfiled,
        projects: unfiled,
      ));
    }
  } else if (active.isNotEmpty) {
    sections.add(ProjectSection(
      kind: ProjectSectionKind.active,
      projects: active,
    ));
  }
  if (onHold.isNotEmpty) {
    sections.add(ProjectSection(
      kind: ProjectSectionKind.onHold,
      projects: onHold,
    ));
  }
  if (someday.isNotEmpty) {
    sections.add(ProjectSection(
      kind: ProjectSectionKind.someday,
      projects: someday,
    ));
  }
  if (done.isNotEmpty) {
    sections.add(ProjectSection(
      kind: ProjectSectionKind.completed,
      projects: done,
    ));
  }
  return sections;
}

/// Read model the Projects screen watches: the project list grouped into
/// display sections. Keeps grouping out of the widget tree.
final projectSectionsProvider = Provider<AsyncValue<List<ProjectSection>>>(
  (ref) {
    final projects = ref.watch(projectsProvider);
    final areas = ref.watch(areasProvider).valueOrNull ?? const <Area>[];
    return projects.whenData((list) => groupProjects(list, areas));
  },
);

/// Workspace context includes history so an editor opened from Completed still
/// has a selected entry. Repository ordering is retained within each group.
final projectWorkspaceItemsProvider = Provider.autoDispose
    .family<AsyncValue<List<Item>>, String>((ref, id) {
      final active = ref.watch(projectItemsProvider(id));
      final completed = ref.watch(completedProjectItemsProvider(id));
      return active.when(
        data: (items) => completed.whenData((done) => [...items, ...done]),
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
      );
    });

final workspaceProjectProvider = Provider.autoDispose.family<Project?, String>((
  ref,
  id,
) {
  final projects = ref.watch(projectsProvider).valueOrNull;
  return projects?.where((project) => project.id == id).firstOrNull;
});
