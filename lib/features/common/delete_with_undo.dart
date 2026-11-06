import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import 'undo_snack_bar.dart';

/// Moves [itemId] to the trash and shows an "Undo" snackbar. Undo restores the
/// item exactly as it was and re-arms its reminders; once the snackbar closes
/// without Undo the item (and its attachment files) is permanently deleted.
///
/// Use this from list screens in place of calling `deleteItemProvider`
/// directly, so a delete is never silent and never instantly irreversible.
Future<void> deleteWithUndo(
  BuildContext context,
  WidgetRef ref,
  String itemId,
) => deleteManyWithUndo(context, ref, [itemId]);

/// Batch variant of [deleteWithUndo]: one snackbar, one Undo for all [itemIds].
Future<void> deleteManyWithUndo(
  BuildContext context,
  WidgetRef ref,
  List<String> itemIds,
) async {
  if (itemIds.isEmpty) return;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  // The snackbar can outlive its screen: resolve everything the callbacks need
  // up front so none of them reads a disposed WidgetRef.
  final trash = ref.read(trashItemProvider);
  final restore = ref.read(restoreTrashedItemProvider);
  final purge = ref.read(purgeTrashProvider);

  final snapshots = [for (final id in itemIds) ?await trash(id)];
  if (snapshots.isEmpty) return;
  final trashedIds = [for (final s in snapshots) s.id];
  if (!context.mounted) {
    // Nowhere to show Undo; finish the delete now.
    await purge(ids: trashedIds);
    return;
  }

  messenger.hideCurrentSnackBar();
  unawaited(messenger
      .showSnackBar(
        undoSnackBar(
          context,
          message: l10n.deletedItemsSnackbar(snapshots.length),
          onUndo: () async {
            for (final s in snapshots) {
              await restore(s);
            }
          },
        ),
      )
      .closed
      .then((reason) async {
        // Purge only re-checks `trashed`, so an Undone item is never touched.
        if (reason != SnackBarClosedReason.action) {
          await purge(ids: trashedIds);
        }
      })
      .catchError((Object _) {
        // Best effort: leftovers are swept on next launch.
      }));
}
