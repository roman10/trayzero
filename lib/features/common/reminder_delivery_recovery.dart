import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/notification_scheduler.dart';
import 'exact_alarm_permission_recovery.dart';
import 'notification_permission_recovery.dart';

/// Ensures the platform can actually deliver reminders the app just enabled.
///
/// 1. Notification permission must be granted.
/// 2. On Android, exact alarms must be available for precise short-horizon
///    reminders.
Future<void> ensureReminderDeliveryReachable(
  BuildContext context,
  WidgetRef ref,
) async {
  final status =
      (await ref.read(checkNotificationPermissionProvider).call())
          .valueOrNull ??
      NotificationPermission.granted;
  if (status != NotificationPermission.granted) {
    if (!context.mounted) return;
    await runNotificationPermissionRecovery(context, ref);
    ref.invalidate(notificationPermissionStatusProvider);
    return;
  }
  if (!Platform.isAndroid || !context.mounted) return;
  final exactAllowed =
      (await ref.read(checkExactAlarmPermissionProvider).call()).valueOrNull ??
      true;
  if (exactAllowed || !context.mounted) return;
  await runExactAlarmPermissionRecovery(context, ref);
}
