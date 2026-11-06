import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_recurrence.dart';
import '../common/localized_dates.dart';

/// Stepper for the recurrence interval ("every N days/weeks/…").
///
/// The data model has always carried `recurrenceInterval`; this exposes it.
/// Clamped to 1..99 — beyond that the phrasing stops being meaningful and a
/// fat-fingered value would push instances years out.
class IntervalStepper extends StatelessWidget {
  const IntervalStepper({
    required this.recurrence,
    required this.interval,
    required this.onChanged,
    super.key,
  });

  final Recurrence recurrence;
  final int interval;
  final ValueChanged<int> onChanged;

  static const _min = 1;
  static const _max = 99;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 4,
      children: [
        Text(
          recurrence.localizedInterval(l10n, interval),
          style: TextStyle(fontSize: 14, color: scheme.onSurface),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: l10n.decreaseRepeatInterval,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: interval <= _min ? null : () => onChanged(interval - 1),
        ),
        IconButton(
          tooltip: l10n.increaseRepeatInterval,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline),
          onPressed: interval >= _max ? null : () => onChanged(interval + 1),
        ),
      ],
    );
  }
}

/// Structured-pattern qualifier editor. Weekly → which weekdays; monthly →
/// day-of-month vs Nth-weekday. Daily/yearly have no qualifier and render
/// nothing. State is derived from the item, never held locally, so it stays
/// in sync with the committed draft (matching the other recurrence pickers).
class RecurrencePatternEditor extends StatelessWidget {
  const RecurrencePatternEditor({
    required this.recurrence,
    required this.byWeekdays,
    required this.monthlyWeek,
    required this.monthlyWeekday,
    required this.onWeekdaysChanged,
    required this.onDayOfMonth,
    required this.onNthWeekday,
    super.key,
  });

  final Recurrence recurrence;
  final List<int> byWeekdays;
  final int? monthlyWeek;
  final int? monthlyWeekday;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final VoidCallback onDayOfMonth;
  final void Function(int week, int weekday) onNthWeekday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    Widget labelled(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );

    switch (recurrence) {
      case Recurrence.weekly:
        return labelled(
          l10n.repeatOn,
          Wrap(
            spacing: 6,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(localizedWeekday(d, l10n, short: true)),
                  selected: byWeekdays.contains(d),
                  onSelected: (sel) {
                    final next = [...byWeekdays];
                    sel ? next.add(d) : next.remove(d);
                    next.sort();
                    onWeekdaysChanged(next);
                  },
                ),
            ],
          ),
        );
      case Recurrence.monthly:
        final isNth = monthlyWeek != null && monthlyWeekday != null;
        return labelled(
          l10n.repeatMonthlyOn,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.repeatDayOfMonth),
                    selected: !isNth,
                    onSelected: (_) => onDayOfMonth(),
                  ),
                  ChoiceChip(
                    label: Text(l10n.repeatDayOfWeek),
                    selected: isNth,
                    onSelected: (_) => onNthWeekday(
                      monthlyWeek ?? 1,
                      monthlyWeekday ?? DateTime.monday,
                    ),
                  ),
                ],
              ),
              if (isNth)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<int>(
                        isExpanded: true,
                        itemHeight: null,
                        value: monthlyWeek,
                        onChanged: (v) => onNthWeekday(v!, monthlyWeekday!),
                        items: [
                          for (final week in const [1, 2, 3, 4, 5, -1])
                            DropdownMenuItem(
                              value: week,
                              child: Text(localizedMonthlyOrdinal(week, l10n)),
                            ),
                        ],
                      ),
                      DropdownButton<int>(
                        isExpanded: true,
                        itemHeight: null,
                        value: monthlyWeekday,
                        onChanged: (v) => onNthWeekday(monthlyWeek!, v!),
                        items: [
                          for (var d = 1; d <= 7; d++)
                            DropdownMenuItem(
                              value: d,
                              child: Text(
                                localizedWeekday(d, l10n, short: true),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      case Recurrence.daily:
      case Recurrence.yearly:
        return const SizedBox.shrink();
    }
  }
}

/// "Ends" control for a recurring item: Never / On date / After N times.
///
/// The mode is derived from the item (`until` set → date, `count` set →
/// count, neither → never) rather than held as local state, so it always
/// reflects the committed draft. Count is floored at 2 — "after 1" would
/// mean the item never repeats, which is just turning recurrence off.
class RecurrenceEndPicker extends ConsumerWidget {
  const RecurrenceEndPicker({
    required this.until,
    required this.count,
    required this.onNever,
    required this.onUntil,
    required this.onCount,
    super.key,
  });

  final DateTime? until;
  final int? count;
  final VoidCallback onNever;
  final ValueChanged<DateTime> onUntil;
  final ValueChanged<int> onCount;

  static const _minCount = 2;
  static const _maxCount = 99;

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = ref.read(clockProvider).now();
    final lastDate = now.add(const Duration(days: 365 * 10));
    final seed = until ?? now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: lastDate,
      initialDate: seed.isBefore(now)
          ? now
          : (seed.isAfter(lastDate) ? lastDate : seed),
    );
    if (picked != null) onUntil(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.repeatEnds,
          style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.repeatNever),
              selected: until == null && count == null,
              onSelected: (_) => onNever(),
            ),
            ChoiceChip(
              label: Text(l10n.repeatOnDate),
              selected: until != null,
              onSelected: (_) => _pickDate(context, ref),
            ),
            ChoiceChip(
              label: Text(l10n.repeatAfterCount),
              selected: count != null,
              onSelected: (_) => onCount(count ?? _minCount),
            ),
          ],
        ),
        if (until != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () => _pickDate(context, ref),
              child: Row(
                children: [
                  Icon(Icons.event_busy, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.repeatLastOnDate(
                        DateFormat.yMMMd(l10n.dateLocaleName).format(until!),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (count != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.repeatAfterOccurrences(count!),
                  style: TextStyle(fontSize: 14, color: scheme.onSurface),
                ),
                IconButton(
                  tooltip: l10n.decreaseRepeatCount,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: count! <= _minCount
                      ? null
                      : () => onCount(count! - 1),
                ),
                IconButton(
                  tooltip: l10n.increaseRepeatCount,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: count! >= _maxCount
                      ? null
                      : () => onCount(count! + 1),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
