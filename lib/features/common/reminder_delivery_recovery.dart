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
/// Returns whether recovery UI was needed, so callers can avoid stacking
/// unrelated prompts on top of its permission dialogs and feedback.
Future<bool> ensureReminderDeliveryReachable(
  BuildContext context,
  WidgetRef ref,
) async {
  final status =
      (await ref.read(checkNotificationPermissionProvider).call())
          .valueOrNull ??
      NotificationPermission.granted;
  if (status != NotificationPermission.granted) {
    if (!context.mounted) return false;
    await runNotificationPermissionRecovery(context, ref);
    if (context.mounted) ref.invalidate(notificationPermissionStatusProvider);
    return true;
  }
  if (!Platform.isAndroid || !context.mounted) return false;
  final exactAllowed =
      (await ref.read(checkExactAlarmPermissionProvider).call()).valueOrNull ??
      true;
  if (exactAllowed || !context.mounted) return false;
  await runExactAlarmPermissionRecovery(context, ref);
  return true;
}
