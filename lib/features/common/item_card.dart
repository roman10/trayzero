import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/due_status.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import 'notes_text.dart';

class ItemCard extends ConsumerWidget {
  const ItemCard({
    required this.item,
    this.onTap,
    this.onComplete,
    this.onDelete,
    this.onMoveToProject,
    this.showContext = true,
    this.showProject = true,
    this.selectionMode = false,
    this.selected = false,
    this.onToggleSelected,
    super.key,
  });

  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onMoveToProject;
  final bool showContext;
  final bool showProject;

  /// When true the card shows a leading selection indicator, taps toggle
  /// selection instead of opening the item, and the swipe actions are
  /// suppressed so bulk triage and per-item gestures never fight each other.
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onToggleSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final now = ref.read(clockProvider).now();
    final contexts = ref.watch(contextsProvider).valueOrNull ?? const [];
    final GtdContext? ctx = item.contextId == null
        ? null
        : contexts.cast<GtdContext?>().firstWhere(
              (c) => c?.id == item.contextId,
              orElse: () => null,
            );
    final summary =
        ref.watch(attachmentSummariesProvider).valueOrNull?[item.id];
    final projects = ref.watch(projectsProvider).valueOrNull ?? const [];
    final Project? project = item.projectId == null
        ? null
        : projects.cast<Project?>().firstWhere(
              (p) => p?.id == item.projectId,
              orElse: () => null,
            );

    final card = InkWell(
        onTap: selectionMode ? onToggleSelected : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selectionMode && selected
                ? scheme.primaryContainer
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectionMode && selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 22,
                        color: selected ? scheme.primary : scheme.outline,
                      ),
                    ),
                  if (!selectionMode && onComplete != null)
                    Semantics(
                      label: 'Mark ${item.title} done',
                      button: true,
                      child: GestureDetector(
                        onTap: onComplete,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.outline,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (item.isTwoMin)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '2 min',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                NotesText(
                  text: item.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  baseStyle: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final meta = _metaItems(context, ctx, project, scheme,
                      constraints.maxWidth, now, summary);
                  if (meta.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(spacing: 6, runSpacing: 6, children: meta),
                  );
                },
              ),
            ],
          ),
        ),
    );

    if (selectionMode) {
      return Semantics(
        label: 'Select ${item.title}',
        selected: selected,
        button: true,
        child: card,
      );
    }

    if (onComplete == null && onDelete == null && onMoveToProject == null) {
      return card;
    }

    return Slidable(
      key: ValueKey(item.id),
      startActionPane: onMoveToProject == null
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.3,
              children: [
                SlidableAction(
                  onPressed: (_) => onMoveToProject!(),
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                  icon: Icons.folder_outlined,
                  label: 'Project',
                ),
              ],
            ),
      endActionPane: onComplete == null && onDelete == null
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: onDelete == null ? 0.25 : 0.5,
              children: [
                if (onComplete != null)
                  SlidableAction(
                    onPressed: (_) => onComplete!(),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    icon: Icons.check,
                    label: 'Done',
                  ),
                if (onDelete != null)
                  SlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
              ],
            ),
      child: card,
    );
  }

  List<Widget> _metaItems(
      BuildContext context,
      GtdContext? ctx,
      Project? project,
      ColorScheme scheme,
      double maxWidth,
      DateTime now,
      AttachmentSummary? attachments) {
    final out = <Widget>[];
    if (showContext && ctx != null) {
      out.add(_chip(context, ctx.name,
          Color(ctx.color).onSurfaceOf(scheme.brightness),
          maxWidth: maxWidth));
    }
    if (showProject && project != null && project.id.isNotEmpty) {
      final title = project.title;
      out.add(_chip(
        context,
        title,
        scheme.primary,
        icon: Icons.folder,
        // Project titles are free-form and can be long; give them two lines
        // before ellipsizing, and let a tap reveal the full name.
        maxLines: 2,
        maxWidth: maxWidth,
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(title)));
        },
      ));
    }
    if (item.energy != null) {
      out.add(_chip(
        context,
        '${item.energy!.label} energy',
        scheme.tertiary,
        maxWidth: maxWidth,
        icon: switch (item.energy!) {
          Energy.low => Icons.battery_2_bar,
          Energy.medium => Icons.battery_4_bar,
          Energy.high => Icons.battery_full,
        },
      ));
    }
    if (item.timeEstimateMinutes != null) {
      out.add(_chip(
        context,
        '${item.timeEstimateMinutes} min',
        scheme.secondary,
        icon: Icons.schedule,
        maxWidth: maxWidth,
      ));
    }
    if (item.dueAt != null) {
      final overdue =
          dueStatusOf(item.dueAt!, now).phase == DuePhase.overdue;
      out.add(_chip(
        context,
        dueChipLabel(item.dueAt!, now),
        scheme.error,
        icon: overdue ? Icons.event_busy : Icons.event,
        maxWidth: maxWidth,
        filled: overdue,
      ));
    }
    if (item.recurrence != null) {
      // Sits next to the due/defer chip it is anchored to. The chip stays
      // terse (cadence word only); a tap surfaces the full pattern, weekday
      // and monthly qualifiers included, without crowding the row.
      final rule = item.recurrenceRule!;
      out.add(_chip(
        context,
        rule.shortLabel,
        scheme.primary,
        icon: Icons.repeat,
        maxWidth: maxWidth,
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(rule.describe())));
        },
      ));
    }
    if (item.waitingOn != null && item.waitingOn!.isNotEmpty) {
      out.add(_chip(context, 'Waiting on ${item.waitingOn!}', scheme.tertiary,
          icon: Icons.hourglass_top, maxWidth: maxWidth));
    }
    if (attachments != null && !attachments.isEmpty) {
      final l10n = AppLocalizations.of(context);
      void add(int count, IconData icon, String semantic) {
        if (count == 0) return;
        out.add(Semantics(
          label: semantic,
          child: _chip(context, '$count', scheme.secondary,
              icon: icon, maxWidth: maxWidth),
        ));
      }

      add(attachments.images, Icons.image_outlined,
          l10n.attachmentPhotoCount(attachments.images));
      add(attachments.audio, Icons.mic_none,
          l10n.attachmentAudioCount(attachments.audio));
      add(attachments.files, Icons.attach_file,
          l10n.attachmentFileCount(attachments.files));
    }
    return out;
  }

  Widget _chip(
    BuildContext context,
    String text,
    Color color, {
    IconData? icon,
    int maxLines = 1,
    required double maxWidth,
    VoidCallback? onTap,
    bool filled = false,
  }) {
    // Filled chips invert: solid colour fill with a contrast-matched content
    // colour, used to make overdue items visually unmistakable. The fill is
    // arbitrary (error / tertiary / due colours) and varies by theme, so pick
    // black or white from its luminance rather than assuming white. Subtle
    // chips use a 12%-alpha wash.
    final fg = filled
        ? (ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black)
        : color;
    final chip = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: fg),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: fg,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return chip;
    return Tooltip(
      message: text,
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }
}
