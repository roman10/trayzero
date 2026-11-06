import '../../application/calendar_connection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/locale_resolution.dart';
import '../../application/appearance_controller.dart';
import '../../application/automatic_folder_backup.dart';
import '../../application/billing_controller.dart';
import '../../application/providers.dart';
import '../../core/appearance_preferences.dart';
import '../../core/clock.dart';
import '../../core/folder_backup.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/gtd_workflow_diagram.dart';
import '../common/localized_dates.dart';
import 'app_color_picker.dart';
import 'reminders_status.dart';
import 'settings_controller.dart';
import 'settings_tiles.dart';

export 'legal_links.dart' show kPrivacyPolicyUrl, kTermsOfUseUrl;

/// The More tab: a flat, grouped hub that links to focused subpages. It holds
/// no settings logic of its own - each subpage owns its side-effects.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appearance = ref.watch(appearanceProvider);
    final locale = ref.watch(localeOverrideProvider);
    final remindersBlocked = ref.watch(remindersBlockedProvider);
    final folderBackup = ref.watch(automaticFolderBackupProvider);
    final supporter =
        ref.watch(supporterStatusProvider).valueOrNull?.isSupporter ?? false;
    final version = ref.watch(packageInfoProvider).valueOrNull?.version;
    final themeLabel = switch (appearance.mode) {
      AppearanceMode.system => l10n.themeFollowSystem,
      AppearanceMode.light => l10n.themeLight,
      AppearanceMode.dark => l10n.themeDark,
    };
    final contexts = ref.watch(contextsProvider).valueOrNull?.length;
    final tags = ref.watch(tagsProvider).valueOrNull?.length;
    final areas = ref.watch(areasProvider).valueOrNull?.length;
    final calendar = ref.watch(calendarConnectionProvider);

    final backupHealth = ref.watch(backupHealthProvider);
    final String backupSubtitle;
    if (backupHealth == BackupHealth.stale) {
      backupSubtitle = l10n.moreBackupSubtitleStale(
        ref
            .watch(clockProvider)
            .now()
            .difference(folderBackup.settings.lastHealthy!)
            .inDays,
      );
    } else if (folderBackup.failed) {
      backupSubtitle = l10n.moreBackupSubtitleFailed;
    } else if (!folderBackup.settings.enabled) {
      backupSubtitle = l10n.moreBackupSubtitleOff;
    } else if (folderBackup.settings.lastSuccess == null) {
      backupSubtitle = l10n.folderBackupNever;
    } else {
      backupSubtitle = l10n.folderBackupLastSuccess(
        DateFormat.yMMMd(
          l10n.dateLocaleName,
        ).add_jm().format(folderBackup.settings.lastSuccess!.toLocal()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          if (remindersBlocked)
            AttentionBanner(
              icon: Icons.notifications_off_outlined,
              title: l10n.moreRemindersBlockedTitle,
              body: l10n.moreRemindersBlockedBody,
              actionLabel: l10n.moreFix,
              onAction: () => context.push('/settings/reminders'),
            )
          else if (folderBackup.failed)
            AttentionBanner(
              icon: Icons.error_outline,
              title: l10n.moreBackupFailedTitle,
              body: l10n.moreBackupFailedBody,
              actionLabel: l10n.moreFix,
              onAction: () => context.push('/settings/backup'),
            ),
          SettingsGroup(
            label: l10n.moreGroupOrganize,
            children: [
              SettingsRow(
                icon: Icons.label_outline,
                title: l10n.contextsLabel,
                trailingText: contexts?.toString(),
                onTap: () => context.push('/settings/contexts'),
              ),
              SettingsRow(
                icon: Icons.sell_outlined,
                title: l10n.tagsAndPeopleLabel,
                trailingText: tags?.toString(),
                onTap: () => context.push('/settings/tags'),
              ),
              SettingsRow(
                icon: Icons.flag_outlined,
                title: l10n.areasOfFocusLabel,
                trailingText: areas?.toString(),
                onTap: () => context.push('/settings/areas'),
              ),
              SettingsRow(
                icon: Icons.event_note_outlined,
                title: l10n.calendarConnectionTitle,
                trailingText: calendar.issue != null
                    ? l10n.calendarNeedsAttention
                    : calendar.settings.removing
                    ? l10n.calendarRemovalPending
                    : !calendar.settings.connected
                    ? l10n.moreOff
                    : calendar.settings.automatic
                    ? l10n.calendarConnected
                    : l10n.calendarPaused,
                onTap: () => context.push('/settings/calendar-sync'),
              ),
            ],
          ),
          SettingsGroup(
            label: l10n.moreGroupPreferences,
            children: [
              SettingsRow(
                icon: Icons.palette_outlined,
                title: l10n.appearanceSection,
                subtitle: l10n.moreAppearanceSummary(
                  themeLabel,
                  paletteLabel(l10n, appearance.palette),
                ),
                onTap: () => context.push('/settings/appearance'),
              ),
              SettingsRow(
                icon: Icons.notifications_active_outlined,
                title: l10n.remindersSection,
                trailing: remindersBlocked
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : null,
                onTap: () => context.push('/settings/reminders'),
              ),
              SettingsRow(
                icon: Icons.translate_outlined,
                title: l10n.languageLabel,
                subtitle: locale == null
                    ? l10n.languageFollowSystem
                    : _localeEndonym(locale),
                onTap: () async {
                  final choice = await showModalBottomSheet<_LangChoice>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => _LanguagePicker(current: locale),
                  );
                  if (choice != null) {
                    await ref
                        .read(localeOverrideProvider.notifier)
                        .set(choice.locale);
                  }
                },
              ),
            ],
          ),
          SettingsGroup(
            label: l10n.moreGroupData,
            children: [
              SettingsRow(
                icon: Icons.cloud_upload_outlined,
                title: l10n.moreBackupRestore,
                subtitle: backupSubtitle,
                trailing: backupHealth == BackupHealth.stale
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : null,
                onTap: () => context.push('/settings/backup'),
              ),
              SettingsRow(
                icon: Icons.move_down_outlined,
                title: l10n.importFromApp,
                subtitle: l10n.moreImportSources,
                onTap: () => context.push('/settings/import'),
              ),
            ],
          ),
          SettingsGroup(
            label: l10n.appName,
            children: [
              SettingsRow(
                icon: Icons.favorite,
                title: l10n.supportTitle,
                trailingText: supporter
                    ? l10n.moreSupportTrailingSupporter
                    : l10n.moreSupportTrailing,
                onTap: () => context.push('/settings/support'),
              ),
              SettingsRow(
                icon: Icons.menu_book_outlined,
                title: l10n.moreHowGtdWorks,
                onTap: () => showGtdWorkflowSheet(context),
              ),
              SettingsRow(
                icon: Icons.info_outline,
                title: l10n.moreAboutPrivacy,
                trailingText: version,
                onTap: () => context.push('/settings/about'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.settingsFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Endonym (native-language name) for a supported locale. Names read the same
/// regardless of the app's current language, so they live here rather than in
/// the ARB files.
String _localeEndonym(Locale l) => switch (localeToTag(l)) {
  'de' => 'Deutsch',
  'en' => 'English',
  'es' => 'Español',
  'fr' => 'Français',
  'ja' => '日本語',
  'ko' => '한국어',
  'pt' => 'Português',
  'ru' => 'Русский',
  'zh' => '简体中文',
  'zh-Hant' => '繁體中文',
  _ => l.languageCode,
};

/// Result of the language sheet. Wraps a nullable [Locale] so "System default"
/// (locale == null) is distinguishable from a dismissed sheet (result == null).
class _LangChoice {
  const _LangChoice(this.locale);
  final Locale? locale;
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.current});
  final Locale? current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(l10n.languageFollowSystem),
            trailing: current == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, const _LangChoice(null)),
          ),
          const Divider(height: 1),
          for (final loc in AppLocalizations.supportedLocales)
            ListTile(
              title: Text(_localeEndonym(loc)),
              trailing:
                  current != null &&
                      current!.languageCode == loc.languageCode &&
                      current!.scriptCode == loc.scriptCode
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, _LangChoice(loc)),
            ),
        ],
      ),
    );
  }
}
