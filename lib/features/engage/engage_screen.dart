import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../application/current_time.dart';
import '../../core/due_status.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../capture/capture_sheet.dart';
import '../common/complete_with_undo.dart';
import '../common/delete_with_undo.dart';
import '../common/empty_state.dart';
import '../common/error_view.dart';
import '../common/focus_star.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/item_card.dart';
import '../common/keyboard_shortcut_actions.dart';
import '../common/workspace_scroll_controller.dart';
import '../common/redecide_actions.dart';
import '../common/tag_picker.dart';
import '../projects/project_picker.dart';
import 'engage_controller.dart';
import 'today_controller.dart';

/// Time-available chips (in minutes). null = any.
List<({String label, int? minutes})> _timeChips(AppLocalizations l) => [
  (label: l.filterAnyTime, minutes: null),
  (label: l.filterUnder5m, minutes: 5),
  (label: l.filterUnder15m, minutes: 15),
  (label: l.filterUnder30m, minutes: 30),
  (label: l.filterUnder1h, minutes: 60),
];

String _energyLabel(AppLocalizations l, Energy e) => switch (e) {
  Energy.low => l.energyLow,
  Energy.medium => l.energyMedium,
  Energy.high => l.energyHigh,
};

class EngageScreen extends ConsumerStatefulWidget {
  const EngageScreen({
    this.onOpenItem,
    this.selectedItemId,
    this.initialScrollOffset = 0,
    super.key,
  });
  final ValueChanged<String>? onOpenItem;
  final String? selectedItemId;
  final double initialScrollOffset;

  @override
  ConsumerState<EngageScreen> createState() => _EngageScreenState();
}

class _EngageScreenState extends ConsumerState<EngageScreen> {
  late final WorkspaceScrollController _todayScroll;
  late final WorkspaceScrollController _nextScroll;

  @override
  void initState() {
    super.initState();
    final view = ref.read(doViewProvider);
    _todayScroll = WorkspaceScrollController(
      initialScrollOffset: view == DoView.today
          ? widget.initialScrollOffset
          : 0,
    );
    _nextScroll = WorkspaceScrollController(
      initialScrollOffset: view == DoView.nextActions
          ? widget.initialScrollOffset
          : 0,
    );
  }

  bool get _readOnly => widget.onOpenItem != null;

  @override
  void dispose() {
    _todayScroll.dispose();
    _nextScroll.dispose();
    super.dispose();
  }

  void _openItem(String id) {
    final open = widget.onOpenItem;
    if (open != null) {
      open(id);
    } else {
      final scroll = ref.read(doViewProvider) == DoView.today
          ? _todayScroll
          : _nextScroll;
      context.push(
        Uri(path: '/item/$id', queryParameters: {'workspace': 'do'}).toString(),
        extra: scroll.hasClients ? scroll.offset : 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(doViewProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.engageTitle),
        automaticallyImplyLeading: !_readOnly,
        actions: [
          if (!_readOnly)
            IconButton(
              tooltip: l.howGtdWorks,
              icon: const Icon(Icons.help_outline),
              onPressed: () =>
                  showGtdWorkflowSheet(context, highlight: GtdStage.engage),
            ),
          if (!_readOnly)
            SearchShortcutButton(
              onPressed: () => context.push('/search'),
            ),
        ],
      ),
      floatingActionButton: _readOnly
          ? null
          : CaptureShortcutButton(
              heroTag: 'engage-fab',
              onPressed: () => showCaptureSheet(context),
            ),
      body: Column(
        children: [
          // One line per label at any text size: the switch scrolls
          // sideways rather than wrapping into a tall block that would
          // crowd out the list on small phones.
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth - 32,
                ),
                child: SegmentedButton<DoView>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: DoView.today,
                      icon: const Icon(Icons.star_outline_rounded),
                      label: Text(l.doViewToday, softWrap: false),
                    ),
                    ButtonSegment(
                      value: DoView.nextActions,
                      icon: const Icon(Icons.checklist),
                      label: Text(l.doViewNextActions, softWrap: false),
                    ),
                  ],
                  selected: {view},
                  onSelectionChanged: (s) =>
                      ref.read(doViewProvider.notifier).set(s.single),
                ),
              ),
            ),
          ),
          Expanded(
            child: switch (view) {
              DoView.today => _TodayView(
                scrollController: _todayScroll,
                onOpenItem: _openItem,
                selectedItemId: widget.selectedItemId,
                readOnly: _readOnly,
              ),
              DoView.nextActions => _NextActionsView(
                scrollController: _nextScroll,
                onOpenItem: _openItem,
                selectedItemId: widget.selectedItemId,
                readOnly: _readOnly,
              ),
            },
          ),
        ],
      ),
    );
  }
}

/// The context/energy/time-filtered Next Actions list, with the hard
/// landscape on top. The Do tab's original view.
class _NextActionsView extends ConsumerWidget {
  const _NextActionsView({
    required this.scrollController,
    required this.onOpenItem,
    this.selectedItemId,
    this.readOnly = false,
  });
  final WorkspaceScrollController scrollController;
  final ValueChanged<String> onOpenItem;
  final String? selectedItemId;
  final bool readOnly;

  Widget _actionCard(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) => ItemCard(
    key: readOnly ? scrollController.itemKey(item.id) : null,
    item: item,
    highlighted: item.id == selectedItemId,
    onTap: item.id == selectedItemId ? null : () => onOpenItem(item.id),
    onComplete: readOnly ? null : () => completeWithUndo(context, ref, item.id),
    onDelete: readOnly ? null : () => deleteWithUndo(context, ref, item.id),
    onMoveToProject: readOnly
        ? null
        : () => pickAndMoveToProject(context, ref, item),
    onToggleFocus: readOnly ? null : () => toggleTodayFocus(context, ref, item),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(filteredNextActionsProvider);
    final totalActions =
        ref.watch(nextActionsProvider).valueOrNull?.length ?? 0;
    final band = ref.watch(engageCalendarBandProvider);
    final contexts = ref.watch(contextsProvider).valueOrNull ?? const [];
    final filter = ref.watch(engageFilterProvider);
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        _FilterStrip(contexts: contexts, filter: filter),
        const Divider(height: 1),
        Expanded(
          child: actions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => ErrorView(
              error: e,
              stackTrace: st,
              onRetry: () => ref.invalidate(nextActionsProvider),
            ),
            data: (filtered) {
              if (selectedItemId != null) {
                scrollController.prepare(selectedItemId, [
                  ...band.map((item) => item.id),
                  ...filtered.map((item) => item.id),
                ]);
              }
              final actionsEmpty = filtered.isEmpty;
              final hiddenCount = totalActions - filtered.length;

              // Only take over the whole screen when there is nothing at
              // all — never let an empty next-actions list hide the hard
              // landscape.
              if (band.isEmpty && actionsEmpty) {
                if (totalActions == 0) {
                  return EmptyState(
                    icon: Icons.task_alt,
                    title: l.engageEmptyTitle,
                    message: l.engageEmptyMessage,
                    action: readOnly
                        ? null
                        : FilledButton(
                            onPressed: () => context.go('/inbox'),
                            child: Text(l.engageOpenInbox),
                          ),
                  );
                }
                return EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: l.engageNoMatchTitle,
                  message: l.engageHiddenByFilters(hiddenCount),
                  action: FilledButton(
                    onPressed: ref.read(engageFilterProvider.notifier).clear,
                    child: Text(l.clearFilters),
                  ),
                );
              }

              return WorkspaceListViewport(
                controller: scrollController,
                child: ListView(
                  key: const PageStorageKey('do-next-actions'),
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    if (band.isNotEmpty) ...[
                      _HardLandscapeBand(
                        items: band,
                        onOpenItem: onOpenItem,
                        selectedItemId: selectedItemId,
                        readOnly: readOnly,
                        scrollController: scrollController,
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (!actionsEmpty)
                      // Stagger only the discretionary list; the band above
                      // is static (it doesn't react to the filters).
                      AnimationLimiter(
                        child: Column(
                          children: [
                            for (var i = 0; i < filtered.length; i++) ...[
                              if (i != 0) const SizedBox(height: 8),
                              if (readOnly)
                                _actionCard(context, ref, filtered[i])
                              else
                                AnimationConfiguration.staggeredList(
                                  position: i,
                                  duration: const Duration(milliseconds: 250),
                                  child: SlideAnimation(
                                    verticalOffset: 16,
                                    child: FadeInAnimation(
                                      child: _actionCard(
                                        context,
                                        ref,
                                        filtered[i],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Text(
                              totalActions == 0
                                  ? l.engageInlineEmpty
                                  : l.engageHiddenByFilters(hiddenCount),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                            if (totalActions > 0)
                              TextButton(
                                onPressed: ref
                                    .read(engageFilterProvider.notifier)
                                    .clear,
                                child: Text(l.clearFilters),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// GTD Engage is "calendar first, then next actions". This band puts the
/// Calendar (the hard landscape: overdue + due-today calendar items) at the top of the Do
/// screen, on a distinct surface so it reads as separate from — and is not
/// touched by — the context/energy/time filters below. Overdue items carry
/// the explicit re-decide actions; today's items support tap + swipe like
/// any card.
class _HardLandscapeBand extends ConsumerWidget {
  const _HardLandscapeBand({
    required this.items,
    required this.onOpenItem,
    this.selectedItemId,
    this.readOnly = false,
    required this.scrollController,
  });
  final WorkspaceScrollController scrollController;
  final ValueChanged<String> onOpenItem;
  final String? selectedItemId;
  final bool readOnly;
  final List<Item> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final calendar = context.gtd.calendar;
    final now = ref.watch(currentTimeProvider);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: calendar.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // One line: icon, title + muted subtitle (wraps/ellipsizes at
          // large text sizes), and the count pill pinned at the end.
          Row(
            children: [
              Icon(Icons.event_outlined, color: calendar, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: l.hardLandscape,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: ' · ${l.hardLandscapeSubtitle}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: calendar.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            _BandTile(
              item: item,
              onOpenItem: onOpenItem,
              selected: item.id == selectedItemId,
              readOnly: readOnly,
              itemKey: readOnly ? scrollController.itemKey(item.id) : null,
              overdue: dueStatusOf(item.dueAt!, now).phase == DuePhase.overdue,
            ),
        ],
      ),
    );
  }
}

/// One row of the Calendar band. No Today star: calendar items due today or
/// overdue are on Today by definition. Overdue items re-decide via the
/// explicit [ReDecideActions]; today's items keep the normal
/// swipe-to-complete affordance.
class _BandTile extends ConsumerWidget {
  const _BandTile({
    required this.item,
    required this.overdue,
    required this.onOpenItem,
    this.selected = false,
    this.readOnly = false,
    this.itemKey,
  });
  final Key? itemKey;
  final ValueChanged<String> onOpenItem;
  final bool selected;
  final bool readOnly;
  final Item item;
  final bool overdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemCard(
          key: itemKey,
          item: item,
          highlighted: selected,
          onTap: selected ? null : () => onOpenItem(item.id),
          onComplete: overdue || readOnly
              ? null
              : () => completeWithUndo(context, ref, item.id),
        ),
        if (overdue && !readOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ReDecideActions(item: item),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _FilterStrip extends ConsumerWidget {
  const _FilterStrip({required this.contexts, required this.filter});
  final List<GtdContext> contexts;
  final EngageFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(engageFilterProvider.notifier);
    final l = AppLocalizations.of(context);
    final tags = ref.watch(tagsProvider).valueOrNull ?? const [];
    final tag = ref.watch(engageFilterTagProvider);
    final contextChips = [
      if (!filter.isEmpty)
        ActionChip(
          key: const Key('engage-filter-reset'),
          avatar: const Icon(Icons.filter_alt_off_outlined, size: 16),
          label: Text(l.filterReset),
          onPressed: controller.clear,
        ),
      FilterChip(
        selected: filter.contextId == null,
        label: Text(l.filterAllContexts),
        onSelected: (_) => controller.setContext(null),
      ),
      for (final c in contexts)
        FilterChip(
          selected: filter.contextId == c.id,
          label: Text(c.name),
          onSelected: (sel) => controller.setContext(sel ? c.id : null),
        ),
      if (tags.isNotEmpty)
        FilterChip(
          selected: tag != null,
          showCheckmark: false,
          avatar: Icon(
            tag == null ? Icons.sell_outlined : tagIcon(tag),
            size: 16,
          ),
          label: Text(tag?.name ?? l.filterTag),
          onSelected: (_) => _pickTag(context, ref, tags, tag),
        ),
    ];
    final timeEnergyChip = FilterChip(
      key: const Key('engage-filter-time-energy'),
      selected: filter.maxTimeMinutes != null || filter.energy != null,
      showCheckmark: false,
      avatar: const Icon(Icons.tune, size: 16),
      label: Text(
        _timeEnergySummary(l, filter),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onSelected: (_) => _showTimeEnergySheet(context),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Keep enough space for both the control and several context chips.
          // Use the pane's width so a narrow editor sidebar stays scrollable.
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final pinTimeEnergy =
              constraints.maxWidth >=
              480 * textScale.clamp(1.0, double.infinity);
          return Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.only(
                    start: 12,
                    end: pinTimeEnergy ? 0 : 12,
                  ),
                  child: Row(
                    spacing: 6,
                    children: [
                      ...contextChips,
                      if (!pinTimeEnergy) timeEnergyChip,
                    ],
                  ),
                ),
              ),
              if (pinTimeEnergy)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6, end: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * .4,
                    ),
                    child: timeEnergyChip,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// "Time & energy" summary for the strip chip: the active choices, or the
/// generic label when neither is set.
String _timeEnergySummary(AppLocalizations l, EngageFilter filter) {
  final parts = [
    if (filter.maxTimeMinutes != null)
      _timeChips(l).firstWhere((t) => t.minutes == filter.maxTimeMinutes).label,
    if (filter.energy != null) _energyLabel(l, filter.energy!),
  ];
  return parts.isEmpty ? l.filterTimeEnergy : parts.join(' · ');
}

/// Time and energy filters, applied live; Done just closes the sheet.
Future<void> _showTimeEnergySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const _TimeEnergySheet(),
    );

class _TimeEnergySheet extends ConsumerWidget {
  const _TimeEnergySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final filter = ref.watch(engageFilterProvider);
    final controller = ref.read(engageFilterProvider.notifier);
    final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(l.timeEstimateSection, style: headerStyle),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _timeChips(l))
                FilterChip(
                  selected: filter.maxTimeMinutes == t.minutes,
                  label: Text(t.label),
                  onSelected: (_) => controller.setMaxTime(t.minutes),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(l.energySection, style: headerStyle),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in [null, ...Energy.values])
                FilterChip(
                  selected: filter.energy == e,
                  avatar: e == null
                      ? null
                      : Icon(switch (e) {
                          Energy.low => Icons.battery_2_bar,
                          Energy.medium => Icons.battery_4_bar,
                          Energy.high => Icons.battery_full,
                        }, size: 16),
                  label: Text(
                    e == null ? l.filterAnyEnergy : _energyLabel(l, e),
                  ),
                  onSelected: (_) => controller.setEnergy(e),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.done),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-choice tag filter: *Any tag* or one tag.
Future<void> _pickTag(
  BuildContext context,
  WidgetRef ref,
  List<Tag> tags,
  Tag? current,
) async {
  final picked = await showModalBottomSheet<(String?,)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final check = Icon(
        Icons.check,
        color: Theme.of(sheetContext).colorScheme.primary,
      );
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: Text(l10n.filterAnyTag),
            trailing: current == null ? check : null,
            onTap: () => Navigator.pop(sheetContext, (null,)),
          ),
          for (final t in tags)
            ListTile(
              leading: Icon(tagIcon(t)),
              title: Text(t.name),
              trailing: current?.id == t.id ? check : null,
              onTap: () => Navigator.pop(sheetContext, (t.id,)),
            ),
        ],
      );
    },
  );
  if (picked == null) return;
  ref.read(engageFilterProvider.notifier).setTag(picked.$1);
}

/// Today (ADR 0007): the plan card (with any carry-over awaiting a decision)
/// until today is planned, the Calendar band, then the Items committed to today.
class _TodayView extends ConsumerWidget {
  const _TodayView({
    required this.scrollController,
    required this.onOpenItem,
    this.selectedItemId,
    this.readOnly = false,
  });
  final WorkspaceScrollController scrollController;
  final ValueChanged<String> onOpenItem;
  final String? selectedItemId;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayViewProvider);
    final band = ref.watch(engageCalendarBandProvider);
    final planned = ref.watch(plannedTodayProvider);
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return today.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => ErrorView(
        error: e,
        stackTrace: st,
        onRetry: () => ref.invalidate(todayViewProvider),
      ),
      data: (view) {
        if (selectedItemId != null) {
          scrollController.prepare(selectedItemId, [
            ...band.map((item) => item.id),
            ...view.focused.map((item) => item.id),
          ]);
        }
        // Carry-over only exists before the day is planned (Start my day
        // resolves it), so the card carries it. Should it ever exist while
        // planned, the card comes back so it is never hidden.
        final showPlanCard =
            !readOnly && (!planned || view.carriedOver.isNotEmpty);
        final nothing = band.isEmpty && view.focused.isEmpty;
        if (nothing &&
            planned &&
            view.carriedOver.isEmpty &&
            view.doneToday == 0) {
          return EmptyState(
            icon: Icons.star_outline_rounded,
            title: l.todayEmptyTitle,
            message: l.todayEmptyMessage,
            action: readOnly
                ? null
                : OutlinedButton(
                    onPressed: () => context.push('/today/plan'),
                    child: Text(l.todayPlanAction),
                  ),
          );
        }
        return WorkspaceListViewport(
          controller: scrollController,
          child: ListView(
            key: const PageStorageKey('do-today'),
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              if (showPlanCard) ...[
                _PlanCard(carryOverCount: view.carriedOver.length),
                const SizedBox(height: 12),
              ],
              if (band.isNotEmpty) ...[
                _HardLandscapeBand(
                  items: band,
                  onOpenItem: onOpenItem,
                  selectedItemId: selectedItemId,
                  readOnly: readOnly,
                  scrollController: scrollController,
                ),
                const SizedBox(height: 20),
              ],
              if (view.focused.isNotEmpty) ...[
                Semantics(
                  header: true,
                  child: Text(
                    l.todayFocusHeader,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in view.focused) ...[
                  ItemCard(
                    key: readOnly
                        ? scrollController.itemKey(item.id)
                        : ValueKey('today-${item.id}'),
                    item: item,
                    highlighted: item.id == selectedItemId,
                    onTap: item.id == selectedItemId
                        ? null
                        : () => onOpenItem(item.id),
                    onComplete: readOnly
                        ? null
                        : () => completeWithUndo(context, ref, item.id),
                    onToggleFocus: readOnly
                        ? null
                        : () => toggleTodayFocus(context, ref, item),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (!showPlanCard && view.focused.isEmpty && view.doneToday == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l.todayEmptyMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              if (view.doneToday > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 18, color: scheme.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.todayDoneCount(view.doneToday),
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Invites the short daily plan until one is finished today, and says how
/// many carried-over Items wait for a keep-or-clear decision there.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.carryOverCount});

  /// Items focused on an earlier day that still need a keep-or-clear
  /// decision; 0 hides the line.
  final int carryOverCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.todayPlanCardTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.todayPlanCardBody,
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
            if (carryOverCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.todayCarryOverLine(carryOverCount),
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => context.push('/today/plan'),
                child: Text(l.todayPlanAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
