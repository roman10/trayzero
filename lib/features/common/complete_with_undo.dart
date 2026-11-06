import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import 'undo_snack_bar.dart';

/// Completes [itemId] and shows an "Undo" snackbar. Undo fully reverses the
/// completion — including deleting any recurrence instance that completing
/// the item just spawned — and restores it to the list it came from.
///
/// Use this from list screens (review / engage / project detail) in place of
/// calling `completeItemProvider` directly, so completion is never silent.
Future<void> completeWithUndo(
  BuildContext context,
  WidgetRef ref,
  String itemId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  // The snackbar can outlive its list screen. Resolve Undo before awaiting or
  // navigating so its callback never reads a disposed WidgetRef.
  final undo = ref.read(undoCompleteProvider);
  final spawnedId = await ref.read(completeItemProvider).call(itemId);
  if (!context.mounted) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      undoSnackBar(
        context,
        message: l10n.completed,
        onUndo: () => undo(itemId, spawnedRecurrenceId: spawnedId),
      ),
    );
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
  final complete = ref.read(completeItemProvider);
  // Resolved up front so Undo still works if this screen is gone by then.
  final undo = ref.read(undoCompleteProvider);
  final spawnedIds = <String, String?>{};
  // Built before awaiting (it needs the BuildContext); Undo reads the map,
  // which is complete by the time the snackbar can be shown.
  final snackBar = undoSnackBar(
    context,
    message: l10n.completedItemsSnackbar(itemIds.length),
    onUndo: () async {
      for (final e in spawnedIds.entries) {
        await undo(e.key, spawnedRecurrenceId: e.value);
      }
    },
  );
  for (final id in itemIds) {
    spawnedIds[id] = await complete(id);
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
