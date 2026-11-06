import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/common/adaptive_workspace.dart';
import '../features/item_edit/item_edit_controller.dart';
import '../features/item_edit/item_edit_screen.dart';
import '../features/review/weekly_review_controller.dart';
import '../features/review/weekly_review_screen.dart';
import '../l10n/gen/app_localizations.dart';

/// Composition belongs here so the review and editor remain sibling features.
class WeeklyReviewItemWorkspace extends ConsumerStatefulWidget {
  const WeeklyReviewItemWorkspace({required this.itemId, super.key});
  final String itemId;

  @override
  ConsumerState<WeeklyReviewItemWorkspace> createState() =>
      _WeeklyReviewItemWorkspaceState();
}

class _WeeklyReviewItemWorkspaceState
    extends ConsumerState<WeeklyReviewItemWorkspace> {
  bool _returning = false;

  Future<void> _returnToReview() async {
    if (_returning) return;
    setState(() => _returning = true);
    try {
      await ref
          .read(itemEditControllerProvider(widget.itemId).notifier)
          .commit();
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/review/weekly');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).saveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _returning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = ref.watch(weeklyReviewControllerProvider).valueOrNull;
    final l = AppLocalizations.of(context);
    return AdaptiveWorkspace(
      primary: SafeArea(
        child: review == null
            ? const SizedBox.shrink()
            : WeeklyReviewSteps(step: review.currentStep),
      ),
      detail: ItemEditScreen(
        key: ValueKey(widget.itemId),
        itemId: widget.itemId,
        leading: IconButton(
          tooltip: l.weeklyReviewResume,
          onPressed: _returning ? null : _returnToReview,
          icon: const BackButtonIcon(),
        ),
      ),
    );
  }
}
