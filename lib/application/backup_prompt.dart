import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/folder_backup.dart';
import '../features/settings/settings_controller.dart';
import 'automatic_folder_backup.dart';
import 'providers.dart';

/// Kept (non-trashed) items needed before offering automatic backups. The
/// seeded sample adds a handful, so 20 means the user has captured real
/// material. Unlike "first inbox zero" it fires for people who never empty
/// the inbox, and it does not compete with the store-review prompt, which
/// already claims inbox zero as its moment.
const backupPromptMinItems = 20;

/// Pure gate for the one-time prompt. A folder that was ever chosen counts as
/// "already decided", even if automatic backups were later switched off.
bool shouldShowBackupPrompt({
  required bool done,
  required BackupFolder? folder,
  required int keptItems,
}) => !done && folder == null && keptItems >= backupPromptMinItems;

final backupPromptVisibleProvider = Provider<bool>((ref) {
  return shouldShowBackupPrompt(
    done: ref.watch(backupPromptDoneProvider),
    folder: ref.watch(automaticFolderBackupProvider).settings.folder,
    keptItems: ref.watch(keptItemCountProvider).valueOrNull ?? 0,
  );
});
