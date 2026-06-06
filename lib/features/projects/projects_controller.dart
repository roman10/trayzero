import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';

/// A labelled group of projects rendered as one section on the
/// Projects screen.
class ProjectSection {
  const ProjectSection({required this.label, required this.projects});
  final String label;
  final List<Project> projects;
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
      sections.add(ProjectSection(label: area.name, projects: inArea));
    }
    final unfiled = active.where((p) => p.areaId == null).toList();
    if (unfiled.isNotEmpty) {
      sections.add(ProjectSection(label: 'Unfiled', projects: unfiled));
    }
  } else if (active.isNotEmpty) {
    sections.add(ProjectSection(label: 'Active', projects: active));
  }
  if (onHold.isNotEmpty) {
    sections.add(ProjectSection(label: 'On hold', projects: onHold));
  }
  if (someday.isNotEmpty) {
    sections.add(ProjectSection(label: 'Someday', projects: someday));
  }
  if (done.isNotEmpty) {
    sections.add(ProjectSection(label: 'Completed', projects: done));
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
