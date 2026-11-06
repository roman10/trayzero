import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../application/current_time.dart';
import '../../core/due_status.dart';
import '../../domain/today_focus.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import 'complete_circle.dart';
import 'focus_star.dart';
import 'localized_dates.dart';
import 'localized_due_label.dart';
import 'localized_entity_labels.dart';
import 'localized_recurrence.dart';
import 'notes_text.dart';

const _cardPadding = 14.0;
const _cardBorderWidth = 1.0;

/// Distance from the card's outer edge to its content.
const _cardInset = _cardPadding + _cardBorderWidth;

/// Space between the completion circle and the title.
const _circleGap = 10.0;

/// How far [CompleteCircle]'s touch target extends past the visible ring.
const _circleOverhang =
    (CompleteCircle.targetSize - CompleteCircle.diameter) / 2;

/// Tag chips shown before the rest collapse into "+N".
const _maxTagChips = 2;

/// How far [FocusStar]'s touch target extends past the visible star.
const _starOverhang = (FocusStar.targetSize - FocusStar.iconSize) / 2;

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
    this.highlighted = false,
    this.selected = false,
    this.onToggleSelected,
    this.onToggleFocus,
    this.hiddenTagId,
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

  /// Current editor selection, independent of bulk-selection controls.
  final bool highlighted;
  final bool selected;
  final VoidCallback? onToggleSelected;

  /// When set, the card shows a Today star (ADR 0007), filled while the Item
  /// is focused today. Hidden for Items that cannot be focused.
  final VoidCallback? onToggleFocus;

  /// A tag the surrounding screen already implies (the person on their own
  /// Agenda), left off the card's tag chips.
  final String? hiddenTagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(currentTimeProvider);
    final contexts = ref.watch(contextsProvider).valueOrNull ?? const [];
    final GtdContext? ctx = item.contextId == null
        ? null
        : contexts.cast<GtdContext?>().firstWhere(
            (c) => c?.id == item.contextId,
            orElse: () => null,
          );
    final summary = ref
        .watch(attachmentSummariesProvider)
        .valueOrNull?[item.id];
    final projects = ref.watch(projectsProvider).valueOrNull ?? const [];
    final Project? project = item.projectId == null
        ? null
        : projects.cast<Project?>().firstWhere(
            (p) => p?.id == item.projectId,
            orElse: () => null,
          );
    final tags = _tagsOf(
      ref.watch(itemTagIdsProvider).valueOrNull?[item.id],
      ref.watch(tagsProvider).valueOrNull ?? const [],
    );

    final canComplete = !selectionMode && onComplete != null;
    final canStar = !selectionMode && onToggleFocus != null && canFocus(item);

    final body = InkWell(
      onTap: selectionMode ? onToggleSelected : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(_cardPadding),
        decoration: BoxDecoration(
          color: (selectionMode && selected) || highlighted
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (selectionMode && selected) || highlighted
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.5),
            width: _cardBorderWidth,
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
                // Reserves the circle's footprint; the circle itself is drawn
                // by the overlay below so its touch target can exceed it.
                if (canComplete)
                  const SizedBox(
                    width: CompleteCircle.diameter + _circleGap,
                    height: CompleteCircle.diameter,
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
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.minutesShort(2),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                // Reserves the star's footprint; drawn by the overlay below.
                if (canStar)
                  const SizedBox(
                    width: _circleGap + FocusStar.iconSize,
                    height: FocusStar.iconSize,
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
                final meta = _metaItems(
                  context,
                  ctx,
                  project,
                  scheme,
                  constraints.maxWidth,
                  now,
                  summary,
                  tags,
                );
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

    // The circle is an overlay rather than part of the title row: a widget
    // can't receive taps outside its parent's bounds, and the touch target
    // (48dp) is bigger than the row's slot for the ring.
    final card = !canComplete && !canStar
        ? body
        : Stack(
            children: [
              body,
              if (canComplete)
                Positioned(
                  left: _cardInset - _circleOverhang,
                  top: _cardInset - _circleOverhang,
                  child: CompleteCircle(
                    key: ValueKey(item.id),
                    title: item.title,
                    onComplete: onComplete!,
                  ),
                ),
              if (canStar)
                Positioned(
                  right: _cardInset - _starOverhang,
                  top: _cardInset - _starOverhang,
                  child: FocusStar(
                    title: item.title,
                    focused: isFocusedToday(item, now),
                    onToggle: onToggleFocus!,
                  ),
                ),
            ],
          );

    if (selectionMode) {
      return Semantics(
        label: l10n.selectItem(item.title),
        selected: selected,
        button: true,
        child: card,
      );
    }

    if (onComplete == null && onDelete == null && onMoveToProject == null) {
      return highlighted ? Semantics(selected: true, child: card) : card;
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
                  label: l10n.project,
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
                    label: l10n.done,
                  ),
                if (onDelete != null)
                  SlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    icon: Icons.delete,
                    label: l10n.delete,
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
    AttachmentSummary? attachments,
    List<Tag> tags,
  ) {
    final out = <Widget>[];
    final l10n = AppLocalizations.of(context);
    if (showContext && ctx != null) {
      out.add(
        _chip(
          context,
          ctx.name,
          Color(ctx.color).onSurfaceOf(scheme.brightness),
          maxWidth: maxWidth,
        ),
      );
    }
    if (showProject && project != null && project.id.isNotEmpty) {
      final title = project.title;
      out.add(
        _chip(
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
        ),
      );
    }
    if (item.energy != null) {
      out.add(
        _chip(
          context,
          l10n.itemEnergyLabel(item.energy!.localizedLabel(l10n)),
          scheme.tertiary,
          maxWidth: maxWidth,
          icon: switch (item.energy!) {
            Energy.low => Icons.battery_2_bar,
            Energy.medium => Icons.battery_4_bar,
            Energy.high => Icons.battery_full,
          },
        ),
      );
    }
    if (item.timeEstimateMinutes != null) {
      out.add(
        _chip(
          context,
          l10n.minutesShort(item.timeEstimateMinutes!),
          scheme.secondary,
          icon: Icons.schedule,
          maxWidth: maxWidth,
        ),
      );
    }
    if (item.dueAt != null) {
      final overdue = dueStatusOf(item.dueAt!, now).phase == DuePhase.overdue;
      out.add(
        _chip(
          context,
          localizedDueChipLabel(item.dueAt!, now, l10n),
          scheme.error,
          icon: overdue ? Icons.event_busy : Icons.event,
          maxWidth: maxWidth,
          filled: overdue,
        ),
      );
    }
    final defer = item.deferUntil;
    if (defer != null && defer.isAfter(now)) {
      out.add(
        _chip(
          context,
          l10n.startsOnDate(_shortDate(defer, now, l10n)),
          scheme.secondary,
          icon: Icons.schedule_send_outlined,
          maxWidth: maxWidth,
        ),
      );
    }
    if (item.recurrence != null) {
      // Sits next to the due/defer chip it is anchored to. The chip stays
      // terse (cadence word only); a tap surfaces the full pattern, weekday
      // and monthly qualifiers included, without crowding the row.
      final rule = item.recurrenceRule!;
      out.add(
        _chip(
          context,
          rule.localizedShortLabel(l10n),
          scheme.primary,
          icon: Icons.repeat,
          maxWidth: maxWidth,
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(item.localizedRecurrenceSummary(l10n))),
              );
          },
        ),
      );
    }
    if (item.waitingOn != null && item.waitingOn!.isNotEmpty) {
      out.add(
        _chip(
          context,
          l10n.waitingOnPerson(item.waitingOn!),
          context.gtd.waiting,
          icon: Icons.hourglass_top,
          maxWidth: maxWidth,
        ),
      );
    }
    // At most two tag chips and a "+N": tags label, they don't dominate.
    for (final tag in tags.take(_maxTagChips)) {
      out.add(
        Semantics(
          label: tag.isPerson
              ? l10n.personChipSemantics(tag.name)
              : l10n.tagChipSemantics(tag.name),
          excludeSemantics: true,
          child: _chip(
            context,
            tag.name,
            scheme.onSurfaceVariant,
            icon: tag.isPerson ? Icons.person_outline : Icons.sell_outlined,
            maxWidth: maxWidth,
          ),
        ),
      );
    }
    if (tags.length > _maxTagChips) {
      final rest = tags.skip(_maxTagChips).map((t) => t.name).join(', ');
      out.add(
        Semantics(
          label: l10n.moreTags(tags.length - _maxTagChips),
          excludeSemantics: true,
          child: _chip(
            context,
            '+${tags.length - _maxTagChips}',
            scheme.onSurfaceVariant,
            maxWidth: maxWidth,
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(rest)));
            },
          ),
        ),
      );
    }
    if (attachments != null && !attachments.isEmpty) {
      void add(int count, IconData icon, String semantic) {
        if (count == 0) return;
        out.add(
          Semantics(
            label: semantic,
            child: _chip(
              context,
              '$count',
              scheme.secondary,
              icon: icon,
              maxWidth: maxWidth,
            ),
          ),
        );
      }

      add(
        attachments.images,
        Icons.image_outlined,
        l10n.attachmentPhotoCount(attachments.images),
      );
      add(
        attachments.audio,
        Icons.mic_none,
        l10n.attachmentAudioCount(attachments.audio),
      );
      add(
        attachments.files,
        Icons.attach_file,
        l10n.attachmentFileCount(attachments.files),
      );
    }
    return out;
  }

  /// The Item's tags, alphabetical, without [hiddenTagId].
  List<Tag> _tagsOf(List<String>? ids, List<Tag> all) {
    if (ids == null || ids.isEmpty) return const [];
    return [
      for (final t in all)
        if (t.id != hiddenTagId && ids.contains(t.id)) t,
    ];
  }

  /// A terse future date: "Fri, Oct 30", with the time when one was set.
  static String _shortDate(DateTime at, DateTime now, AppLocalizations l10n) {
    final format = at.year == now.year
        ? DateFormat.MMMEd(l10n.dateLocaleName)
        : DateFormat.yMMMEd(l10n.dateLocaleName);
    final hasTime = at.hour != 0 || at.minute != 0;
    return (hasTime ? format.add_jm() : format).format(at);
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
    final scheme = Theme.of(context).colorScheme;
    final backdrop = (selectionMode && selected) || highlighted
        ? scheme.primaryContainer
        : scheme.surfaceContainerLow;
    final fill = filled ? color : color.withValues(alpha: 0.12);
    final background = Color.alphaBlend(fill, backdrop);
    final fg = filled
        ? background.contrastingForeground
        : color.foregroundOn(background);
    final chip = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: fill,
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
