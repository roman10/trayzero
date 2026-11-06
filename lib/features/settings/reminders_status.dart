import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/notification_scheduler.dart';
import 'settings_controller.dart';

/// True when the user has at least one reminder feature on but the OS will
/// not deliver notifications. Drives the More hub banner and the red dot on
/// the Reminders row.
final remindersBlockedProvider = Provider.autoDispose<bool>((ref) {
  final status = ref.watch(notificationPermissionStatusProvider).valueOrNull;
  final blocked =
      status == NotificationPermission.denied ||
      status == NotificationPermission.permanentlyDenied;
  if (!blocked) return false;
  return ref.watch(weeklyReviewReminderProvider) ||
      ref.watch(reminderLeadTimeProvider) > 0 ||
      ref.watch(backupReminderEnabledProvider);
});
