import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/notification_scheduler.dart';
import '../../core/result.dart';
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

NotificationStatusUi notificationStatusUi(NotificationPermission s) =>
    switch (s) {
      NotificationPermission.granted => const NotificationStatusUi(
          title: 'Reminders on',
          body: 'Reminders will alert you on this device.',
          icon: Icons.notifications_active_outlined,
        ),
      NotificationPermission.denied => const NotificationStatusUi(
          title: 'Reminders off',
          body: 'Reminders are scheduled but won’t alert you until you '
              'allow notifications.',
          icon: Icons.notifications_off_outlined,
          actionLabel: 'Enable notifications',
          actionIcon: Icons.notifications_active_outlined,
        ),
      NotificationPermission.permanentlyDenied => const NotificationStatusUi(
          title: 'Reminders blocked',
          body: 'Notifications are turned off for Trayzero in system '
              'settings. Reminders won’t alert you until you turn them '
              'back on there.',
          icon: Icons.notifications_off_outlined,
          actionLabel: 'Open Settings',
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
  // Mark primed only once we know we'll actually show it (on Continue *or*
  // Not now), so an unmounted context never silently suppresses it.
  await ref.read(notificationPrimedProvider.notifier).set(true);
  if (!context.mounted) return false;
  final go = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Turn on reminders?'),
      content: const Text(
        'Trayzero reminds you about due dates and your weekly review by '
        'posting a notification on this device. Nothing is sent to a server '
        '— reminders are scheduled locally.\n\n'
        'Your device will now ask for permission to show notifications.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Continue'),
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

  final statusRes =
      await ref.read(checkNotificationPermissionProvider).call();
  final status = switch (statusRes) {
    Ok(:final value) => value,
    Err() => null,
  };
  if (status == null) {
    _snack(messenger, 'Couldn’t open the notification prompt.');
    return NotificationPermission.denied;
  }

  switch (status) {
    case NotificationPermission.granted:
      _snack(messenger, 'Reminders are already on.');
      return status;

    case NotificationPermission.permanentlyDenied:
      await ref.read(openNotificationSettingsProvider).call();
      _snack(
        messenger,
        'Opened system settings — turn on Notifications for Trayzero.',
      );
      return status;

    case NotificationPermission.denied:
      final primed = ref.read(notificationPrimedProvider);
      if (!primed) {
        if (!context.mounted) return status;
        final go = await showNotificationPrimer(context, ref);
        if (!go) {
          _snack(
            messenger,
            'Reminders stay off. You can enable them anytime in '
            'More → Reminders.',
          );
          return status;
        }
      }
      final reqRes =
          await ref.read(requestNotificationPermissionProvider).call();
      final result = switch (reqRes) {
        Ok(:final value) => value,
        Err() => null,
      };
      _emitResult(messenger, ref, result);
      return result ?? status;
  }
}

/// Canonical post-prompt feedback. [result] null == the request use case
/// errored (the underlying error still reaches logs/Sentry).
void _emitResult(
  ScaffoldMessengerState messenger,
  WidgetRef ref,
  NotificationPermission? result,
) {
  switch (result) {
    case NotificationPermission.granted:
      _snack(messenger, 'Reminders are on.');
    case NotificationPermission.denied:
      _snack(
        messenger,
        'Reminders stay off. You can enable them anytime in '
        'More → Reminders.',
      );
    case NotificationPermission.permanentlyDenied:
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('Notifications are blocked for Trayzero.'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () =>
                ref.read(openNotificationSettingsProvider).call(),
          ),
        ));
    case null:
      _snack(messenger, 'Couldn’t open the notification prompt.');
  }
}

void _snack(ScaffoldMessengerState messenger, String text) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
