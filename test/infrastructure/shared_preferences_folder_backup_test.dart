import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/infrastructure/shared_preferences_folder_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('defaults off and tolerates corrupt preferences', () async {
    for (final raw in [null, '{broken', '{"handle": 4}', '{}']) {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesFolderBackup.key: ?raw,
      });
      final store = SharedPreferencesFolderBackup(
        await SharedPreferences.getInstance(),
      );
      expect(store.load().enabled, false);
      expect(store.load().folder, null);
    }
  });
  test(
    'folder, disabled state, timestamp and fingerprint survive restart',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesFolderBackup(
        await SharedPreferences.getInstance(),
      );
      final date = DateTime.utc(2026, 10, 16);
      await store.save(
        FolderBackupSettings(
          folder: const BackupFolder(
            handle: 'opaque-bookmark',
            label: 'Backups',
          ),
          lastSuccess: date,
          fingerprint: 'hash',
        ),
      );
      final restored = store.load();
      expect(restored.enabled, false);
      expect(restored.folder!.handle, 'opaque-bookmark');
      expect(restored.lastSuccess, date);
      expect(restored.fingerprint, 'hash');
    },
  );
}
