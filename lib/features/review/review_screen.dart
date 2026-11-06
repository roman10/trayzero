import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/complete_with_undo.dart';
import '../common/delete_with_undo.dart';
import '../common/focus_star.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/item_card.dart';
import '../common/redecide_actions.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastDue = ref.watch(pastDueItemsProvider);
    final calendar = ref.watch(calendarItemsProvider);
    final waiting = ref.watch(waitingForProvider).valueOrNull ?? const [];
    final someday = ref.watch(somedayProvider).valueOrNull ?? const [];
    final reference = ref.watch(referenceProvider).valueOrNull ?? const [];
    final completed =
        ref.watch(completedThisWeekProvider).valueOrNull ?? const [];
    final agendas = ref.watch(agendasProvider);
    final gtd = context.gtd;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.reviewTitle),
        actions: [
          IconButton(
            tooltip: l.howGtdWorks,
            icon: const Icon(Icons.help_outline),
            onPressed: () =>
                showGtdWorkflowSheet(context, highlight: GtdStage.reflect),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _WeeklyReviewCard(),
          const SizedBox(height: 20),
          if (pastDue.isNotEmpty) _NeedsReDecisionBucket(items: pastDue),
          _Bucket(
            title: l.calendar,
            icon: Icons.event_outlined,
            color: gtd.calendar,
            count: calendar.length,
            items: calendar,
            emptyMsg: l.calendarEmpty,
          ),
          _Bucket(
            title: l.waitingFor,
            icon: Icons.hourglass_top_outlined,
            color: gtd.waiting,
            count: waiting.length,
            items: waiting,
            emptyMsg: l.waitingForEmpty,
          ),
          // GTD reviews Agendas beside Waiting For (ADR 0010); the bucket
          // exists only while some tag is a person.
          if (agendas.isNotEmpty)
            _Bucket(
              title: l.agendasTitle,
              icon: Icons.people_outline,
              color: gtd.waiting,
              count: agendas.length,
              subtitle: l.agendasPeopleCount(agendas.length),
              items: const [],
              emptyMsg: '',
              children: [
                for (final a in agendas)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline),
                    title: Text(a.person.name),
                    trailing: Text(
                      '${a.count}',
                      semanticsLabel: l.tagOpenItems(a.count),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () => context.push('/agenda/${a.person.id}'),
                  ),
              ],
            ),
          _Bucket(
            title: l.somedayMaybe,
            icon: Icons.cloud_outlined,
            color: gtd.someday,
            count: someday.length,
            items: someday,
            emptyMsg: l.somedayEmpty,
          ),
          _Bucket(
            title: l.reference,
            icon: Icons.bookmark_outline,
            color: gtd.reference,
            count: reference.length,
            items: reference,
            emptyMsg: l.referenceEmpty,
          ),
          _Bucket(
            title: l.completedThisWeek,
            icon: Icons.task_alt,
            color: gtd.nextAction,
            count: completed.length,
            items: completed,
            emptyMsg: l.completedThisWeekEmpty,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}

class _WeeklyReviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final incomplete = ref.watch(incompleteWeeklyReviewProvider).valueOrNull;
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/review/weekly'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh, color: scheme.onPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incomplete == null
                          ? l.weeklyReviewCardTitle
                          : l.weeklyReviewResume,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.weeklyReviewCardSubtitle,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer
                            .withValues(alpha: 0.85),
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
    );
  }
}

class _Bucket extends ConsumerWidget {
  const _Bucket({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.items,
    required this.emptyMsg,
    this.readOnly = false,
    this.subtitle,
    this.children,
  });
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final List<Item> items;
  final String emptyMsg;

  /// Completed items are shown for reference only — no swipe-to-complete or
  /// delete affordances. Tapping still opens the item (where it can be
  /// reopened).
  final bool readOnly;

  /// Replaces the "N items" subtitle.
  final String? subtitle;

  /// Rows shown instead of [items], for buckets that list something else.
  final List<Widget>? children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            childrenPadding:
                const EdgeInsets.fromLTRB(14, 0, 14, 12),
            shape: const RoundedRectangleBorder(
                side: BorderSide.none),
            collapsedShape: const RoundedRectangleBorder(
                side: BorderSide.none),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              subtitle ?? AppLocalizations.of(context).bucketCount(count),
            ),
            children: [
              ...?children,
              if (children == null && items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    emptyMsg,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              for (final item in items) ...[
                ItemCard(
                  item: item,
                  onTap: () => context.push('/item/${item.id}'),
                  onComplete: readOnly
                      ? null
                      : () => completeWithUndo(context, ref, item.id),
                  onDelete: readOnly
                      ? null
                      : () => deleteWithUndo(context, ref, item.id),
                  onToggleFocus: readOnly
                      ? null
                      : () => toggleTodayFocus(context, ref, item),
                ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Past-due items: a missed hard-landscape date is a decision, not a passive
/// red badge. Reuses the [_Bucket] visual chrome but gives every item three
/// explicit GTD re-decide actions instead of swipe gestures.
class _NeedsReDecisionBucket extends ConsumerWidget {
  const _NeedsReDecisionBucket({required this.items});
  final List<Item> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final count = items.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            collapsedShape:
                const RoundedRectangleBorder(side: BorderSide.none),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.event_busy, color: scheme.error, size: 20),
            ),
            title: Text(
              l.needsReDecision,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(l.pastDueCount(count)),
            children: [
              for (final item in items) ...[
                ItemCard(
                  item: item,
                  onTap: () => context.push('/item/${item.id}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ReDecideActions(item: item),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
