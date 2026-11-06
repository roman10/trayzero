import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/error_view.dart';
import '../common/localized_entity_labels.dart';
import 'projects_controller.dart';

/// Read-only project context beside an editor. It cannot create a second draft
/// for the currently edited item or accidentally complete/delete another task.
class ProjectItemsPane extends ConsumerWidget {
  const ProjectItemsPane({
    required this.projectId,
    required this.selectedItemId,
    required this.onSelected,
    super.key,
  });
  final String projectId;
  final String selectedItemId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(projectWorkspaceItemsProvider(projectId));
    final project = ref.watch(workspaceProjectProvider(projectId));
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          project?.title ?? l10n.project,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorView(
            error: error,
            stackTrace: stack,
            onRetry: () {
              ref.invalidate(projectItemsProvider(projectId));
              ref.invalidate(completedProjectItemsProvider(projectId));
            },
          ),
          data: (items) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item.id == selectedItemId;
              return ListTile(
                key: ValueKey(item.id),
                selected: selected,
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                title: Text(item.title),
                subtitle: Text(item.status.localizedLabel(l10n)),
                onTap: selected ? null : () => onSelected(item.id),
              );
            },
          ),
        ),
      ),
    );
  }
}
