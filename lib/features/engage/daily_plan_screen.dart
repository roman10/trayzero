import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/current_time.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../domain/today_focus.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/error_view.dart';
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
              canFocus(i) &&
              isFocusedToday(i, now) &&
              !bandIds.contains(i.id),
        )
        .length;
    bool isOn(Item i) {
      final current = live[i.id];
      return current != null && isFocusedToday(current, now);
    }

    final unkept = carryOver.where((i) => !isOn(i)).toList();

    Widget rows(List<Item> items, {String Function(Item)? subtitle}) => Column(
      children: [
        for (final item in items)
          _PlanRow(
            key: ValueKey('plan-${item.id}'),
            item: item,
            focused: isOn(item),
            subtitle: subtitle?.call(item),
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
              _CalendarRow(
                key: ValueKey('plan-${item.id}'),
                item: item,
                subtitle: localizedDueChipLabel(item.dueAt!, now, l),
                onTap: () => context.push('/item/${item.id}'),
              ),
          ],
          if (plan.waiting.isNotEmpty) ...[
            _SectionHeader(title: l.planSectionWaiting),
            rows(
              plan.waiting,
              subtitle: (i) => i.waitingOn == null || i.waitingOn!.isEmpty
                  ? ''
                  : l.waitingOnPerson(i.waitingOn!),
            ),
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
          // Wraps the button below the count at large text sizes.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(l.planFocusedCount(focusedCount)),
              ),
              FilledButton(
                onPressed: _saving ? null : () => _startDay(live, now),
                child: Text(l.planStartDay),
              ),
            ],
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
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// One suggestion: the whole row toggles the star, so the target is the
/// full row height rather than the icon.
class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.item,
    required this.focused,
    required this.onToggle,
    this.subtitle,
    super.key,
  });

  final Item item;
  final bool focused;
  final String? subtitle;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sub = subtitle;
    return Semantics(
      label: focused
          ? l.focusRemoveItem(item.title)
          : l.focusAddItem(item.title),
      toggled: focused,
      button: true,
      excludeSemantics: true,
      child: ListTile(
        minTileHeight: 48,
        title: Text(item.title),
        subtitle: sub == null || sub.isEmpty ? null : Text(sub),
        trailing: Icon(
          focused ? Icons.star_rounded : Icons.star_outline_rounded,
          color: focused ? scheme.primary : scheme.outline,
        ),
        onTap: onToggle,
      ),
    );
  }
}

/// A calendar item due today or overdue: on Today automatically, so it is
/// shown read-only with no star. Tapping opens the item.
class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.item,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final Item item;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      minTileHeight: 48,
      title: Text(item.title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_outlined, size: 16, color: scheme.outline),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                l.planOnToday,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
