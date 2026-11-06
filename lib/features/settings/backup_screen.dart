import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/import_backup.dart';
import '../../application/providers.dart';
import '../../core/result.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/readable_page_body.dart';
import 'backup_io.dart';
import 'backup_status_card.dart';
import 'folder_backup_controls.dart';
import 'settings_tiles.dart';

/// Backup status, automatic folder backup, one-off export, and restore.
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreBackupRestore)),
      body: ReadablePageBody(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 32),
          children: [
            const BackupStatusCard(),
            SettingsGroup(
              label: l10n.backupGroupBackUp,
              children: [
                const FolderBackupControls(),
                // Builder so onTap reads the row's own RenderBox: the iOS share
                // sheet needs a sharePositionOrigin that is non-empty and within
                // the root view. The tapped row is always small and on-screen;
                // the enclosing (scrollable) list may not be.
                Builder(
                  builder: (tileContext) => SettingsRow(
                    icon: Icons.ios_share,
                    title: l10n.backupExportTitle,
                    subtitle: l10n.backupExportSubtitle,
                    chevron: false,
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
                          SnackBar(content: Text(l10n.exportBackupError(error))),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            SettingsGroup(
              label: l10n.backupGroupRestore,
              children: [
                SettingsRow(
                  key: const ValueKey('backup_restore'),
                  icon: Icons.cloud_download_outlined,
                  title: l10n.backupRestoreTitle,
                  subtitle: l10n.backupRestoreRowSubtitle,
                  onTap: () => _onRestore(context, ref),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Text(
                l10n.backupFootnote,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton(
                  onPressed: () => showBackupHowItWorks(context),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: Text(l10n.backupHowItWorks),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRestore(BuildContext context, WidgetRef ref) async {
    final source = await chooseRestoreSource(context);
    if (source == null || !context.mounted) return;

    final String? raw;
    switch (source) {
      case RestoreSource.folder:
        // The folder screen lists, previews and confirms on its own.
        await context.push('/settings/backup/restore');
        return;
      case RestoreSource.file:
        raw = await readBackupFile();
      case RestoreSource.paste:
        if (!context.mounted) return;
        raw = await showDialog<String>(
          context: context,
          builder: (_) => const PasteBackupDialog(),
        );
    }
    if (raw == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final importer = ref.read(importBackupProvider);
    final preview = importer.inspect(raw);
    if (!context.mounted) return;
    switch (preview) {
      case Err(:final error):
        debugPrint('Backup import rejected: $error');
        _snack(context, backupImportErrorMessage(l10n, error));
        return;
      case Ok(:final value):
        if (value.isEmpty) {
          _snack(context, l10n.moreBackupEmpty);
          return;
        }
        final confirmed = await confirmImport(context, value);
        if (confirmed != true || !context.mounted) return;
    }

    final payload = raw;
    final res = await withProgress(
      context,
      l10n.importingProgress,
      () => importer.call(payload),
    );
    if (!context.mounted) return;
    final message = switch (res) {
      Ok(:final value) => l10n.moreRestoredEntries(value),
      Err(:final error) => () {
        debugPrint('Backup import failed: $error');
        return backupImportErrorMessage(l10n, error);
      }(),
    };
    _snack(context, message);
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Localized, user-facing text for a [BackupImportError].
String backupImportErrorMessage(AppLocalizations l10n, BackupImportError e) =>
    switch (e.failure) {
      BackupImportFailure.empty => l10n.backupErrEmpty,
      BackupImportFailure.invalidJson => l10n.backupErrInvalidJson,
      BackupImportFailure.notBackup => l10n.backupErrNotBackup,
      BackupImportFailure.newerVersion => l10n.backupErrNewerVersion,
      BackupImportFailure.unrecognized => l10n.backupErrUnrecognized,
      BackupImportFailure.invalidData => l10n.backupErrInvalidData,
      BackupImportFailure.remindersNotRefreshed => l10n.backupErrReminders,
      BackupImportFailure.restoreFailed => l10n.backupErrRestoreFailed,
    };
