import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/automatic_folder_backup.dart';
import '../../l10n/gen/app_localizations.dart';
import 'settings_controller.dart';

/// One-time, dismissible suggestion to turn on automatic folder backups
/// (ADR 0013). Non-blocking: it sits above the Inbox list, and either button
/// retires it for good. Cancelling the folder picker keeps it visible, since
/// nothing was decided.
class BackupPromptCard extends ConsumerWidget {
  const BackupPromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final busy = ref.watch(automaticFolderBackupProvider).busy;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        key: const ValueKey('backup_prompt'),
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.folder_copy_outlined,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.backupPromptTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Text(
                  l10n.backupPromptBody,
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  children: [
                    TextButton(
                      key: const ValueKey('backup_prompt_dismiss'),
                      onPressed: () =>
                          ref.read(backupPromptDoneProvider.notifier).set(true),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSecondaryContainer,
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(l10n.backupPromptDismiss),
                    ),
                    TextButton(
                      key: const ValueKey('backup_prompt_enable'),
                      onPressed: busy
                          ? null
                          : () async {
                              final controller = ref.read(
                                automaticFolderBackupProvider.notifier,
                              );
                              await controller.chooseFolder();
                              if (ref
                                  .read(automaticFolderBackupProvider)
                                  .settings
                                  .enabled) {
                                await ref
                                    .read(backupPromptDoneProvider.notifier)
                                    .set(true);
                              }
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSecondaryContainer,
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(l10n.backupPromptAction),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
