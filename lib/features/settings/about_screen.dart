import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../common/gtd_workflow_diagram.dart';
import 'legal_links.dart';
import 'settings_controller.dart';
import 'settings_tiles.dart';

/// What is GTD, onboarding replay, crash-report opt-in, version and legal.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final crashReporting = ref.watch(crashReportingEnabledProvider);
    final info = ref.watch(packageInfoProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreAboutPrivacy)),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.menu_book_outlined,
                title: l10n.whatIsGtd,
                onTap: () => showGtdWorkflowSheet(context),
              ),
              SettingsRow(
                icon: Icons.replay_circle_filled_outlined,
                title: l10n.showOnboardingAgain,
                onTap: () async {
                  await ref.read(onboardingCompleteProvider.notifier).reset();
                  if (!context.mounted) return;
                  context.go('/onboarding');
                },
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsSwitchRow(
                icon: Icons.bug_report_outlined,
                title: l10n.crashReports,
                subtitle: l10n.crashReportsDescription,
                value: crashReporting,
                onChanged: (v) async {
                  await ref.read(crashReportingEnabledProvider.notifier).set(v);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        v
                            ? l10n.crashReportsEnabled
                            : l10n.crashReportsDisabled,
                      ),
                    ),
                  );
                },
              ),
              SettingsRow(
                icon: Icons.info_outline,
                title: l10n.versionLabel,
                subtitle: info == null
                    ? '…'
                    : l10n.moreVersionBuild(info.version, info.buildNumber),
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: l10n.legalPrivacyPolicy,
                chevron: false,
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => openLegalUrl(context, kPrivacyPolicyUrl),
              ),
              SettingsRow(
                icon: Icons.description_outlined,
                title: l10n.legalTermsOfUse,
                chevron: false,
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => openLegalUrl(context, kTermsOfUseUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
