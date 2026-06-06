import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// The five GTD stages, used both to lay out the diagram and to drive the
/// "you are here" highlight when the sheet is opened from a stage screen.
enum GtdStage { capture, clarify, organize, reflect, engage }

/// Opens the GTD workflow diagram as a draggable bottom sheet.
///
/// [highlight] emphasises the stage the user is currently on (e.g. opening
/// from the Inbox highlights [GtdStage.capture]).
Future<void> showGtdWorkflowSheet(
  BuildContext context, {
  GtdStage? highlight,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Text(
              l10n.gtdDiagramTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.gtdDiagramSubtitle,
              style: TextStyle(
                height: 1.4,
                color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            GtdWorkflowDiagram(highlight: highlight),
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.gtdAttribution,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// A vertical, theme-driven illustration of the GTD workflow:
/// Capture → Clarify (decision tree) → Organize → Reflect → Engage.
///
/// Stage and bucket chips that map to a real screen are tappable: they
/// dismiss the enclosing sheet (if any) and navigate there.
class GtdWorkflowDiagram extends StatelessWidget {
  const GtdWorkflowDiagram({this.highlight, super.key});

  final GtdStage? highlight;

  @override
  Widget build(BuildContext context) {
    final gtd = context.gtd;
    final l10n = AppLocalizations.of(context);
    final stages = <Widget>[
      _StageCard(
        index: 1,
        stage: GtdStage.capture,
        highlight: highlight,
        icon: Icons.inbox_outlined,
        accent: gtd.inbox,
        title: l10n.capture,
        body: l10n.gtdStage1Body,
        chips: [
          _Node(l10n.inbox, route: '/inbox', color: gtd.inbox),
        ],
      ),
      _StageCard(
        index: 2,
        stage: GtdStage.clarify,
        highlight: highlight,
        icon: Icons.account_tree_outlined,
        accent: gtd.nextAction,
        title: l10n.clarify,
        body: l10n.gtdStage2Body,
        child: const _DecisionTree(),
      ),
      _StageCard(
        index: 3,
        stage: GtdStage.organize,
        highlight: highlight,
        icon: Icons.dashboard_customize_outlined,
        accent: gtd.project,
        title: l10n.organize,
        body: l10n.gtdStage3Body,
        chips: [
          _Node(l10n.projects, route: '/projects', color: gtd.project),
          _Node(l10n.nextAction, route: '/do', color: gtd.nextAction),
          // No dedicated screen — these buckets live inside Review, so
          // they are labels, not tappable destinations.
          _Node(l10n.waitingFor, color: gtd.waiting),
          _Node(l10n.calendar, color: gtd.calendar),
          _Node(l10n.someday, color: gtd.someday),
          _Node(l10n.reference, color: gtd.reference),
        ],
        footnote: l10n.gtdStage3Footnote,
      ),
      _StageCard(
        index: 4,
        stage: GtdStage.reflect,
        highlight: highlight,
        icon: Icons.refresh,
        accent: AppColors.seed,
        title: l10n.reflect,
        body: l10n.gtdStage4Body,
        chips: [
          _Node(l10n.weeklyReviewCardTitle,
              route: '/review', color: AppColors.seed),
        ],
      ),
      _StageCard(
        index: 5,
        stage: GtdStage.engage,
        highlight: highlight,
        icon: Icons.play_arrow_rounded,
        accent: gtd.nextAction,
        title: l10n.engage,
        body: l10n.gtdStage5Body,
        chips: [
          _Node(l10n.engageTitle, route: '/do', color: gtd.nextAction),
        ],
      ),
    ];

    final children = <Widget>[];
    for (var i = 0; i < stages.length; i++) {
      children.add(stages[i]);
      if (i != stages.length - 1) children.add(const _Connector());
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.index,
    required this.stage,
    required this.highlight,
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    this.chips,
    this.child,
    this.footnote,
  });

  final int index;
  final GtdStage stage;
  final GtdStage? highlight;
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final List<_Node>? chips;
  final Widget? child;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final active = highlight == stage;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: active
            ? Border.all(color: scheme.primary, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$index. $title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: active ? scheme.onPrimaryContainer : null,
                  ),
                ),
              ),
              if (active)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.youAreHere,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              height: 1.45,
              fontSize: 14,
              color: active
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: 14),
            child!,
          ],
          if (chips != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips!,
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 10),
            Text(
              footnote!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: active
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The GTD clarify decision tree, rendered as a compact branch list.
class _DecisionTree extends StatelessWidget {
  const _DecisionTree();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branches = <(String, String)>[
      (l10n.decisionNotActionableQ, l10n.decisionNotActionableA),
      (l10n.decisionTwoMinQ, l10n.decisionTwoMinA),
      (l10n.decisionDelegateQ, l10n.decisionDelegateA),
      (l10n.decisionMultiStepQ, l10n.decisionMultiStepA),
      (l10n.decisionOtherwiseQ, l10n.decisionOtherwiseA),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (q, a) in branches)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.subdirectory_arrow_right,
                    size: 16, color: scheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                      children: [
                        TextSpan(
                          text: '$q  ',
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: a,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A pill representing a GTD list. If [route] is set it is tappable: it
/// closes the enclosing sheet and navigates there.
class _Node extends StatelessWidget {
  const _Node(this.label, {required this.color, this.route});

  final String label;
  final Color color;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (route != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 13, color: color),
          ],
        ],
      ),
    );
    if (route == null) return pill;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Resolve the router before popping: once the sheet route is
        // popped this element is deactivated and the go_router lookup
        // via InheritedWidget is no longer reliable.
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.go(route!);
      },
      child: pill,
    );
  }
}

/// The vertical line + arrow drawn between two stage cards.
class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Center(
      child: Column(
        children: [
          Container(width: 2, height: 16, color: color),
          Icon(Icons.keyboard_arrow_down, size: 20, color: color),
        ],
      ),
    );
  }
}
