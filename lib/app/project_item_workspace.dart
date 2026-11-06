import 'package:flutter/material.dart';

import '../features/projects/project_items_pane.dart';
import 'item_workspace.dart';

class ProjectItemWorkspace extends StatelessWidget {
  const ProjectItemWorkspace({
    required this.itemId,
    required this.projectId,
    super.key,
  });
  final String itemId;
  final String projectId;

  @override
  Widget build(BuildContext context) => ItemWorkspace(
    itemId: itemId,
    queryParameters: {'project': projectId},
    navigationLocation: '/projects',
    primaryBuilder: (select) => ProjectItemsPane(
      projectId: projectId,
      selectedItemId: itemId,
      onSelected: select,
    ),
  );
}
