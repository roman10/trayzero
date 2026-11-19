import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../application/current_time.dart';
import '../../application/providers.dart';
import '../../core/due_status.dart';
import '../../domain/entities/entities.dart';
import '../../domain/today_focus.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/error_view.dart';
import '../common/focus_star.dart';
import '../common/item_card_appearance.dart';
import '../common/item_metadata_label.dart';
import '../common/localized_dates.dart';
import '../common/localized_due_label.dart';
import 'today_controller.dart';

/// The short daily plan (ADR 0007): one scrolling screen of suggestions the
/// user stars for today. Stars write immediately; "Start my day" returns
/// un-kept carry-over to its lists and logs the plan.
class DailyPlanScreen extends ConsumerStatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  ConsumerState<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends ConsumerState<DailyPlanScreen> {
  /// Carry-over captured on first data, so rows don't vanish or jump while
  /// the user keeps them (keeping re-stamps them to today).
  List<Item>? _carryOver;
  bool _saving = false;

  Future<void> _toggle(Item item, bool focused) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = AppLocalizations.of(context).focusError;
    try {
      await ref.read(setTodayFocusProvider).call([item], focused: !focused);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _keepAll(List<Item> items) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = AppLocalizations.of(context).focusError;
    try {
      await ref.read(setTodayFocusProvider).call(items, focused: true);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _startDay(Map<String, Item> live, DateTime now) async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    // Resolved before awaiting so Undo never reads a disposed ref.
    final focus = ref.read(setTodayFocusProvider);
    final notKept = [
      for (final item in _carryOver ?? const <Item>[])
        if (live[item.id] case final current?)
          if (isCarriedOver(current, now)) current,
    ];
    setState(() => _saving = true);
    try {
      final cleared = await ref
          .read(finishDailyReviewProvider)
          .call(notKept: notKept);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            showCloseIcon: true,
            content: Text(
              cleared.isEmpty
                  ? l.planDoneSnackbar
                  : l.planClearedSnackbar(cleared.length),
            ),
            persist: false,
            duration: const Duration(seconds: 5),
            action: cleared.isEmpty
                ? null
                : SnackBarAction(
                    label: l.undo,
                    onPressed: () => focus.restore(cleared),
                  ),
          ),
        );
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.planSaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(currentTimeProvider);
    final focusedSource = ref.watch(focusedItemsProvider);
    final band = ref.watch(engageCalendarBandProvider);
    final waiting = ref.watch(waitingForProvider).valueOrNull ?? const [];
    final actions = ref.watch(nextActionsProvider).valueOrNull ?? const [];

    final focusedItems = focusedSource.valueOrNull;
    if (focusedItems == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.todayPlanCardTitle)),
        body: focusedSource.hasError
            ? ErrorView(
                error: focusedSource.error,
                stackTrace: focusedSource.stackTrace,
                onRetry: () => ref.invalidate(focusedItemsProvider),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final live = {for (final i in focusedItems) i.id: i};
    // Calendar items due today or overdue are on Today by definition, so
    // they never need a carry-over decision.
    final bandIds = {for (final i in band) i.id};
    final carryOver = _carryOver ??= [
      for (final i in focusedItems)
        if (isCarriedOver(i, now) && !bandIds.contains(i.id)) i,
    ];
    final plan = buildDailyPlan(
      band: band,
      waiting: waiting,
      nextActions: actions,
      now: now,
      exclude: {for (final i in carryOver) i.id},
    );
    final focusedCount = focusedItems
        .where(
          (i) =>
              canFocus(i) && isFocusedToday(i, now) && !bandIds.contains(i.id),
        )
        .length;
    bool isOn(Item i) {
      final current = live[i.id];
      return current != null && isFocusedToday(current, now);
    }

    final unkept = carryOver.where((i) => !isOn(i)).toList();

    Widget rows(List<Item> items) => Column(
      children: [
        for (final item in items)
          _PlanRow(
            key: ValueKey('plan-${item.id}'),
            item: live[item.id] ?? item,
            focused: isOn(item),
            onOpen: () => context.push('/item/${item.id}'),
            onToggle: () => _toggle(item, isOn(item)),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.todayPlanCardTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.planTodayIntro),
          ),
          if (carryOver.isNotEmpty) ...[
            _SectionHeader(
              title: l.planSectionCarryOver,
              trailing: unkept.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () => _keepAll(unkept),
                      child: Text(l.planKeepAll),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                l.planCarryOverHint,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            rows(carryOver),
          ],
          if (plan.calendar.isNotEmpty) ...[
            _SectionHeader(title: l.planSectionCalendar),
            for (final item in plan.calendar)
              _PlanRow(
                key: ValueKey('plan-${item.id}'),
                item: item,
                focused: false,
                automatic: true,
                onOpen: () => context.push('/item/${item.id}'),
              ),
          ],
          if (plan.waiting.isNotEmpty) ...[
            _SectionHeader(title: l.planSectionWaiting),
            rows(plan.waiting),
          ],
          if (plan.available.isNotEmpty) ...[
            _SectionHeader(title: l.planSectionAvailable),
            rows(plan.available),
          ],
          if (plan.nextActions.isNotEmpty) ...[
            _SectionHeader(title: l.doViewNextActions),
            rows(plan.nextActions),
          ],
          if (carryOver.isEmpty && plan.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l.planEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          // Keep the count inside the primary action rather than a second
          // fixed block that consumes the viewport at large text sizes.
          child: MergeSemantics(
            child: Semantics(
              liveRegion: true,
              value: l.planFocusedCount(focusedCount),
              child: FilledButton(
                onPressed: _saving ? null : () => _startDay(live, now),
                child: Row(
                  children: [
                    Expanded(child: Text(l.planStartDay)),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: l.planFocusedCount(focusedCount),
                      excludeFromSemantics: true,
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 20),
                            const SizedBox(width: 4),
                            Text('$focusedCount'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Opening an item and changing its Today commitment have separate targets.
/// Metadata stays consistent across suggestions and automatic calendar rows.
class _PlanRow extends ConsumerWidget {
  const _PlanRow({
    required this.item,
    required this.focused,
    required this.onOpen,
    this.onToggle,
    this.automatic = false,
    super.key,
  });

  final Item item;
  final bool focused;
  final bool automatic;
  final VoidCallback onOpen;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(currentTimeProvider);
    final entities = ref.watch(dailyPlanEntitiesProvider);
    final project = entities.projects[item.projectId];
    final gtdContext = entities.contexts[item.contextId];
    final scheme = Theme.of(context).colorScheme;
    final metadata = <({String label, IconData icon, Color color})>[];
    void meta(String label, IconData icon, [Color? color]) => metadata.add((
      label: label,
      icon: icon,
      color: (color ?? scheme.onSurfaceVariant).foregroundOn(
        scheme.surfaceContainerLow,
      ),
    ));
    final due = item.dueAt?.toLocal();
    final start = item.deferUntil?.toLocal();
    String date(DateTime at) => localizedDeferLabel(at, l, now: now);

    if (item.status == ItemStatus.waiting) {
      final person = item.waitingOn?.trim();
      meta(
        person == null || person.isEmpty
            ? l.waitingFor
            : l.waitingOnPerson(person),
        Icons.hourglass_top,
        context.gtd.waiting,
      );
      final followUp = start ?? due;
      if (followUp != null) {
        meta(l.planFollowUpOnDate(date(followUp)), Icons.event_outlined);
      }
    } else if (item.status == ItemStatus.calendar) {
      meta(
        due == null ? l.scheduled : l.planScheduledOnDate(date(due)),
        Icons.event_outlined,
      );
    } else if (start != null &&
        !start.isBefore(DateTime(now.year, now.month, now.day))) {
      meta(
        l.startsOnDate(date(start)),
        Icons.schedule_send_outlined,
        scheme.secondary,
      );
    }
    // Waiting uses defer (else due) as its follow-up date. Preserve a
    // separate deadline when set instead of labelling it a start date.
    if (due != null &&
        item.status != ItemStatus.calendar &&
        (item.status != ItemStatus.waiting ||
            (start != null && start != due))) {
      meta(
        dueStatusOf(due, now).phase == DuePhase.upcoming
            ? l.dueOnDate(date(due))
            : localizedDueChipLabel(due, now, l),
        Icons.event_outlined,
        scheme.error,
      );
    }
    if (item.status == ItemStatus.calendar &&
        due != null &&
        dueStatusOf(due, now).phase == DuePhase.overdue) {
      meta(
        localizedDueChipLabel(due, now, l),
        Icons.event_busy_outlined,
        scheme.error,
      );
    }
    if (gtdContext != null) {
      meta(
        gtdContext.name,
        Icons.place_outlined,
        Color(gtdContext.color).onSurfaceOf(scheme.brightness),
      );
    }
    final minutes = item.timeEstimateMinutes ?? (item.isTwoMin ? 2 : null);
    if (minutes != null) {
      meta(l.minutesShort(minutes), Icons.schedule_outlined, scheme.secondary);
    }

    final identity = [
      item.title,
      if (project != null) project.title,
      ...metadata.map((entry) => entry.label),
    ].join(', ');
    final textTheme = Theme.of(context).textTheme;
    final metadataStyle =
        textTheme.bodySmall?.copyWith(fontSize: 12.5, height: 1.3) ??
        const TextStyle(fontSize: 12.5, height: 1.3);
    const inset = ItemCardAppearance.padding + ItemCardAppearance.borderWidth;
    const starOverhang = (FocusStar.targetSize - FocusStar.iconSize) / 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Stack(
        children: [
          Semantics(
            button: true,
            child: InkWell(
              onTap: onOpen,
              borderRadius: ItemCardAppearance.radius,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ItemCardAppearance.padding),
                decoration: ItemCardAppearance.decoration(scheme),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: ItemCardAppearance.titleStyle,
                          ),
                        ),
                        if (!automatic)
                          const SizedBox(
                            width: 10 + FocusStar.iconSize,
                            height:
                                FocusStar.targetSize -
                                ItemCardAppearance.padding,
                          ),
                      ],
                    ),
                    if (project != null) ...[
                      const SizedBox(height: 6),
                      ItemMetadataLabel(
                        text: project.title,
                        icon: Icons.folder_outlined,
                        iconSize: 16,
                        style: metadataStyle.copyWith(color: scheme.primary),
                      ),
                    ],
                    if (metadata.isNotEmpty || automatic) ...[
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            for (final entry in metadata)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: ItemMetadataLabel(
                                  text: entry.label,
                                  icon: entry.icon,
                                  iconSize: 16,
                                  style: metadataStyle.copyWith(
                                    color: entry.color,
                                  ),
                                ),
                              ),
                            if (automatic)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: ItemMetadataLabel(
                                  text: l.planOnToday,
                                  icon: Icons.today_outlined,
                                  iconSize: 16,
                                  style: metadataStyle.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (!automatic)
            Positioned(
              top: inset - starOverhang,
              right: inset - starOverhang,
              child: FocusStar(
                title: identity,
                focused: focused,
                onToggle: onToggle!,
              ),
            ),
        ],
      ),
    );
  }
}
