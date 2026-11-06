import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// A snackbar with an "Undo" action and the standard 5 s window. A null
/// [onUndo] gives a plain message with no action.
///
/// `persist: false` because Flutter otherwise keeps any snackbar with an
/// action on screen until dismissed. The overflow threshold is divided by the
/// text scale: SnackBar measures the action label at 1x, so at large text (or
/// a long translation such as German "Rückgängig") the action would overflow
/// its row instead of wrapping below the message.
SnackBar undoSnackBar(
  BuildContext context, {
  required String message,
  VoidCallback? onUndo,
}) {
  final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
  return SnackBar(
    content: Text(message),
    persist: false,
    duration: const Duration(seconds: 5),
    actionOverflowThreshold: (0.25 / (scale < 1 ? 1 : scale)).clamp(0.0, 1.0),
    action: onUndo == null
        ? null
        : SnackBarAction(
            label: AppLocalizations.of(context).undo,
            onPressed: onUndo,
          ),
  );
}
