import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/notification_scheduler.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/notification_permission_recovery.dart';
import '../common/reminder_delivery_recovery.dart';
import 'settings_controller.dart';
import 'settings_tiles.dart';

/// Reminder permission status, nudges (weekly review / weekly backup) and
/// timing (lead time, deferred-item surface time).
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weeklyNudge = ref.watch(weeklyReviewReminderProvider);
    final backupReminderOn = ref.watch(backupReminderEnabledProvider);
    final leadTime = ref.watch(reminderLeadTimeProvider);
    final deferSurface = ref.watch(deferSurfaceMinutesProvider);
    final status = ref.watch(notificationPermissionStatusProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersSection)),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          SettingsGroup(
            children: [_NotificationPermissionTile(status: status)],
          ),
          SettingsGroup(
            label: l10n.moreNudgesGroup,
            children: [
              SettingsSwitchRow(
                icon: Icons.alarm,
                title: l10n.weeklyReviewNudge,
                subtitle: l10n.weeklyReviewNudgeDescription,
                value: weeklyNudge,
                onChanged: (v) async {
                  await ref.read(weeklyReviewReminderProvider.notifier).set(v);
                  if (v) {
                    await ref.read(scheduleWeeklyReviewReminderProvider).call();
                    if (!context.mounted) return;
                    await ensureReminderDeliveryReachable(context, ref);
                  } else {
                    await ref.read(cancelWeeklyReviewReminderProvider).call();
                  }
                },
              ),
              SettingsSwitchRow(
                icon: Icons.event_repeat_outlined,
                title: l10n.weeklyBackupReminder,
                subtitle: l10n.weeklyBackupReminderDescription,
                value: backupReminderOn,
                onChanged: (v) async {
                  await ref.read(backupReminderEnabledProvider.notifier).set(v);
                  if (v) {
                    await ref.read(scheduleBackupReminderProvider).call();
                    if (!context.mounted) return;
                    await ensureReminderDeliveryReachable(context, ref);
                  } else {
                    await ref.read(cancelBackupReminderProvider).call();
                  }
                },
              ),
            ],
          ),
          SettingsGroup(
            label: l10n.moreTimingGroup,
            children: [
              SettingsRow(
                icon: Icons.notifications_active_outlined,
                title: l10n.remindBeforeDue,
                subtitle: leadTime == 0
                    ? l10n.remindBeforeDueOff
                    : '${_leadTimeLabel(l10n, leadTime)} · '
                          '${l10n.remindBeforeDueSuffix}',
                onTap: () async {
                  final picked = await showModalBottomSheet<int>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final m in _leadTimeChoices)
                            ListTile(
                              title: Text(_leadTimeLabel(l10n, m)),
                              trailing: leadTime == m
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () => Navigator.pop(context, m),
                            ),
                        ],
                      ),
                    ),
                  );
                  if (picked == null) return;
                  await ref.read(reminderLeadTimeProvider.notifier).set(picked);
                  if (picked > 0 && context.mounted) {
                    await ensureReminderDeliveryReachable(context, ref);
                  }
                },
              ),
              SettingsRow(
                icon: Icons.snooze_outlined,
                title: l10n.deferSurfaceLabel,
                subtitle:
                    '${_minutesLabel(context, deferSurface)} · '
                    '${l10n.deferSurfaceDescription}',
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: deferSurface ~/ 60,
                      minute: deferSurface % 60,
                    ),
                  );
                  if (picked == null) return;
                  await ref
                      .read(deferSurfaceMinutesProvider.notifier)
                      .set(picked.hour * 60 + picked.minute);
                  if (context.mounted) {
                    await ensureReminderDeliveryReachable(context, ref);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Locale-aware time-of-day label that honours the device's 12/24-hour
/// setting (e.g. "9:00 AM" or "09:00").
String _minutesLabel(BuildContext context, int minutesSinceMidnight) =>
    TimeOfDay(
      hour: minutesSinceMidnight ~/ 60,
      minute: minutesSinceMidnight % 60,
    ).format(context);

const _leadTimeChoices = [0, 10, 30, 60, 1440];

String _leadTimeLabel(AppLocalizations l10n, int minutes) => switch (minutes) {
  0 => l10n.moreLeadOff,
  10 => l10n.moreLead10,
  30 => l10n.moreLead30,
  60 => l10n.moreLead60,
  1440 => l10n.moreLead1440,
  _ => l10n.moreLeadOther(minutes),
};

/// State-adaptive notification status row. granted shows a quiet
/// confirmation; denied offers an in-app prompt; permanentlyDenied deep-
/// links to system Settings - all via the shared recovery helper.
class _NotificationPermissionTile extends ConsumerWidget {
  const _NotificationPermissionTile({required this.status});

  final NotificationPermission? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (status == null) {
      return ListTile(
        minTileHeight: 56,
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        title: Text(l10n.checkingNotificationStatus),
      );
    }
    final ui = notificationStatusUi(l10n, status!);
    final blocked = ui.actionLabel != null;
    final tile = ListTile(
      leading: SettingsIconBadge(
        icon: ui.icon,
        color: blocked ? scheme.error : null,
      ),
      title: Text(ui.title),
      subtitle: Text(ui.body),
      isThreeLine: blocked,
      trailing: blocked ? null : Icon(Icons.check, color: scheme.primary),
    );
    if (!blocked) return tile;
    // Action goes on its own full-width row below the status rather than
    // ListTile.trailing, where a long label + icon can overflow on narrow /
    // large-text screens.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: OutlinedButton.icon(
            icon: Icon(ui.actionIcon, size: 18),
            label: Text(ui.actionLabel!),
            onPressed: () async {
              await runNotificationPermissionRecovery(context, ref);
              ref.invalidate(notificationPermissionStatusProvider);
            },
          ),
        ),
      ],
    );
  }
}
