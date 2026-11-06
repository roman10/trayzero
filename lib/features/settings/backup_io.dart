import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../application/import_backup.dart';
import '../../l10n/gen/app_localizations.dart';
import 'settings_tiles.dart';

enum RestoreSource { folder, file, paste }

/// Runs [task] behind a non-dismissible progress dialog. A large import
/// (thousands of Google tasks) takes seconds; without this the screen looks
/// frozen. The dialog goes on the root navigator (showDialog's default), so
/// it is dismissed via the same root navigator.
Future<T> withProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() task,
) async {
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

/// Bottom-sheet chooser for where a backup to restore lives. Nothing is
/// changed by choosing; every path previews before it restores. Returns null
/// if dismissed.
Future<RestoreSource?> chooseRestoreSource(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<RestoreSource>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.backupRestoreTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l10n.backupRestoreSheetBody,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.35),
              ),
            ),
            ListTile(
              key: const ValueKey('restore_source_folder'),
              minTileHeight: 56,
              leading: const SettingsIconBadge(icon: Icons.folder_zip_outlined),
              title: Text(l10n.backupRestoreFromFolder),
              subtitle: Text(l10n.backupRestoreFromFolderHint),
              onTap: () => Navigator.of(sheetContext).pop(RestoreSource.folder),
            ),
            ListTile(
              key: const ValueKey('restore_source_file'),
              minTileHeight: 56,
              leading: const SettingsIconBadge(
                icon: Icons.insert_drive_file_outlined,
              ),
              title: Text(l10n.backupRestoreFromFile),
              subtitle: Text(l10n.backupRestoreFromFileHint),
              onTap: () => Navigator.of(sheetContext).pop(RestoreSource.file),
            ),
            ListTile(
              key: const ValueKey('restore_source_paste'),
              minTileHeight: 56,
              leading: const SettingsIconBadge(
                icon: Icons.content_paste_outlined,
              ),
              title: Text(l10n.backupRestorePaste),
              subtitle: Text(l10n.importFromPasteDescription),
              onTap: () => Navigator.of(sheetContext).pop(RestoreSource.paste),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

/// Opens the OS file picker for a single `.json` backup and returns its
/// text, or null if the user cancelled. Malformed bytes are returned as-is
/// so the use case can surface a precise "not valid JSON" message.
Future<String?> readBackupFile() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;
  final bytes = result.files.first.bytes;
  if (bytes == null) return null;
  return utf8.decode(bytes, allowMalformed: true);
}

Future<bool?> confirmImport(BuildContext context, BackupPreview p) {
  final l10n = AppLocalizations.of(context);
  final parts = <String>[
    if (p.items > 0) l10n.backupCountItems(p.items),
    if (p.projects > 0) l10n.backupCountProjects(p.projects),
    if (p.contexts > 0) l10n.backupCountContexts(p.contexts),
    if (p.areas > 0) l10n.backupCountAreas(p.areas),
    if (p.attachments > 0) l10n.backupCountAttachments(p.attachments),
    if (p.reviews > 0) l10n.backupCountReviews(p.reviews),
  ];
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.importConfirmTitle),
      content: Text(l10n.importConfirmBody(parts.join(', '))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.importButton),
        ),
      ],
    ),
  );
}

/// Stateful so the Import button stays disabled until there is non-blank
/// text, and so dismissal uses the dialog's own Navigator (not the shell
/// route's, which previously caused a black screen).
class PasteBackupDialog extends StatefulWidget {
  const PasteBackupDialog({super.key});
  @override
  State<PasteBackupDialog> createState() => _PasteBackupDialogState();
}

class _PasteBackupDialogState extends State<PasteBackupDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasText = _ctrl.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(l10n.importFromPasteTitle),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        minLines: 6,
        maxLines: 10,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: l10n.pasteBackupHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: hasText
              ? () => Navigator.of(context).pop(_ctrl.text)
              : null,
          child: Text(l10n.importButton),
        ),
      ],
    );
  }
}

/// A short, offline explanation of what folder backup does and how to move
/// to another device with it.
Future<void> showBackupHowItWorks(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.backupHowTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            for (final text in [
              l10n.backupHowSaves,
              l10n.backupHowSync,
              l10n.backupHowMove,
            ]) ...[
              const SizedBox(height: 12),
              Text(
                text,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
