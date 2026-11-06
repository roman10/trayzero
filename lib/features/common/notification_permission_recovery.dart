import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/notification_scheduler.dart';
import '../../core/result.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_controller.dart';

/// One place that owns notification-permission UX so Settings, item-edit,
/// and (later) calendar share identical copy and behaviour. The Settings
/// *tile rendering* uses [notificationStatusUi] (a pure mapper); the
/// imperative recovery flow is [runNotificationPermissionRecovery]; the
/// one-time rationale is [showNotificationPrimer].

/// Pure presentation for a [NotificationPermission]. [actionLabel] is null
/// when the state needs no user action (granted).
class NotificationStatusUi {
  const NotificationStatusUi({
    required this.title,
    required this.body,
    required this.icon,
    this.actionLabel,
    this.actionIcon,
  });

  final String title;
  final String body;
  final IconData icon;
  final String? actionLabel;
  final IconData? actionIcon;
}

NotificationStatusUi notificationStatusUi(
  AppLocalizations l10n,
  NotificationPermission s,
) => switch (s) {
  NotificationPermission.granted => NotificationStatusUi(
    title: l10n.notificationStatusOnTitle,
    body: l10n.notificationStatusOnBody,
    icon: Icons.notifications_active_outlined,
  ),
  NotificationPermission.denied => NotificationStatusUi(
    title: l10n.notificationStatusOffTitle,
    body: l10n.notificationStatusOffBody,
    icon: Icons.notifications_off_outlined,
    actionLabel: l10n.notificationActionEnable,
    actionIcon: Icons.notifications_active_outlined,
  ),
  NotificationPermission.permanentlyDenied => NotificationStatusUi(
    title: l10n.notificationStatusBlockedTitle,
    body: l10n.notificationStatusBlockedBody,
    icon: Icons.notifications_off_outlined,
    actionLabel: l10n.notificationActionOpenSettings,
    actionIcon: Icons.open_in_new,
  ),
};

/// The one-time pre-permission rationale. Marks [notificationPrimedProvider]
/// the moment it is shown — on Continue *or* Not now — so it never re-nags.
/// Returns true when the user chose Continue.
Future<bool> showNotificationPrimer(
  BuildContext context,
  WidgetRef ref,
) async {
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  // Mark primed only once we know we'll actually show it (on Continue *or*
  // Not now), so an unmounted context never silently suppresses it.
  await ref.read(notificationPrimedProvider.notifier).set(true);
  if (!context.mounted) return false;
  final go = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.notificationPrimerTitle),
      content: Text(l10n.notificationPrimerBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.notificationPrimerNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.notificationPrimerContinue),
        ),
      ],
    ),
  );
  return go ?? false;
}

/// Reads current status and runs the right recovery path: primer→prompt for
/// `denied`, deep-link for `permanentlyDenied`, a quiet confirmation for
/// `granted`. Always finishes with an honest SnackBar. Mounted-safe and
/// idempotent. Returns the resulting status so callers can refresh local UI.
Future<NotificationPermission> runNotificationPermissionRecovery(
  BuildContext context,
  WidgetRef ref,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);

  final statusRes =
      await ref.read(checkNotificationPermissionProvider).call();
  final status = switch (statusRes) {
    Ok(:final value) => value,
    Err() => null,
  };
  if (status == null) {
    _snack(messenger, l10n.notificationPromptFailed);
    return NotificationPermission.denied;
  }

  switch (status) {
    case NotificationPermission.granted:
      _snack(messenger, l10n.notificationAlreadyOn);
      return status;

    case NotificationPermission.permanentlyDenied:
      await ref.read(openNotificationSettingsProvider).call();
      _snack(messenger, l10n.notificationOpenedSettings);
      return status;

    case NotificationPermission.denied:
      final primed = ref.read(notificationPrimedProvider);
      if (!primed) {
        if (!context.mounted) return status;
        final go = await showNotificationPrimer(context, ref);
        if (!go) {
          _snack(messenger, l10n.notificationStayOff);
          return status;
        }
      }
      final reqRes =
          await ref.read(requestNotificationPermissionProvider).call();
      final result = switch (reqRes) {
        Ok(:final value) => value,
        Err() => null,
      };
      _emitResult(messenger, l10n, ref, result);
      return result ?? status;
  }
}

/// Canonical post-prompt feedback. [result] null == the request use case
/// errored (the underlying error still reaches logs/Sentry).
void _emitResult(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  WidgetRef ref,
  NotificationPermission? result,
) {
  switch (result) {
    case NotificationPermission.granted:
      _snack(messenger, l10n.notificationNowOn);
    case NotificationPermission.denied:
      _snack(messenger, l10n.notificationStayOff);
    case NotificationPermission.permanentlyDenied:
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(l10n.notificationBlocked),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.notificationActionOpenSettings,
            onPressed: () =>
                ref.read(openNotificationSettingsProvider).call(),
          ),
        ));
    case null:
      _snack(messenger, l10n.notificationPromptFailed);
  }
}

void _snack(ScaffoldMessengerState messenger, String text) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
