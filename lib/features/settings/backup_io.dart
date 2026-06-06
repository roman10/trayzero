import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../application/import_backup.dart';
import '../../l10n/gen/app_localizations.dart';

enum ImportSource { file, paste }

/// Runs [task] behind a non-dismissible progress dialog. A large import
/// (thousands of Google tasks) takes seconds; without this the screen looks
/// frozen. The dialog goes on the root navigator (showDialog's default), so
/// it is dismissed via the same root navigator.
Future<T> withProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() task,
) async {
  unawaited(showDialog<void>(
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
  ));
  try {
    return await task();
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

/// Bottom-sheet chooser: file is the recommended/primary path, paste is the
/// fallback. Returns null if dismissed.
Future<ImportSource?> chooseImportSource(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<ImportSource>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.importSourceSheetTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open_outlined),
            title: Text(l10n.importFromFileTitle),
            subtitle: Text(l10n.importFromFileDescription),
            onTap: () =>
                Navigator.of(sheetContext).pop(ImportSource.file),
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_outlined),
            title: Text(l10n.importFromPasteTitle),
            subtitle: Text(l10n.importFromPasteDescription),
            onTap: () =>
                Navigator.of(sheetContext).pop(ImportSource.paste),
          ),
          const SizedBox(height: 8),
        ],
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
  String n(int c, String singular) =>
      '$c $singular${c == 1 ? '' : 's'}';
  final parts = <String>[
    if (p.items > 0) n(p.items, 'item'),
    if (p.projects > 0) n(p.projects, 'project'),
    if (p.contexts > 0) n(p.contexts, 'context'),
    if (p.areas > 0) n(p.areas, 'area'),
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
        decoration: InputDecoration(
          hintText: l10n.pasteBackupHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed:
              hasText ? () => Navigator.of(context).pop(_ctrl.text) : null,
          child: Text(l10n.importButton),
        ),
      ],
    );
  }
}
