import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';

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
  final spawnedId = await ref.read(completeItemProvider).call(itemId);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Completed'),
        // Flutter defaults `persist` to `action != null`, which keeps any
        // snackbar with an action on screen until the user dismisses it.
        // We want the usual auto-dismiss after a short Undo window.
        persist: false,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref
              .read(undoCompleteProvider)
              .call(itemId, spawnedRecurrenceId: spawnedId),
        ),
      ),
    );
}
