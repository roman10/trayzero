import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../domain/entities/entities.dart';

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
    final unit =
        interval == 1 ? recurrence.unitNoun : '${recurrence.unitNoun}s';
    return Row(
      children: [
        Text(
          'Every',
          style: TextStyle(fontSize: 14, color: scheme.onSurface),
        ),
        const SizedBox(width: 8),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: interval <= _min
              ? null
              : () => onChanged(interval - 1),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$interval',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline),
          onPressed: interval >= _max
              ? null
              : () => onChanged(interval + 1),
        ),
        const SizedBox(width: 8),
        Text(
          unit,
          style: TextStyle(fontSize: 14, color: scheme.onSurface),
        ),
      ],
    );
  }
}

/// Weekday labels indexed by `DateTime.monday`(1)..`DateTime.sunday`(7).
const _weekdayShort = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

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

  static const _weeks = {1: 'First', 2: 'Second', 3: 'Third', 4: 'Fourth', -1: 'Last'};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget labelled(String label, Widget child) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12.5, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              child,
            ],
          ),
        );

    switch (recurrence) {
      case Recurrence.weekly:
        return labelled(
          'Repeat on',
          Wrap(
            spacing: 6,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(_weekdayShort[d]!),
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
          'On',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Day of month'),
                    selected: !isNth,
                    onSelected: (_) => onDayOfMonth(),
                  ),
                  ChoiceChip(
                    label: const Text('Day of week'),
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
                  child: Row(
                    children: [
                      DropdownButton<int>(
                        value: monthlyWeek,
                        onChanged: (v) =>
                            onNthWeekday(v!, monthlyWeekday!),
                        items: [
                          for (final e in _weeks.entries)
                            DropdownMenuItem(
                                value: e.key, child: Text(e.value)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: monthlyWeekday,
                        onChanged: (v) => onNthWeekday(monthlyWeek!, v!),
                        items: [
                          for (var d = 1; d <= 7; d++)
                            DropdownMenuItem(
                                value: d, child: Text(_weekdayShort[d]!)),
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
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      initialDate: until ?? now.add(const Duration(days: 30)),
    );
    if (picked != null) onUntil(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ends',
          style: TextStyle(
            fontSize: 12.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Never'),
              selected: until == null && count == null,
              onSelected: (_) => onNever(),
            ),
            ChoiceChip(
              label: const Text('On date'),
              selected: until != null,
              onSelected: (_) => _pickDate(context, ref),
            ),
            ChoiceChip(
              label: const Text('After N times'),
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
                  Text(
                    'Last on ${DateFormat.yMMMd().format(until!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        if (count != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  'After',
                  style: TextStyle(fontSize: 14, color: scheme.onSurface),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: count! <= _minCount
                      ? null
                      : () => onCount(count! - 1),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${count!}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: count! >= _maxCount
                      ? null
                      : () => onCount(count! + 1),
                ),
                Text(
                  'times',
                  style: TextStyle(fontSize: 14, color: scheme.onSurface),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
