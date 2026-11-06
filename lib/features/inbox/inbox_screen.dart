import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../application/backup_prompt.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../capture/capture_sheet.dart';
import '../common/complete_with_undo.dart';
import '../common/delete_with_undo.dart';
import '../common/empty_state.dart';
import '../common/error_view.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/item_card.dart';
import '../common/keyboard_shortcut_actions.dart';
import '../common/workspace_scroll_controller.dart';
import '../projects/project_picker.dart';
import '../settings/backup_prompt_card.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({
    this.onOpenItem,
    this.selectedItemId,
    this.initialScrollOffset = 0,
    super.key,
  });

  final ValueChanged<String>? onOpenItem;
  final String? selectedItemId;
  final double initialScrollOffset;

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _selectionMode = false;
  final _selected = <String>{};
  late final _scroll = WorkspaceScrollController(
    initialScrollOffset: widget.initialScrollOffset,
  );

  bool get _readOnly => widget.onOpenItem != null;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openItem(String id) {
    final select = widget.onOpenItem;
    if (select != null) {
      select(id);
      return;
    }
    context.push(
      Uri(
        path: '/item/$id',
        queryParameters: {'workspace': 'inbox'},
      ).toString(),
      extra: _scroll.hasClients ? _scroll.offset : 0.0,
    );
  }

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
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    // Leave selection first so a second tap can't trash the batch twice.
    _exitSelection();
    await deleteManyWithUndo(context, ref, ids);
  }

  Future<void> _completeSelected() async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    // Leave selection first so a second tap can't re-run the batch (a repeat
    // completion spawns no successor, so its Undo would orphan the first
    // run's recurrence instances).
    _exitSelection();
    await completeManyWithUndo(context, ref, ids);
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
    final showBackupPrompt =
        !_readOnly && ref.watch(backupPromptVisibleProvider);
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
                IconButton(
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _selected.isEmpty ? null : _deleteSelected,
                ),
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
              automaticallyImplyLeading: !_readOnly,
              actions: _readOnly
                  ? null
                  : [
                      if ((items.valueOrNull ?? const <Item>[]).isNotEmpty)
                        IconButton(
                          tooltip: l10n.select,
                          icon: const Icon(Icons.checklist),
                          onPressed: () => _enterSelection(),
                        ),
                      IconButton(
                        tooltip: l10n.howGtdWorks,
                        icon: const Icon(Icons.help_outline),
                        onPressed: () => showGtdWorkflowSheet(
                          context,
                          highlight: GtdStage.capture,
                        ),
                      ),
                      SearchShortcutButton(
                        onPressed: () => context.push('/search'),
                      ),
                    ],
            ),
      floatingActionButton: _selectionMode || _readOnly
          ? null
          : CaptureShortcutButton(
              heroTag: 'inbox-fab',
              onPressed: () => showCaptureSheet(context),
              extended: true,
            ),
      bottomNavigationBar: _selectionMode
          ? _SelectionActionBar(
              enabled: _selected.isNotEmpty,
              onDone: _completeSelected,
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
      body: SafeArea(
        top: false,
        child: WorkspaceListViewport(
          controller: _scroll,
          child: AnimationLimiter(
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                if (!_selectionMode && showBackupPrompt)
                  const SliverToBoxAdapter(child: BackupPromptCard()),
                ..._buildList(context, items),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, AsyncValue<List<Item>> items) {
    final l10n = AppLocalizations.of(context);
    return items.when(
      loading: () => const [
        SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      ],
      error: (e, st) => [
        SliverFillRemaining(
          child: ErrorView(
            error: e,
            stackTrace: st,
            onRetry: () => ref.invalidate(inboxItemsProvider),
          ),
        ),
      ],
      data: (list) {
        if (_readOnly) {
          _scroll.prepare(
            widget.selectedItemId,
            list.map((item) => item.id).toList(),
          );
        }
        if (list.isEmpty) {
          return [
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.inbox_outlined,
                title: l10n.inboxEmptyTitle,
                message: l10n.inboxEmptyMessage,
                action: _readOnly
                    ? null
                    : FilledButton.icon(
                        onPressed: () => showCaptureSheet(context),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.inboxEmptyAction),
                      ),
              ),
            ),
          ];
        }
        // Drop selections for items that left the inbox so the count and
        // every bulk sweep stay in sync (mirrors OrganizeActionsScreen).
        _selected.removeWhere((id) => !list.any((i) => i.id == id));
        // Keep the prompt, Process action and items in one scroll viewport:
        // pinned headers can consume the whole window at large text sizes.
        return [
          if (!_selectionMode && !_readOnly) ...[
            SliverToBoxAdapter(child: _ProcessHeader(count: list.length)),
            const SliverToBoxAdapter(child: Divider(height: 1)),
          ],
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, _readOnly ? 16 : 96),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = list[i];
                final highlighted = widget.selectedItemId == item.id;
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 250),
                  child: SlideAnimation(
                    verticalOffset: 20,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onLongPress: _selectionMode || _readOnly
                            ? null
                            : () => _enterSelection(item.id),
                        child: ItemCard(
                          key: _readOnly ? _scroll.itemKey(item.id) : null,
                          item: item,
                          highlighted: highlighted,
                          selectionMode: _selectionMode,
                          selected: _selected.contains(item.id),
                          onToggleSelected: () => _toggle(item.id),
                          onTap: highlighted ? null : () => _openItem(item.id),
                          // For things already done before triage:
                          // completes in place, no clarify pass.
                          onComplete: _readOnly
                              ? null
                              : () => completeWithUndo(context, ref, item.id),
                          onDelete: _readOnly
                              ? null
                              : () => deleteWithUndo(context, ref, item.id),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ];
      },
    );
  }
}

class _SelectionActionBar extends StatelessWidget {
  const _SelectionActionBar({
    required this.enabled,
    required this.onDone,
    required this.onMove,
    required this.onSomeday,
    required this.onNextAction,
  });

  final bool enabled;
  final VoidCallback onDone;
  final VoidCallback onMove;
  final VoidCallback onSomeday;
  final VoidCallback onNextAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = [
      (icon: Icons.task_alt, label: l10n.done, callback: onDone),
      (icon: Icons.folder_outlined, label: l10n.project, callback: onMove),
      (icon: Icons.schedule, label: l10n.someday, callback: onSomeday),
      (icon: Icons.bolt_outlined, label: l10n.nextAction, callback: onNextAction),
    ];
    return BottomAppBar(
      // Keep one readable line of enlarged text without taking most of a
      // short window. Horizontal scrolling preserves every action and label.
      height: 56 + MediaQuery.textScalerOf(context).scale(14) * 1.5,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final action in actions)
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: enabled ? action.callback : null,
                icon: Icon(action.icon, size: 22),
                label: Text(action.label),
              ),
          ],
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
