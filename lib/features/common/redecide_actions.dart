import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../item_edit/sections.dart';
import 'complete_with_undo.dart';
import 'delete_with_undo.dart';
import 'reminder_delivery_recovery.dart';

/// The three GTD re-decisions for a past-due hard-landscape item:
/// reschedule (renegotiate the date), complete (it's done), or drop
/// (the commitment is no longer real). A missed date is a decision, not a
/// passive badge — so these are explicit buttons, never a swipe.
///
/// Reschedule only changes `dueAt`; `status` stays `calendar`, so the item
/// simply moves from overdue back onto the upcoming hard landscape.
///
/// Shared by the Review › "Needs re-decision" bucket and the Do screen's
/// hard-landscape band so both surfaces stay behaviourally identical.
class ReDecideActions extends ConsumerWidget {
  const ReDecideActions({super.key, required this.item});

  final Item item;

  Future<void> _reschedule(BuildContext context, WidgetRef ref) async {
    final picked = await pickDateTime(context, ref, initial: item.dueAt);
    if (picked == null) return;
    await ref.read(saveItemProvider).call(item.copyWith(dueAt: picked));
    if (!context.mounted) return;
    await ensureReminderDeliveryReachable(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 4,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.event_repeat, size: 18),
          label: Text(l10n.reschedule),
          onPressed: () => _reschedule(context, ref),
        ),
        TextButton.icon(
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: Text(l10n.complete),
          onPressed: () => completeWithUndo(context, ref, item.id),
        ),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(l10n.drop),
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          onPressed: () => deleteWithUndo(context, ref, item.id),
        ),
      ],
    );
  }
}
