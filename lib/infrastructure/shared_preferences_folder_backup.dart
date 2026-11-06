import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/folder_backup.dart';

class SharedPreferencesFolderBackup implements FolderBackupPreferences {
  SharedPreferencesFolderBackup(this._prefs);
  final SharedPreferences _prefs;
  static const key = 'automatic_folder_backup_v1';

  @override
  FolderBackupSettings load() {
    try {
      final raw = jsonDecode(_prefs.getString(key) ?? '{}') as Map;
      final handle = raw['handle'] as String?;
      final label = raw['label'] as String?;
      if (handle == null || handle.isEmpty || label == null || label.isEmpty) {
        return const FolderBackupSettings();
      }
      return FolderBackupSettings(
        folder: BackupFolder(handle: handle, label: label),
        enabled: raw['enabled'] == true,
        lastSuccess: DateTime.tryParse(raw['lastSuccess'] as String? ?? ''),
        fingerprint: raw['fingerprint'] as String?,
        lastVerified: DateTime.tryParse(raw['lastVerified'] as String? ?? ''),
      );
    } catch (_) {
      return const FolderBackupSettings();
    }
  }

  @override
  Future<void> save(FolderBackupSettings settings) async {
    final ok = await _prefs.setString(
      key,
      jsonEncode({
        'handle': settings.folder?.handle,
        'label': settings.folder?.label,
        'enabled': settings.enabled,
        'lastSuccess': settings.lastSuccess?.toUtc().toIso8601String(),
        'fingerprint': settings.fingerprint,
        'lastVerified': settings.lastVerified?.toUtc().toIso8601String(),
      }),
    );
    if (!ok) throw StateError('Could not save backup preferences');
  }
}
