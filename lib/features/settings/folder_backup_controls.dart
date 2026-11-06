import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/automatic_folder_backup.dart';
import '../../core/folder_backup.dart';
import '../../l10n/gen/app_localizations.dart';
import 'settings_tiles.dart';

/// Turns automatic backups on or off. Turning on without a folder goes
/// straight to the folder picker, which enables backups once one is chosen.
Future<void> setAutomaticBackup(
  AutomaticFolderBackup controller,
  FolderBackupSettings settings,
  bool enabled,
) {
  if (enabled && settings.folder == null) return controller.chooseFolder();
  return controller.setEnabled(enabled);
}

/// The automatic-backup switch and, while it is on, the folder row. Rows only;
/// the caller supplies the surrounding [SettingsGroup].
class FolderBackupControls extends ConsumerWidget {
  const FolderBackupControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(automaticFolderBackupProvider);
    final controller = ref.read(automaticFolderBackupProvider.notifier);
    final settings = state.settings;
    return Column(
      children: [
        SettingsSwitchRow(
          key: const ValueKey('automatic_folder_backup'),
          icon: Icons.folder_copy_outlined,
          title: l10n.backupAutoTitle,
          subtitle: l10n.backupAutoSubtitle,
          value: settings.enabled,
          onChanged: state.busy
              ? null
              : (enabled) => setAutomaticBackup(controller, settings, enabled),
        ),
        if (settings.enabled)
          SettingsRow(
            key: const ValueKey('backup_folder'),
            icon: Icons.folder_open_outlined,
            title: settings.folder == null
                ? l10n.folderBackupChoose
                : l10n.backupFolderTitle,
            subtitle: settings.folder?.label,
            onTap: state.busy ? null : controller.chooseFolder,
          ),
      ],
    );
  }
}
