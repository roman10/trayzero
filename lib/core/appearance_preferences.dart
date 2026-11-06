import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stable storage identifiers, independent of Flutter and localized labels.
enum AppearanceMode {
  system('system'),
  light('light'),
  dark('dark');

  const AppearanceMode(this.id);
  final String id;

  static AppearanceMode fromId(String? id) =>
      values.firstWhere((mode) => mode.id == id, orElse: () => system);
}

const trayzeroSeedArgb = 0xFFD2601F;

enum AppPalette {
  amber('amber', trayzeroSeedArgb),
  blue('blue', 0xFF1565C0),
  cyan('cyan', 0xFF00BCD4),
  teal('teal', 0xFF00838F),
  green('green', 0xFF2E7D32),
  violet('violet', 0xFF6750A4),
  rose('rose', 0xFFB32658);

  const AppPalette(this.id, this.seedArgb);
  final String id;

  /// Palette colors for Flutter themes and app icon notification accents.
  final int seedArgb;

  static AppPalette fromId(String? id) =>
      values.firstWhere((palette) => palette.id == id, orElse: () => amber);
}

class AppearancePreferences {
  const AppearancePreferences({
    this.mode = AppearanceMode.system,
    this.palette = AppPalette.amber,
  });

  final AppearanceMode mode;
  final AppPalette palette;

  AppearancePreferences copyWith({AppearanceMode? mode, AppPalette? palette}) =>
      AppearancePreferences(
        mode: mode ?? this.mode,
        palette: palette ?? this.palette,
      );
}

/// Preferences are preloaded at bootstrap, so the first frame uses the saved
/// appearance. Failed writes throw; the controller restores the saved value.
abstract class AppearancePreferencesStore {
  AppearancePreferences load();
  Future<void> saveMode(AppearanceMode mode);
  Future<void> savePalette(AppPalette palette);
}

final appearancePreferencesStoreProvider = Provider<AppearancePreferencesStore>(
  (ref) => throw UnimplementedError('Override at bootstrap'),
);
