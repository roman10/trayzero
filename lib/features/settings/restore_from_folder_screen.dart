import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/folder_restore.dart';
import '../../core/result.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_dates.dart';
import '../common/readable_page_body.dart';
import 'backup_io.dart';
import 'backup_screen.dart' show backupImportErrorMessage;
import 'settings_controller.dart';

/// Lists the Trayzero backups found in a folder and restores the one the user
/// taps (ADR 0013). Reached from Backup & restore and from the first
/// onboarding page; [fromOnboarding] finishes onboarding after a restore
/// instead of returning to the previous screen.
class RestoreFromFolderScreen extends ConsumerStatefulWidget {
  const RestoreFromFolderScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<RestoreFromFolderScreen> createState() =>
      _RestoreFromFolderScreenState();
}

class _RestoreFromFolderScreenState
    extends ConsumerState<RestoreFromFolderScreen> {
  @override
  void initState() {
    super.initState();
    // Reuse the folder automatic backups already write to.
    Future.microtask(
      () => ref
          .read(folderRestoreControllerProvider.notifier)
          .useConfiguredFolder(),
    );
  }

  Future<void> _restore(RestoreEntry entry) async {
    final preview = entry.preview;
    if (preview == null) return;
    final l10n = AppLocalizations.of(context);
    // Captured now: the screen may already be gone when the result arrives.
    final messenger = ScaffoldMessenger.of(context);
    void snack(String m) => messenger.showSnackBar(SnackBar(content: Text(m)));
    if (preview.isEmpty) {
      snack(l10n.moreBackupEmpty);
      return;
    }
    final confirmed = await confirmImport(context, preview);
    if (confirmed != true || !mounted) return;
    final res = await withProgress(
      context,
      l10n.importingProgress,
      () => ref.read(folderRestoreControllerProvider.notifier).restore(entry),
    );
    if (!mounted) return;
    switch (res) {
      case Err(:final error):
        snack(backupImportErrorMessage(l10n, error));
      case Ok(:final value):
        if (widget.fromOnboarding) {
          await ref.read(onboardingCompleteProvider.notifier).complete();
          if (!mounted) return;
          context.go('/inbox');
        } else {
          context.pop();
        }
        snack(l10n.moreRestoredEntries(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(folderRestoreControllerProvider);
    final controller = ref.read(folderRestoreControllerProvider.notifier);
    final dateFormat = DateFormat.yMMMd(l10n.dateLocaleName).add_jm();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.restoreFolderTitle)),
      body: ReadablePageBody(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                l10n.restoreFolderIntro,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
              ),
            ),
            ListTile(
              key: const ValueKey('restore_choose_folder'),
              leading: const Icon(Icons.folder_open_outlined),
              title: Text(
                state.folder == null
                    ? l10n.restoreFolderChoose
                    : l10n.restoreFolderChange,
              ),
              subtitle: state.folder == null
                  ? null
                  : Text(l10n.restoreFolderFrom(state.folder!.label)),
              onTap: state.loading ? null : controller.chooseFolder,
            ),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.failed)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.restoreFolderFailed,
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ),
            if (state.listed && state.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(l10n.restoreFolderEmpty),
              ),
            for (final entry in state.entries)
              ListTile(
                key: ValueKey('restore_${entry.snapshot.id}'),
                leading: const Icon(Icons.history),
                title: Text(
                  entry.snapshot.takenAt == null
                      ? entry.snapshot.name
                      : dateFormat.format(entry.snapshot.takenAt!.toLocal()),
                ),
                subtitle: Text(
                  entry.unreadable
                      ? l10n.restoreFolderUnreadable
                      : entry.preview == null
                      ? l10n.restoreFolderReading
                      : l10n.restoreFolderItemCount(entry.preview!.items),
                ),
                enabled: entry.preview != null,
                onTap: entry.preview == null ? null : () => _restore(entry),
              ),
          ],
        ),
      ),
    );
  }
}
