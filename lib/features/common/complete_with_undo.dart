import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/haptic_feedback.dart';
import '../../l10n/gen/app_localizations.dart';
import 'play_haptic.dart';
import 'undo_snack_bar.dart';

/// Completes [itemId] and shows an "Undo" snackbar. Undo fully reverses the
/// completion — including deleting any recurrence instance that completing
/// the item just spawned — and restores it to the list it came from.
///
/// [onCompleted] receives the feedback lifetime after a successful completion.
/// It can schedule follow-up work once Undo has finished.
///
/// Use this from list screens (review / engage / project detail) in place of
/// calling `completeItemProvider` directly, so completion is never silent.
Future<void> completeWithUndo(
  BuildContext context,
  WidgetRef ref,
  String itemId, {
  void Function(Future<void> settled)? onCompleted,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  // The snackbar can outlive its list screen. Resolve Undo before awaiting or
  // navigating so its callback never reads a disposed WidgetRef.
  final undo = ref.read(undoCompleteProvider);
  final completion = await ref.read(completeItemProvider).complete(itemId);
  if (!context.mounted || completion == null) return;
  playHaptic(ref, HapticCue.taskCompleted);
  messenger.hideCurrentSnackBar();
  final bar = messenger.showSnackBar(
    undoSnackBar(
      context,
      message: l10n.completed,
      onUndo: () =>
          undo(itemId, spawnedRecurrenceId: completion.spawnedRecurrenceId),
    ),
  );
  onCompleted?.call(bar.closed.then((_) {}));
}

/// Batch variant of [completeWithUndo]: completes every id in [itemIds] and
/// shows a single "Undo" snackbar that reverses the whole batch, including any
/// recurrence instances the completions spawned.
Future<void> completeManyWithUndo(
  BuildContext context,
  WidgetRef ref,
  List<String> itemIds,
) async {
  if (itemIds.isEmpty) return;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final complete = ref.read(completeItemProvider).complete;
  // Resolved up front so Undo still works if this screen is gone by then.
  final undo = ref.read(undoCompleteProvider);
  final spawnedIds = <String, String?>{};
  SnackBar buildUndo(int count) => undoSnackBar(
    context,
    message: l10n.completedItemsSnackbar(count),
    onUndo: () async {
      for (final e in spawnedIds.entries) {
        await undo(e.key, spawnedRecurrenceId: e.value);
      }
    },
  );
  final originalSnackBar = buildUndo(itemIds.length);
  for (final id in itemIds) {
    final completion = await complete(id);
    if (completion != null) spawnedIds[id] = completion.spawnedRecurrenceId;
  }
  if (spawnedIds.isEmpty || !messenger.mounted) return;
  final snackBar = context.mounted && spawnedIds.length != itemIds.length
      ? buildUndo(spawnedIds.length)
      : originalSnackBar;
  if (context.mounted) playHaptic(ref, HapticCue.taskCompleted);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
