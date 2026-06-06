import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../capture/capture_sheet.dart';
import '../common/empty_state.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/item_card.dart';
import '../projects/project_picker.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _selectionMode = false;
  final _selected = <String>{};

  void _enterSelection([String? firstId]) {
    setState(() {
      _selectionMode = true;
      if (firstId != null) _selected.add(firstId);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _toggle(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  Future<void> _deleteSelected() async {
    final n = _selected.length;
    if (n == 0) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(dialogL10n.deleteItemsConfirmTitle(n)),
          content: Text(dialogL10n.deleteItemsConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(dialogL10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(batchDeleteItemsProvider).call(_selected.toList());
    _finish(l10n.deletedItemsSnackbar(n));
  }

  Future<void> _moveSelected(List<Item> list) async {
    final picked = list.where((i) => _selected.contains(i.id)).toList();
    if (picked.isEmpty) return;
    final pick = await showProjectPicker(context, ref, allowNone: false);
    if (pick == null) return;
    final projectId = switch (pick) {
      ProjectPickNone() => null,
      ProjectPickId(:final id) => id,
    };
    if (projectId == null) return;
    final move = ref.read(moveItemToProjectProvider);
    for (final i in picked) {
      await move(i, projectId);
    }
    if (!mounted) return;
    _finish(AppLocalizations.of(context).filedItemsSnackbar(picked.length));
  }

  Future<void> _setStatusSelected(
    List<Item> list,
    ItemStatus status,
    String destination,
  ) async {
    final picked = list.where((i) => _selected.contains(i.id)).toList();
    if (picked.isEmpty) return;
    final save = ref.read(saveItemProvider);
    for (final i in picked) {
      await save(i.copyWith(status: status));
    }
    if (!mounted) return;
    _finish(AppLocalizations.of(context)
        .movedItemsSnackbar(picked.length, destination));
  }

  void _finish(String message) {
    if (!mounted) return;
    _exitSelection();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inboxItemsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                tooltip: l10n.cancel,
                icon: const Icon(Icons.close),
                onPressed: _exitSelection,
              ),
              title: Text(l10n.selectionCountTitle(_selected.length)),
              actions: [
                TextButton(
                  onPressed: () {
                    final list = items.valueOrNull ?? const <Item>[];
                    setState(() {
                      if (_selected.length == list.length) {
                        _selected.clear();
                      } else {
                        _selected
                          ..clear()
                          ..addAll(list.map((i) => i.id));
                      }
                    });
                  },
                  child: Text(
                    _selected.length ==
                            (items.valueOrNull ?? const <Item>[]).length
                        ? l10n.selectNone
                        : l10n.selectAll,
                  ),
                ),
              ],
            )
          : AppBar(
              title: Text(l10n.inbox),
              actions: [
                if ((items.valueOrNull ?? const <Item>[]).isNotEmpty)
                  IconButton(
                    tooltip: l10n.select,
                    icon: const Icon(Icons.checklist),
                    onPressed: () => _enterSelection(),
                  ),
                IconButton(
                  tooltip: l10n.howGtdWorks,
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => showGtdWorkflowSheet(context,
                      highlight: GtdStage.capture),
                ),
                IconButton(
                  tooltip: l10n.search,
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/search'),
                ),
              ],
            ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              heroTag: 'inbox-fab',
              onPressed: () => showCaptureSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.capture),
            ),
      bottomNavigationBar: _selectionMode
          ? _SelectionActionBar(
              enabled: _selected.isNotEmpty,
              onDelete: _deleteSelected,
              onMove: () =>
                  _moveSelected(items.valueOrNull ?? const <Item>[]),
              onSomeday: () => _setStatusSelected(
                  items.valueOrNull ?? const <Item>[],
                  ItemStatus.someday,
                  l10n.someday),
              onNextAction: () => _setStatusSelected(
                  items.valueOrNull ?? const <Item>[],
                  ItemStatus.nextAction,
                  l10n.nextAction),
            )
          : null,
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.inboxEmptyTitle,
              message: l10n.inboxEmptyMessage,
              action: FilledButton.icon(
                onPressed: () => showCaptureSheet(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.inboxEmptyAction),
              ),
            );
          }
          // Drop selections for items that left the inbox so the count and
          // every bulk sweep stay in sync (mirrors OrganizeActionsScreen).
          _selected.removeWhere((id) => !list.any((i) => i.id == id));
          return Column(
            children: [
              if (!_selectionMode) ...[
                _ProcessHeader(count: list.length),
                const Divider(height: 1),
              ],
              Expanded(
                child: AnimationLimiter(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = list[i];
                      return AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 250),
                        child: SlideAnimation(
                          verticalOffset: 20,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onLongPress: _selectionMode
                                  ? null
                                  : () => _enterSelection(item.id),
                              child: ItemCard(
                                item: item,
                                selectionMode: _selectionMode,
                                selected: _selected.contains(item.id),
                                onToggleSelected: () => _toggle(item.id),
                                onTap: () =>
                                    context.push('/item/${item.id}'),
                                onDelete: () => ref
                                    .read(deleteItemProvider)
                                    .call(item.id),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectionActionBar extends StatelessWidget {
  const _SelectionActionBar({
    required this.enabled,
    required this.onDelete,
    required this.onMove,
    required this.onSomeday,
    required this.onNextAction,
  });

  final bool enabled;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onSomeday;
  final VoidCallback onNextAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BarAction(
            icon: Icons.delete_outline,
            label: l10n.delete,
            onPressed: enabled ? onDelete : null,
          ),
          _BarAction(
            icon: Icons.folder_outlined,
            label: l10n.project,
            onPressed: enabled ? onMove : null,
          ),
          _BarAction(
            icon: Icons.schedule,
            label: l10n.someday,
            onPressed: enabled ? onSomeday : null,
          ),
          _BarAction(
            icon: Icons.bolt_outlined,
            label: l10n.nextAction,
            onPressed: enabled ? onNextAction : null,
          ),
        ],
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        onPressed == null ? scheme.onSurfaceVariant.withValues(alpha: 0.4) : null;
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessHeader extends StatelessWidget {
  const _ProcessHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/process'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.bolt,
                      color: scheme.onPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.processInbox,
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        l10n.inboxItemsToClarify(count),
                        style: TextStyle(
                          color: scheme.onPrimaryContainer
                              .withValues(alpha: 0.75),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded,
                    color: scheme.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
