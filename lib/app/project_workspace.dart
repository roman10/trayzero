import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/common/adaptive_workspace.dart';
import '../features/projects/project_detail_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/shell/app_shell.dart';
import '../l10n/gen/app_localizations.dart';

class ProjectWorkspace extends StatefulWidget {
  const ProjectWorkspace({
    required this.projectId,
    required this.initialScrollOffset,
    super.key,
  });

  final String projectId;
  final double initialScrollOffset;

  @override
  State<ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

class _ProjectWorkspaceState extends State<ProjectWorkspace> {
  var _detailKey = GlobalKey<ProjectDetailScreenState>();
  bool _leaving = false;

  @override
  void didUpdateWidget(ProjectWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      _detailKey = GlobalKey<ProjectDetailScreenState>();
    }
  }

  Future<void> _navigate(String target) async {
    if (_leaving) return;
    _leaving = true;
    final detail = _detailKey;
    try {
      await detail.currentState?.commitOutcome();
      if (mounted &&
          detail == _detailKey &&
          ModalRoute.of(context)?.isCurrent == true) {
        context.go(target);
      }
    } catch (_) {
      if (mounted && detail == _detailKey) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).saveError)),
          );
      }
    } finally {
      _leaving = false;
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    location: '/projects',
    detailBodyWidth: 560,
    onNavigate: _navigate,
    child: AdaptiveWorkspace(
      primary: ProjectsScreen(
        selectedProjectId: widget.projectId,
        showBackButton: false,
        initialScrollOffset: widget.initialScrollOffset,
      ),
      detail: ProjectDetailScreen(key: _detailKey, projectId: widget.projectId),
    ),
  );
}
