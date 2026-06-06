import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/due_status.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../capture/capture_sheet.dart';
import '../common/complete_with_undo.dart';
import '../common/empty_state.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/item_card.dart';
import '../common/redecide_actions.dart';
import '../projects/project_picker.dart';
import 'engage_controller.dart';

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

class EngageScreen extends ConsumerWidget {
  const EngageScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l.engageTitle),
        actions: [
          IconButton(
            tooltip: l.howGtdWorks,
            icon: const Icon(Icons.help_outline),
            onPressed: () =>
                showGtdWorkflowSheet(context, highlight: GtdStage.engage),
          ),
          IconButton(
            tooltip: l.search,
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'engage-fab',
        onPressed: () => showCaptureSheet(context),
        tooltip: l.capture,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _FilterStrip(contexts: contexts, filter: filter),
          const Divider(height: 1),
          Expanded(
            child: actions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (filtered) {
                final actionsEmpty = filtered.isEmpty;

                // Only take over the whole screen when there is nothing at
                // all — never let an empty next-actions list hide the hard
                // landscape.
                if (band.isEmpty && actionsEmpty) {
                  if (totalActions == 0) {
                    return EmptyState(
                      icon: Icons.task_alt,
                      title: l.engageEmptyTitle,
                      message: l.engageEmptyMessage,
                      action: FilledButton(
                        onPressed: () => context.go('/inbox'),
                        child: Text(l.engageOpenInbox),
                      ),
                    );
                  }
                  return EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: l.engageNoMatchTitle,
                    message: l.engageNoMatchMessage,
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    if (band.isNotEmpty) ...[
                      _HardLandscapeBand(items: band),
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
                              AnimationConfiguration.staggeredList(
                                position: i,
                                duration: const Duration(milliseconds: 250),
                                child: SlideAnimation(
                                  verticalOffset: 16,
                                  child: FadeInAnimation(
                                    child: ItemCard(
                                      item: filtered[i],
                                      onTap: () => context
                                          .push('/item/${filtered[i].id}'),
                                      onComplete: () => completeWithUndo(
                                          context, ref, filtered[i].id),
                                      onDelete: () => ref
                                          .read(deleteItemProvider)
                                          .call(filtered[i].id),
                                      onMoveToProject: () =>
                                          pickAndMoveToProject(
                                              context, ref, filtered[i]),
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
                        child: Text(
                          totalActions == 0
                              ? l.engageInlineEmpty
                              : l.engageNoMatchMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// GTD Engage is "calendar first, then next actions". This band puts the
/// hard landscape (overdue + due-today calendar items) at the top of the Do
/// screen, on a distinct surface so it reads as separate from — and is not
/// touched by — the context/energy/time filters below. Overdue items carry
/// the explicit re-decide actions; today's items support tap + swipe like
/// any card.
class _HardLandscapeBand extends ConsumerWidget {
  const _HardLandscapeBand({required this.items});
  final List<Item> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final calendar = context.gtd.calendar;
    final now = ref.watch(clockProvider).now();
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
          Row(
            children: [
              Icon(Icons.event_outlined, color: calendar, size: 18),
              const SizedBox(width: 8),
              Text(l.hardLandscape,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(width: 6),
              Text(l.hardLandscapeSubtitle,
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            _BandTile(
              item: item,
              overdue:
                  dueStatusOf(item.dueAt!, now).phase == DuePhase.overdue,
            ),
        ],
      ),
    );
  }
}

/// One row of the hard-landscape band. Overdue items re-decide via the
/// explicit [ReDecideActions]; today's items keep the normal
/// swipe-to-complete affordance.
class _BandTile extends ConsumerWidget {
  const _BandTile({required this.item, required this.overdue});
  final Item item;
  final bool overdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemCard(
          item: item,
          onTap: () => context.push('/item/${item.id}'),
          onComplete:
              overdue ? null : () => completeWithUndo(context, ref, item.id),
        ),
        if (overdue)
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
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
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final t in _timeChips(l)) ...[
                  FilterChip(
                    selected: filter.maxTimeMinutes == t.minutes,
                    label: Text(t.label),
                    onSelected: (_) => controller.setMaxTime(t.minutes),
                  ),
                  const SizedBox(width: 6),
                ],
                const SizedBox(width: 6),
                for (final e in [null, ...Energy.values]) ...[
                  FilterChip(
                    selected: filter.energy == e,
                    avatar: e == null
                        ? null
                        : Icon(
                            switch (e) {
                              Energy.low => Icons.battery_2_bar,
                              Energy.medium => Icons.battery_4_bar,
                              Energy.high => Icons.battery_full,
                            },
                            size: 16,
                          ),
                    label:
                        Text(e == null ? l.filterAnyEnergy : _energyLabel(l, e)),
                    onSelected: (_) => controller.setEnergy(e),
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
