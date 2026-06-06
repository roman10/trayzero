import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/billing_controller.dart';
import '../../application/providers.dart';
import '../../core/billing.dart';
import '../../core/notification_scheduler.dart';
import '../../core/result.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/notification_permission_recovery.dart';
import '../common/reminder_delivery_recovery.dart';
import 'backup_io.dart';
import 'settings_controller.dart';

/// Public legal pages, shown from the Support section so the app's purchase
/// flow links to them (required for auto-renewable subscriptions on iOS).
const String kPrivacyPolicyUrl = 'https://trayzero.app/privacy';
const String kTermsOfUseUrl = 'https://trayzero.app/terms';

/// Opens a legal page externally; mirrors [NotesText]'s launch idiom and
/// shows a snackbar if the URL can't be opened.
Future<void> _openLegalUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open link")),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't open link")),
    );
  }
}

/// Settings as a list of collapsible sections. Each section persists its
/// expand/collapse state per-user. Side-effects (notification scheduling,
/// backup export/import) all flow through use cases in `lib/application/`
/// so this screen contains only presentation.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        children: const [
          _AppearanceSection(),
          _OrganisationSection(),
          _RemindersSection(),
          _DataSection(),
          _PrivacySection(),
          _AboutSection(),
          _SupportSection(),
          SizedBox(height: 32),
          _Footer(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Shared shell: a single ExpansionTile per section, persisted state, and
/// a one-line summary visible when collapsed.
class _Section extends ConsumerWidget {
  const _Section({
    required this.id,
    required this.title,
    required this.summary,
    required this.children,
  });
  final String id;
  final String title;
  final String summary;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(settingsSectionExpandedProvider(id));
    return ExpansionTile(
      key: PageStorageKey<String>('settings_section_$id'),
      initiallyExpanded: expanded,
      onExpansionChanged: (v) =>
          ref.read(settingsSectionExpandedProvider(id).notifier).set(v),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      children: children,
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    final haptics = ref.watch(hapticsEnabledProvider);
    final themeLabel = switch (mode) {
      ThemeMode.system => l10n.themeFollowSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
    return _Section(
      id: 'appearance',
      title: l10n.appearanceSection,
      summary: '$themeLabel · Haptics ${haptics ? 'on' : 'off'}',
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: Text(l10n.themeLabel),
          subtitle: Text(switch (mode) {
            ThemeMode.system => l10n.themeFollowSystem,
            ThemeMode.light => l10n.themeLight,
            ThemeMode.dark => l10n.themeDark,
          }),
          onTap: () async {
            final picked = await showModalBottomSheet<ThemeMode>(
              context: context,
              showDragHandle: true,
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final m in ThemeMode.values)
                      ListTile(
                        title: Text(switch (m) {
                          ThemeMode.system => l10n.themeFollowSystem,
                          ThemeMode.light => l10n.themeLight,
                          ThemeMode.dark => l10n.themeDark,
                        }),
                        trailing: mode == m ? const Icon(Icons.check) : null,
                        onTap: () => Navigator.pop(context, m),
                      ),
                  ],
                ),
              ),
            );
            if (picked != null) {
              await ref.read(themeModeProvider.notifier).set(picked);
            }
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.vibration_outlined),
          title: Text(l10n.hapticFeedback),
          value: haptics,
          onChanged: (v) => ref.read(hapticsEnabledProvider.notifier).set(v),
        ),
      ],
    );
  }
}

class _OrganisationSection extends ConsumerWidget {
  const _OrganisationSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      id: 'organisation',
      title: l10n.organizationSection,
      summary: 'Contexts, areas, calendar sync',
      children: [
        ListTile(
          leading: const Icon(Icons.label_outline),
          title: Text(l10n.contextsLabel),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/contexts'),
        ),
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(l10n.areasOfFocusLabel),
          subtitle: Text(l10n.areasOfFocusDescription),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/areas'),
        ),
        ListTile(
          leading: const Icon(Icons.event_note_outlined),
          title: Text(l10n.calendarSyncLabel),
          subtitle: Text(l10n.calendarSyncDescription),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/calendar-sync'),
        ),
      ],
    );
  }
}

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weeklyNudge = ref.watch(weeklyReviewReminderProvider);
    final leadTime = ref.watch(reminderLeadTimeProvider);
    final deferSurface = ref.watch(deferSurfaceMinutesProvider);
    final status = ref.watch(notificationPermissionStatusProvider).valueOrNull;
    final summarySuffix = switch (status) {
      NotificationPermission.denied => ' · reminders off',
      NotificationPermission.permanentlyDenied => ' · reminders blocked',
      _ => '',
    };
    return _Section(
      id: 'reminders',
      title: l10n.remindersSection,
      summary:
          'Weekly nudge ${weeklyNudge ? 'on' : 'off'} · '
          'lead ${_leadTimeLabel(leadTime).toLowerCase()} · '
          'defer ${_minutesLabel(context, deferSurface)}$summarySuffix',
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.alarm),
          title: Text(l10n.weeklyReviewNudge),
          subtitle: Text(l10n.weeklyReviewNudgeDescription),
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
        ListTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: Text(l10n.remindBeforeDue),
          subtitle: Text(
            leadTime == 0
                ? l10n.remindBeforeDueOff
                : '${_leadTimeLabel(leadTime)} · ${l10n.remindBeforeDueSuffix}',
          ),
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
                        title: Text(_leadTimeLabel(m)),
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
        ListTile(
          leading: const Icon(Icons.snooze_outlined),
          title: Text(l10n.deferSurfaceLabel),
          subtitle: Text(
            '${_minutesLabel(context, deferSurface)} · '
            '${l10n.deferSurfaceDescription}',
          ),
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
        _NotificationPermissionTile(status: status),
      ],
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

String _leadTimeLabel(int minutes) => switch (minutes) {
  0 => 'Off',
  10 => '10 minutes before',
  30 => '30 minutes before',
  60 => '1 hour before',
  1440 => '1 day before',
  _ => '$minutes minutes before',
};

/// State-adaptive notification status row. Replaces the old misleading
/// "Request notification permission" dead-end: granted shows a quiet
/// confirmation; denied offers an in-app prompt; permanentlyDenied deep-
/// links to system Settings — all via the shared recovery helper.
class _NotificationPermissionTile extends ConsumerWidget {
  const _NotificationPermissionTile({required this.status});

  final NotificationPermission? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (status == null) {
      return ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        title: Text(l10n.checkingNotificationStatus),
      );
    }
    final ui = notificationStatusUi(status!);
    final tile = ListTile(
      leading: Icon(ui.icon),
      title: Text(ui.title),
      subtitle: Text(ui.body),
      isThreeLine: status != NotificationPermission.granted,
      trailing: ui.actionLabel == null
          ? Icon(Icons.check, color: scheme.primary)
          : null,
    );
    if (ui.actionLabel == null) return tile;
    // Action goes on its own full-width row below the status (mirrors the
    // calendar-sync denied idiom) rather than ListTile.trailing, where a
    // long label + icon can overflow on narrow / large-text screens.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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

class _DataSection extends ConsumerWidget {
  const _DataSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final backupReminderOn = ref.watch(backupReminderEnabledProvider);
    return _Section(
      id: 'data',
      title: l10n.dataSection,
      summary: 'Backup ${backupReminderOn ? 'reminder on' : 'reminder off'}',
      children: [
        // Builder so onTap reads the tile's own RenderBox: the iOS share
        // sheet needs a sharePositionOrigin that is non-empty and within the
        // root view. The tapped tile is always small and on-screen; the
        // enclosing (scrollable) section may not be.
        Builder(
          builder: (tileContext) => ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: Text(l10n.exportBackup),
            subtitle: Text(
              Platform.isIOS
                  ? l10n.exportBackupDescriptionIos
                  : l10n.exportBackupDescriptionAndroid,
            ),
            onTap: () async {
              final box = tileContext.findRenderObject() as RenderBox?;
              final origin = (box != null && box.hasSize)
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null;
              final res = await ref
                  .read(exportBackupProvider)
                  .call(sharePositionOrigin: origin);
              if (!tileContext.mounted) return;
              if (res case Err(:final error)) {
                ScaffoldMessenger.of(tileContext).showSnackBar(
                  SnackBar(
                    content: Text(l10n.exportBackupError(error)),
                  ),
                );
              }
            },
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.event_repeat_outlined),
          title: Text(l10n.weeklyBackupReminder),
          subtitle: Text(l10n.weeklyBackupReminderDescription),
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
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined),
          title: Text(l10n.importBackup),
          subtitle: Text(l10n.importBackupDescription),
          onTap: () => _onImport(context, ref),
        ),
      ],
    );
  }

  Future<void> _onImport(BuildContext context, WidgetRef ref) async {
    final source = await chooseImportSource(context);
    if (source == null || !context.mounted) return;

    final String? raw;
    switch (source) {
      case ImportSource.file:
        raw = await readBackupFile();
      case ImportSource.paste:
        if (!context.mounted) return;
        raw = await _showPasteDialog(context);
    }
    if (raw == null || !context.mounted) return;

    final importer = ref.read(importBackupProvider);
    final preview = importer.inspect(raw);
    if (!context.mounted) return;
    switch (preview) {
      case Err(:final error):
        _snack(context, error);
        return;
      case Ok(:final value):
        if (value.isEmpty) {
          _snack(context, 'This backup has no entries to restore.');
          return;
        }
        final confirmed = await confirmImport(context, value);
        if (confirmed != true || !context.mounted) return;
    }

    final payload = raw;
    final res = await withProgress(
      context,
      AppLocalizations.of(context).importingProgress,
      () => importer.call(payload),
    );
    if (!context.mounted) return;
    final message = switch (res) {
      Ok(:final value) =>
        'Restored $value ${value == 1 ? 'entry' : 'entries'}.',
      Err(:final error) => error,
    };
    _snack(context, message);
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final crashReporting = ref.watch(crashReportingEnabledProvider);
    return _Section(
      id: 'privacy',
      title: l10n.privacySection,
      summary: 'Crash reports ${crashReporting ? 'on' : 'off'}',
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.bug_report_outlined),
          title: Text(l10n.crashReports),
          subtitle: Text(l10n.crashReportsDescription),
          value: crashReporting,
          onChanged: (v) async {
            await ref.read(crashReportingEnabledProvider.notifier).set(v);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  v ? l10n.crashReportsEnabled : l10n.crashReportsDisabled,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AboutSection extends ConsumerWidget {
  const _AboutSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      id: 'about',
      title: l10n.aboutSection,
      summary: 'GTD primer, version, onboarding',
      children: [
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(l10n.whatIsGtd),
          onTap: () => showGtdWorkflowSheet(context),
        ),
        ListTile(
          leading: const Icon(Icons.replay_circle_filled_outlined),
          title: Text(l10n.showOnboardingAgain),
          onTap: () async {
            await ref.read(onboardingCompleteProvider.notifier).reset();
            if (!context.mounted) return;
            context.go('/onboarding');
          },
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            final subtitle = info == null
                ? '…'
                : '${info.version} (build ${info.buildNumber})';
            return ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.versionLabel),
              subtitle: Text(subtitle),
            );
          },
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          AppLocalizations.of(context).settingsFooter,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

Future<String?> _showPasteDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const PasteBackupDialog(),
  );
}


/// Support: optional tips + supporter purchases. Nothing here gates a
/// feature - tips are consumable thank-yous and the supporter entitlement
/// only unlocks cosmetic perks. The section degrades to an "unavailable"
/// note when billing is off or the offering can't load.
class _SupportSection extends ConsumerWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final offeringsAsync = ref.watch(billingOfferingsProvider);
    final status = ref.watch(supporterStatusProvider).valueOrNull;
    final isSupporter = status?.isSupporter ?? false;

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Text(l10n.supportIntro),
      ),
    ];

    if (isSupporter && status != null) {
      children.add(_supporterBadge(context, l10n, status));
    }

    children.addAll(
      offeringsAsync.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
        error: (error, _) {
          debugPrint('[billing] offerings load failed: $error');
          return [_unavailableNote(l10n)];
        },
        data: (offerings) {
          if (offerings == null || offerings.isEmpty) {
            return [_unavailableNote(l10n)];
          }
          return _purchaseTiles(
            context,
            ref,
            l10n,
            offerings,
            isSupporter,
          );
        },
      ),
    );

    children.add(
      ListTile(
        dense: true,
        leading: const Icon(Icons.restore),
        title: Text(l10n.supportRestore),
        subtitle: Text(l10n.supportRestoreSubtitle),
        onTap: () => _restorePurchases(context, ref, l10n),
      ),
    );

    // Functional links to the privacy policy and Terms of Use (EULA), required
    // inside the purchase flow for auto-renewable subscriptions (App Store).
    children.add(
      ListTile(
        dense: true,
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text(l10n.legalPrivacyPolicy),
        trailing: const Icon(Icons.open_in_new, size: 16),
        onTap: () => _openLegalUrl(context, kPrivacyPolicyUrl),
      ),
    );
    children.add(
      ListTile(
        dense: true,
        leading: const Icon(Icons.description_outlined),
        title: Text(l10n.legalTermsOfUse),
        trailing: const Icon(Icons.open_in_new, size: 16),
        onTap: () => _openLegalUrl(context, kTermsOfUseUrl),
      ),
    );

    return _Section(
      id: 'support',
      title: l10n.supportTitle,
      summary:
          isSupporter ? l10n.supportSummarySupporter : l10n.supportSummaryDefault,
      children: children,
    );
  }
}

Widget _unavailableNote(AppLocalizations l10n) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(l10n.supportUnavailable),
    );

Widget _supporterBadge(
  BuildContext context,
  AppLocalizations l10n,
  SupporterStatus status,
) {
  final theme = Theme.of(context);
  final label = switch (status.activePlan) {
    SupporterPlan.yearly => l10n.supportBadgeYearly,
    SupporterPlan.monthly => l10n.supportBadgeMonthly,
    null => l10n.supportBadgeGeneric,
  };
  return ListTile(
    dense: true,
    leading: Icon(Icons.favorite, color: theme.colorScheme.primary),
    title: Text(label, style: theme.textTheme.titleSmall),
    subtitle: Text(l10n.supportBadgeSubtitle),
  );
}

List<Widget> _purchaseTiles(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  BillingOfferings offerings,
  bool isSupporter,
) {
  final tiles = <Widget>[];
  final yearly = offerings.yearly;
  final monthly = offerings.monthly;

  // Recurring plans are hidden once already a supporter, to avoid an
  // accidental second subscription. Tips stay available to everyone.
  if (!isSupporter) {
    if (yearly != null) {
      tiles.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(l10n.supportSupporterYearly),
          subtitle: Text(l10n.supportSupporterYearlySubtitle(yearly.priceString)),
          onTap: () => _purchasePlan(context, ref, l10n, SupporterPlan.yearly),
        ),
      );
    }
    if (monthly != null) {
      tiles.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(l10n.supportSupporterMonthly),
          subtitle:
              Text(l10n.supportSupporterMonthlySubtitle(monthly.priceString)),
          onTap: () => _purchasePlan(context, ref, l10n, SupporterPlan.monthly),
        ),
      );
    }
    if (yearly != null || monthly != null) {
      tiles.add(
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
          child: Text(
            l10n.supportAutoRenewNote,
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
  }

  if (offerings.tips.isNotEmpty) {
    tiles.add(
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
        child: Text(
          l10n.supportTipHeader,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
    for (final tip in offerings.tips) {
      final (label, tier) = switch (tip.id) {
        BillingIds.tipSmall => (l10n.supportTipSmall, TipTier.small),
        BillingIds.tipLarge => (l10n.supportTipLarge, TipTier.large),
        _ => (tip.title, TipTier.small),
      };
      tiles.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.local_cafe_outlined),
          title: Text(label),
          subtitle: Text(tip.priceString),
          onTap: () => _purchaseTip(context, ref, l10n, tier),
        ),
      );
    }
  }

  return tiles;
}

Future<void> _purchaseTip(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  TipTier tier,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref.read(billingControllerProvider).tip(tier);
  _showOutcome(messenger, outcome, l10n.supportThanksTip);
}

Future<void> _purchasePlan(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  SupporterPlan plan,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref.read(billingControllerProvider).becomeSupporter(plan);
  _showOutcome(messenger, outcome, l10n.supportThanksSupporter);
}

Future<void> _restorePurchases(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref.read(billingControllerProvider).restore();
  switch (outcome) {
    case PurchaseSucceeded(:final status):
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status.isSupporter ? l10n.supportRestored : l10n.supportRestoreNone,
          ),
        ),
      );
    case PurchaseFailed(:final message):
      messenger.showSnackBar(SnackBar(content: Text(message)));
    case PurchaseCancelled():
      break;
  }
}

void _showOutcome(
  ScaffoldMessengerState messenger,
  PurchaseOutcome outcome,
  String successMessage,
) {
  switch (outcome) {
    case PurchaseSucceeded():
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    case PurchaseFailed(:final message):
      messenger.showSnackBar(SnackBar(content: Text(message)));
    case PurchaseCancelled():
      break;
  }
}
