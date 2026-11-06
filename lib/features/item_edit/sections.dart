import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_entity_labels.dart';
import '../common/localized_dates.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.5,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class StatusSelector extends StatelessWidget {
  const StatusSelector({
    required this.current,
    required this.onChanged,
    super.key,
  });
  final ItemStatus current;
  final ValueChanged<ItemStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const visible = [
      ItemStatus.inbox,
      ItemStatus.nextAction,
      ItemStatus.waiting,
      ItemStatus.someday,
      ItemStatus.reference,
      ItemStatus.calendar,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final s in visible)
          ChoiceChip(
            label: Text(s.localizedLabel(l10n)),
            selected: current == s,
            onSelected: (_) => onChanged(s),
          ),
      ],
    );
  }
}

class ContextSelector extends StatelessWidget {
  const ContextSelector({
    required this.contexts,
    required this.currentId,
    required this.onChanged,
    super.key,
  });
  final List<GtdContext> contexts;
  final String? currentId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (contexts.isEmpty) {
      return Text(l10n.noContextsAvailable);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: Text(l10n.none),
          selected: currentId == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final c in contexts)
          ChoiceChip(
            label: Text(c.name),
            selected: currentId == c.id,
            onSelected: (sel) => onChanged(sel ? c.id : null),
          ),
      ],
    );
  }
}

class ProjectSelector extends StatelessWidget {
  const ProjectSelector({
    required this.projects,
    required this.currentId,
    required this.onChanged,
    super.key,
  });
  final List<Project> projects;
  final String? currentId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (projects.isEmpty) {
      return Text(l10n.noActiveProjects);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: Text(l10n.none),
          selected: currentId == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final p in projects)
          ChoiceChip(
            label: Text(p.title),
            selected: currentId == p.id,
            onSelected: (sel) => onChanged(sel ? p.id : null),
          ),
      ],
    );
  }
}

/// Shared date+time picker used by [DateTile] and the Review screen's
/// "Reschedule" action. Returns the composed [DateTime], or null if the
/// user cancelled either step. [initial] seeds both pickers; it is clamped
/// into the selectable range so a far-past due date (a reschedule target)
/// doesn't crash showDatePicker.
Future<DateTime?> pickDateTime(
  BuildContext context,
  WidgetRef ref, {
  DateTime? initial,
}) async {
  final now = ref.read(clockProvider).now();
  final firstDate = now.subtract(const Duration(days: 1));
  final lastDate = now.add(const Duration(days: 365 * 5));
  final seed = initial ?? now;
  final initialDate = seed.isBefore(firstDate)
      ? now
      : (seed.isAfter(lastDate) ? lastDate : seed);
  final date = await showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDate: initialDate,
  );
  if (date == null) return null;
  if (!context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial ?? now),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Date-only counterpart of [pickDateTime] (the GTD tickler): returns local
/// start-of-day, or null if cancelled. Same range clamping as [pickDateTime].
Future<DateTime?> pickDateOnly(
  BuildContext context,
  WidgetRef ref, {
  DateTime? initial,
}) async {
  final now = ref.read(clockProvider).now();
  final firstDate = now.subtract(const Duration(days: 1));
  final lastDate = now.add(const Duration(days: 365 * 5));
  final seed = initial ?? now;
  final initialDate = seed.isBefore(firstDate)
      ? now
      : (seed.isAfter(lastDate) ? lastDate : seed);
  final date = await showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDate: initialDate,
  );
  if (date == null) return null;
  return DateTime(date.year, date.month, date.day);
}

class DateTile extends ConsumerWidget {
  const DateTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChange,
    this.dateOnly = false,
    this.allowClear = true,
    super.key,
  });

  /// When true the tile only asks for a day (stored as local start-of-day).
  final bool dateOnly;
  final bool allowClear;
  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: scheme.primary),
      title: Text(label),
      subtitle: value == null
          ? Text(l10n.notSet)
          : Text(
              dateOnly
                  ? localizedDeferLabel(value!, l10n)
                  : DateFormat.yMMMd(
                      l10n.dateLocaleName,
                    ).add_jm().format(value!),
            ),
      trailing: value == null
          ? const Icon(Icons.add)
          : !allowClear
          ? null
          : IconButton(
              tooltip: l10n.clearDate,
              icon: const Icon(Icons.close),
              onPressed: () => onChange(null),
            ),
      onTap: () async {
        final picked = dateOnly
            ? await pickDateOnly(context, ref, initial: value)
            : await pickDateTime(context, ref, initial: value);
        if (picked != null) onChange(picked);
      },
    );
  }
}
