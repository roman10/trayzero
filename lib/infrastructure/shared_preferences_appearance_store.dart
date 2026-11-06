import 'package:shared_preferences/shared_preferences.dart';

import '../core/appearance_preferences.dart';

class SharedPreferencesAppearanceStore implements AppearancePreferencesStore {
  SharedPreferencesAppearanceStore(this._prefs);
  final SharedPreferences _prefs;

  // Preserve the existing light/dark/system setting, including old installs.
  static const _modeKey = 'theme_mode';
  static const _paletteKey = 'app_palette';

  @override
  AppearancePreferences load() => AppearancePreferences(
    mode: AppearanceMode.fromId(_string(_modeKey)),
    palette: AppPalette.fromId(_string(_paletteKey)),
  );

  String? _string(String key) {
    final value = _prefs.get(key);
    return value is String ? value : null;
  }

  @override
  Future<void> saveMode(AppearanceMode mode) => _save(_modeKey, mode.id);

  @override
  Future<void> savePalette(AppPalette palette) =>
      _save(_paletteKey, palette.id);

  Future<void> _save(String key, String value) async {
    if (!await _prefs.setString(key, value)) {
      throw StateError('Could not persist appearance');
    }
  }
}
