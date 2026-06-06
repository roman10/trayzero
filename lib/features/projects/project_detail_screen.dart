import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/complete_with_undo.dart';
import '../common/item_card.dart';
import 'project_movement.dart';

/// Applies a `ReorderableListView` move to an id list. `newIndex` is the
/// destination index after the item at `oldIndex` is removed — matching the
/// `onReorderItem` callback contract introduced in Flutter 3.42 (the older
/// `onReorder` shifted `newIndex` by one when moving downward; that is now
/// the framework's job). Pure so it is unit-testable without a widget tree.
List<String> reorderedActionIds(
    List<String> ids, int oldIndex, int newIndex) {
  final next = [...ids];
  next.insert(newIndex, next.removeAt(oldIndex));
  return next;
}

/// Reorders [live] (DB order) to follow [pendingIds]. Ids in [pendingIds]
/// come first in that order; any live item not in it (e.g. just added
/// elsewhere) keeps its DB position at the end. Pure — the caller decides
/// when the pending override is no longer needed.
List<Item> applyManualOrder(List<Item> live, List<String>? pendingIds) {
  if (pendingIds == null) return live;
  final byId = {for (final i in live) i.id: i};
  final ordered = <Item>[];
  for (final id in pendingIds) {
    final it = byId.remove(id);
    if (it != null) ordered.add(it);
  }
  ordered.addAll(live.where((i) => byId.containsKey(i.id)));
  return ordered;
}

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({required this.projectId, super.key});
  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  Project? _project;
  late TextEditingController _outcome;

  /// Optimistic next-action order: the id sequence the user just dropped.
  /// Rendered immediately so the list never snaps back while the batched
  /// write round-trips; cleared by [_reconcilePendingOrder] once
  /// `projectItemsProvider` re-emits in this exact order.
  List<String>? _pendingOrderIds;

  @override
  void initState() {
    super.initState();
    _outcome = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final p = await ref
        .read(projectRepositoryProvider)
        .getById(widget.projectId);
    if (!mounted || p == null) return;
    setState(() {
      _project = p;
      _outcome.text = p.outcome ?? '';
    });
  }

  @override
  void dispose() {
    _outcome.dispose();
    super.dispose();
  }

  /// Drops the optimistic override once the persisted stream has caught up
  /// to it, so a *later* external change is never masked by stale ids.
  /// Driven by `ref.listen` (post-frame), never from `build`.
  void _reconcilePendingOrder(List<Item> liveNextActions) {
    final pending = _pendingOrderIds;
    if (pending == null) return;
    final liveIds = liveNextActions.map((e) => e.id).toList();
    // Clear once the write has landed (order matches) OR once the set of
    // actions itself changed (add / complete / delete / move-out): a
    // positional override is meaningless against a different membership and
    // would otherwise mask the real list indefinitely.
    final caughtUp = listEquals(liveIds, pending);
    final membershipChanged = !setEquals(liveIds.toSet(), pending.toSet());
    if (caughtUp || membershipChanged) {
      setState(() => _pendingOrderIds = null);
    }
  }

  void _onReorderNextActions(List<Item> shown, int oldIndex, int newIndex) {
    final ids = reorderedActionIds(
        shown.map((e) => e.id).toList(), oldIndex, newIndex);
    setState(() => _pendingOrderIds = ids);
    ref.read(reorderProjectActionsProvider).call(widget.projectId, ids);
  }

  Future<void> _addAction() async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.addNextActionTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.addNextActionHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (ok != true || ctrl.text.trim().isEmpty) return;
    final now = ref.read(clockProvider).now();
    await ref.read(itemRepositoryProvider).upsert(
          Item(
            id: ref.read(idGeneratorProvider).newId(),
            title: ctrl.text.trim(),
            status: ItemStatus.nextAction,
            projectId: widget.projectId,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Pulls already-captured next actions that belong to no project into
  /// this one — the missing inverse of "Add action" (which creates fresh).
  Future<void> _addExistingAction() async {
    final l10n = AppLocalizations.of(context);
    final loose = (ref.read(nextActionsProvider).valueOrNull ?? const <Item>[])
        .where((i) => i.projectId == null)
        .toList();
    if (loose.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noUnassignedActionsMessage),
        ),
      );
      return;
    }
    final selected = <String>{};
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.addExistingActions,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final a in loose)
                      CheckboxListTile(
                        value: selected.contains(a.id),
                        title: Text(a.title),
                        onChanged: (v) => setSheetState(() {
                          if (v ?? false) {
                            selected.add(a.id);
                          } else {
                            selected.remove(a.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(l10n.addCount(selected.length)),
                      onPressed: selected.isEmpty
                          ? null
                          : () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    final move = ref.read(moveItemToProjectProvider);
    for (final a in loose.where((i) => selected.contains(i.id))) {
      await move(a, widget.projectId);
    }
  }

  Future<void> _changeStatus(ProjectStatus s) async {
    if (_project == null) return;
    final updated =
        _project!.copyWith(status: s, updatedAt: ref.read(clockProvider).now());
    await ref.read(projectRepositoryProvider).upsert(updated);
    if (mounted) setState(() => _project = updated);
  }

  Future<void> _saveOutcome() async {
    if (_project == null) return;
    final updated = _project!.copyWith(
      outcome: _outcome.text.trim().isEmpty ? null : _outcome.text.trim(),
      updatedAt: ref.read(clockProvider).now(),
      clearOutcome: _outcome.text.trim().isEmpty,
    );
    await ref.read(projectRepositoryProvider).upsert(updated);
    setState(() => _project = updated);
  }

  Future<void> _editProject(List<Area> areas) async {
    if (_project == null) return;
    final l10n = AppLocalizations.of(context);
    final p = _project!;
    final titleCtrl = TextEditingController(text: p.title);
    String? areaId = p.areaId;
    DateTime? dueAt = p.dueAt;
    String? titleError;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.editProject,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.projectName,
                    hintText: l10n.projectNameHint,
                    errorText: titleError,
                  ),
                  onChanged: titleError == null
                      ? null
                      : (_) => setSheetState(() => titleError = null),
                ),
                if (areas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: areaId,
                    decoration: InputDecoration(
                      labelText: l10n.areaOfFocusOptional,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.unfiledOption),
                      ),
                      for (final a in areas)
                        DropdownMenuItem<String?>(
                          value: a.id,
                          child: Text(a.name),
                        ),
                    ],
                    onChanged: (v) => setSheetState(() => areaId = v),
                  ),
                ],
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.event_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.dueDate),
                  subtitle: Text(dueAt == null
                      ? l10n.notSet
                      : DateFormat.yMMMd().format(dueAt!)),
                  trailing: dueAt == null
                      ? const Icon(Icons.add)
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setSheetState(() => dueAt = null),
                        ),
                  onTap: () async {
                    final now = ref.read(clockProvider).now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365 * 5)),
                      initialDate: dueAt ?? now,
                    );
                    if (picked == null) return;
                    setSheetState(() => dueAt = picked);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(l10n.save),
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) {
                          setSheetState(
                            () => titleError = l10n.projectNameRequired,
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final title = titleCtrl.text.trim();
    titleCtrl.dispose();
    if (ok != true || title.isEmpty) return;
    final updated = p.copyWith(
      title: title,
      areaId: areaId,
      clearArea: areaId == null,
      dueAt: dueAt,
      clearDueAt: dueAt == null,
      updatedAt: ref.read(clockProvider).now(),
    );
    await ref.read(projectRepositoryProvider).upsert(updated);
    if (mounted) setState(() => _project = updated);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteProjectConfirmTitle),
        content: Text(l10n.deleteProjectWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(projectRepositoryProvider)
        .delete(widget.projectId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Reconcile the optimistic order off the build path: once the persisted
    // stream matches the pending drop, drop the override. Registered before
    // the early return so the subscription is consistent across all builds.
    ref.listen(projectItemsProvider(widget.projectId), (_, next) {
      final live = (next.valueOrNull ?? const <Item>[])
          .where((i) => i.status == ItemStatus.nextAction)
          .toList();
      _reconcilePendingOrder(live);
    });
    if (_project == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final p = _project!;
    final items =
        ref.watch(projectItemsProvider(widget.projectId)).valueOrNull ??
            const [];
    final liveNextActions =
        items.where((i) => i.status == ItemStatus.nextAction).toList();
    final nextActions = applyManualOrder(liveNextActions, _pendingOrderIds);
    final waiting =
        items.where((i) => i.status == ItemStatus.waiting).toList();
    final scheduled =
        items.where((i) => i.status == ItemStatus.calendar).toList();
    final reference =
        items.where((i) => i.status == ItemStatus.reference).toList();
    final someday =
        items.where((i) => i.status == ItemStatus.someday).toList();
    final needsClarifying =
        items.where((i) => i.status == ItemStatus.inbox).toList();
    final completed =
        ref.watch(completedProjectItemsProvider(widget.projectId)).valueOrNull ??
            const <Item>[];
    final movement = projectMovement(items);
    final showBanner =
        p.status == ProjectStatus.active && movement != ProjectMovement.healthy;
    final areas = ref.watch(areasProvider).valueOrNull ?? const <Area>[];
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            tooltip: l10n.addExistingActions,
            icon: const Icon(Icons.playlist_add),
            onPressed: _addExistingAction,
          ),
          IconButton(
            tooltip: l10n.editProject,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editProject(areas),
          ),
          PopupMenuButton<ProjectStatus>(
            tooltip: l10n.statusTooltip,
            initialValue: p.status,
            onSelected: _changeStatus,
            itemBuilder: (_) => [
              for (final s in ProjectStatus.values)
                PopupMenuItem(value: s, child: Text(s.label)),
            ],
            icon: const Icon(Icons.flag_outlined),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAction,
        icon: const Icon(Icons.add_task),
        label: Text(l10n.addActionFab),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (showBanner) _MovementBanner(movement: movement),
          if (showBanner) const SizedBox(height: 12),
          _SectionHeader(l10n.outcomeSection),
          TextField(
            controller: _outcome,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.projectOutcomeHint,
            ),
            onChanged: (_) => _saveOutcome(),
          ),
          const SizedBox(height: 20),
          _SectionHeader(l10n.nextActionsSection),
          if (nextActions.isEmpty)
            Text(
              l10n.noNextActionsMessage,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          if (nextActions.isNotEmpty)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: (oldIndex, newIndex) =>
                  _onReorderNextActions(nextActions, oldIndex, newIndex),
              children: [
                for (var i = 0; i < nextActions.length; i++)
                  Padding(
                    key: ValueKey(nextActions[i].id),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ItemCard(
                            item: nextActions[i],
                            showProject: false,
                            onTap: () =>
                                context.push('/item/${nextActions[i].id}'),
                            onComplete: () => completeWithUndo(
                                context, ref, nextActions[i].id),
                            onDelete: () => ref
                                .read(deleteItemProvider)
                                .call(nextActions[i].id),
                          ),
                        ),
                        ReorderableDragStartListener(
                          index: i,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                            child: Icon(Icons.drag_handle,
                                color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          if (waiting.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(l10n.waitingFor),
            for (final w in waiting) _liveCard(w),
          ],
          // Secondary lists. Everything tied to the project that isn't an
          // active commitment lives here, collapsed by default so the screen
          // stays focused on what to do next while still being the single
          // home for the project's reference, deferred and finished work.
          if (scheduled.isNotEmpty)
            _CollapsibleSection(
              key: const ValueKey('section-scheduled'),
              label: l10n.scheduled,
              count: scheduled.length,
              children: [for (final i in scheduled) _liveCard(i)],
            ),
          if (needsClarifying.isNotEmpty)
            _CollapsibleSection(
              key: const ValueKey('section-needs-clarifying'),
              label: l10n.needsClarifying,
              count: needsClarifying.length,
              children: [for (final i in needsClarifying) _liveCard(i)],
            ),
          if (reference.isNotEmpty)
            _CollapsibleSection(
              key: const ValueKey('section-reference'),
              label: l10n.reference,
              count: reference.length,
              children: [for (final i in reference) _liveCard(i)],
            ),
          if (someday.isNotEmpty)
            _CollapsibleSection(
              key: const ValueKey('section-someday'),
              label: l10n.someday,
              count: someday.length,
              children: [for (final i in someday) _liveCard(i)],
            ),
          if (completed.isNotEmpty)
            _CollapsibleSection(
              key: const ValueKey('section-completed'),
              label: l10n.completed,
              count: completed.length,
              children: [
                for (final i in completed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ItemCard(
                      item: i,
                      showProject: false,
                      onTap: () => context.push('/item/${i.id}'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// A card for a non-active project item (scheduled / inbox / reference /
  /// someday). Mirrors the "Waiting for" idiom: tap opens the item, swipe
  /// deletes. No complete affordance — these aren't next actions.
  Widget _liveCard(Item item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ItemCard(
          item: item,
          showProject: false,
          onTap: () => context.push('/item/${item.id}'),
          onDelete: () => ref.read(deleteItemProvider).call(item.id),
        ),
      );
}

/// A section whose body collapses behind its header. Used for the project's
/// secondary lists so a busy project doesn't bury its next actions. Default
/// collapsed; the count stays visible while collapsed so "Completed (5)"
/// reads as a progress signal at a glance.
class _CollapsibleSection extends StatefulWidget {
  const _CollapsibleSection({
    super.key,
    required this.label,
    required this.count,
    required this.children,
  });
  final String label;
  final int count;
  final List<Widget> children;

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  '${widget.label.toUpperCase()} (${widget.count})',
                  style: _sectionLabelStyle(scheme),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          ...widget.children,
        ],
      ],
    );
  }
}

/// The shared look of every section label on this screen (plain headers and
/// collapsible ones alike), so the two never drift apart.
TextStyle _sectionLabelStyle(ColorScheme scheme) => TextStyle(
      fontSize: 11.5,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w600,
      color: scheme.onSurfaceVariant,
    );

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label.toUpperCase(),
          style: _sectionLabelStyle(Theme.of(context).colorScheme),
        ),
      );
}

class _MovementBanner extends StatelessWidget {
  const _MovementBanner({required this.movement});
  final ProjectMovement movement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon, message) = switch (movement) {
      ProjectMovement.stalled => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.warning_amber_rounded,
          'Stalled — no next action, waiting, or scheduled item defined. '
              'Add a next action to get this moving.',
        ),
      ProjectMovement.awaiting => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.hourglass_bottom_rounded,
          'This project is moving through waiting or scheduled items only. '
              'Consider adding a follow-up next action so it doesn\'t stall '
              'when those clear.',
        ),
      ProjectMovement.healthy =>
        throw StateError('healthy movement should not render a banner'),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: fg)),
          ),
        ],
      ),
    );
  }
}
