import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/search_text.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/empty_state.dart';
import '../common/error_view.dart';
import '../common/item_card.dart';
import '../common/keyboard_shortcut_actions.dart';
import '../common/workspace_scroll_controller.dart';
import 'project_filter_sheet.dart';
import 'search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    this.onOpenItem,
    this.selectedItemId,
    this.initialScrollOffset = 0,
    super.key,
  });
  final ValueChanged<String>? onOpenItem;
  final String? selectedItemId;
  final double initialScrollOffset;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchFocus = FocusNode();
  late final _scroll = WorkspaceScrollController(
    initialScrollOffset: widget.initialScrollOffset,
  );

  @override
  void dispose() {
    _searchFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _openItem(String id) {
    final open = widget.onOpenItem;
    if (open != null) {
      open(id);
    } else {
      context.push(
        Uri(
          path: '/item/$id',
          queryParameters: {'workspace': 'search'},
        ).toString(),
        extra: _scroll.hasClients ? _scroll.offset : 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = _buildSearch(context);
    return CallbackShortcuts(
      bindings: {
        searchShortcut: () {
          if (ModalRoute.isCurrentOf(context) == true) {
            _searchFocus.requestFocus();
          }
        },
      },
      // Keep key handling active when the standalone page has no focused
      // field. In a workspace, use its existing cross-pane focus traversal.
      child: widget.onOpenItem == null
          ? FocusScope(autofocus: true, child: search)
          : search,
    );
  }

  Widget _buildSearch(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(searchFilterProvider);
    final results = ref.watch(filteredSearchResultsProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.onOpenItem == null,
        title: _SearchField(
          autofocus: widget.onOpenItem == null,
          focusNode: _searchFocus,
        ),
        actions: [
          if (filter.activeCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Badge(
                label: Text('${filter.activeCount}'),
                child: IconButton(
                  tooltip: l.clearFilters,
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: () =>
                      ref.read(searchFilterProvider.notifier).clear(),
                ),
              ),
            ),
          if (query.isNotEmpty)
            IconButton(
              tooltip: l.clearSearch,
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(searchQueryProvider.notifier).state = '',
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _SearchFilterBar(),
            const Divider(height: 1),
            Expanded(
              child: !isSearchableQuery(query)
                  ? _Hint(text: l.searchMinChars, icon: Icons.search)
                  : results.when(
                      skipLoadingOnReload: true,
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => ErrorView(
                        error: e,
                        stackTrace: st,
                        onRetry: () =>
                            ref.invalidate(filteredSearchResultsProvider),
                      ),
                      data: (list) {
                        if (widget.selectedItemId != null) {
                          _scroll.prepare(
                            widget.selectedItemId,
                            list.map((item) => item.id).toList(),
                          );
                        }
                        if (list.isEmpty) {
                          if (filter.isEmpty) {
                            return _Hint(
                              text: l.searchNoResults(query.trim()),
                              icon: Icons.search_off,
                            );
                          }
                          return EmptyState(
                            icon: Icons.filter_alt_off_outlined,
                            title: l.searchNoMatchTitle,
                            message: l.searchNoMatchMessage,
                            action: FilledButton(
                              onPressed: () => ref
                                  .read(searchFilterProvider.notifier)
                                  .clear(),
                              child: Text(l.clearFilters),
                            ),
                          );
                        }
                        return WorkspaceListViewport(
                          controller: _scroll,
                          child: ListView.separated(
                            controller: _scroll,
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) => ItemCard(
                              key: widget.onOpenItem != null
                                  ? _scroll.itemKey(list[i].id)
                                  : null,
                              item: list[i],
                              highlighted: list[i].id == widget.selectedItemId,
                              onTap: list[i].id == widget.selectedItemId
                                  ? null
                                  : () => _openItem(list[i].id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns the [TextEditingController] lifecycle and pushes edits into
/// [searchQueryProvider]. Kept as the screen's only stateful leaf so the
/// rest of the tree can be a [ConsumerWidget].
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({required this.autofocus, required this.focusNode});
  final bool autofocus;
  final FocusNode focusNode;

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the field in sync when the query is cleared from elsewhere
    // (the AppBar clear button) without disturbing in-progress typing.
    ref.listen<String>(searchQueryProvider, (_, next) {
      if (next != _ctrl.text) {
        _ctrl.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return TextField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).searchHint,
        border: InputBorder.none,
      ),
      onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
    );
  }
}

/// Always-visible filter strip below the AppBar. Row 1: status multi-select
/// + a "Completed" toggle + the project picker chip. Row 2: context chips.
/// Styled to match the Engage screen's `_FilterStrip`.
class _SearchFilterBar extends ConsumerWidget {
  const _SearchFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final controller = ref.read(searchFilterProvider.notifier);
    final contexts = ref.watch(contextsProvider).valueOrNull ?? const [];
    final projects = ref.watch(projectsProvider).valueOrNull ?? const [];
    final l = AppLocalizations.of(context);

    // Self-heal a dangling project filter: if the selected project no
    // longer exists, drop the constraint instead of silently showing
    // nothing.
    ref.listen(projectsProvider, (_, next) {
      final id = filter.projectId;
      final list = next.valueOrNull;
      if (id != null && list != null && !list.any((p) => p.id == id)) {
        controller.setProject(null);
      }
    });

    final selectedProject = filter.projectId == null
        ? null
        : projects.where((p) => p.id == filter.projectId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final s in searchStatusChips) ...[
                  FilterChip(
                    selected: filter.statuses.contains(s),
                    label: Text(_statusLabel(l, s)),
                    onSelected: (_) => controller.toggleStatus(s),
                  ),
                  const SizedBox(width: 6),
                ],
                const SizedBox(width: 6),
                FilterChip(
                  selected: filter.includeCompleted,
                  avatar: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(l.filterCompleted),
                  onSelected: controller.setIncludeCompleted,
                ),
                const SizedBox(width: 12),
                FilterChip(
                  selected: filter.projectId != null,
                  avatar: const Icon(Icons.folder_outlined, size: 16),
                  label: Text(selectedProject?.title ?? l.filterAllProjects),
                  onSelected: (_) async {
                    final pick = await showProjectFilterPicker(
                      context,
                      ref,
                      selectedId: filter.projectId,
                    );
                    switch (pick) {
                      case null:
                        break;
                      case ProjectFilterAll():
                        controller.setProject(null);
                      case ProjectFilterId(:final id):
                        controller.setProject(id);
                    }
                  },
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                FilterChip(
                  selected: filter.contextId == null,
                  label: Text(l.filterAllContexts),
                  onSelected: (_) => controller.setContext(null),
                ),
                const SizedBox(width: 6),
                for (final c in contexts) ...[
                  FilterChip(
                    selected: filter.contextId == c.id,
                    label: Text(c.name),
                    onSelected: (sel) =>
                        controller.setContext(sel ? c.id : null),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Short status labels for the filter chips (the enum's own `label` is too
/// long for a chip strip, e.g. "Someday / Maybe").
String _statusLabel(AppLocalizations l, ItemStatus s) => switch (s) {
  ItemStatus.inbox => l.statusInbox,
  ItemStatus.nextAction => l.statusNext,
  ItemStatus.waiting => l.statusWaiting,
  ItemStatus.someday => l.statusSomeday,
  ItemStatus.reference => l.statusReference,
  _ => s.label,
};

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
