// `CupertinoPageTransitionsBuilder` moved out of material/ into cupertino/
// in Flutter 3.44 (framework PR flutter/flutter#179776). Import the cupertino
// library with `show` so we pick up just that one symbol and avoid pulling
// the full cupertino widget set into this material-themed file.
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../core/appearance_preferences.dart';

/// Trayzero palette. Warm, focused, energizing.
class AppColors {
  // Brand seed — a warm sunrise amber. This is the canonical brand colour,
  // but native surfaces can't read Dart constants, so when it changes the
  // following must be updated by hand to match (#D2601F):
  //   • android/app/src/main/res/drawable/widget_background.xml  (#D2601F)
  //   • ios/CleartrayInboxWidget/CleartrayInboxWidget.swift       (RGB form)
  //   • assets/icon/trayzero-source.svg + regenerate the 1024 PNG
  //   • pubspec.yaml flutter_launcher_icons.adaptive_icon_background
  //     (#C2531B, a deepened variant) then `dart run flutter_launcher_icons`
  static const Color seed = Color(trayzeroSeedArgb);
}

/// Semantic colours for the GTD workflow (buckets, the workflow diagram,
/// calendar accents). These are not derivable from the [ColorScheme], so they
/// ride along as a [ThemeExtension] with separate light and dark palettes.
///
/// Light values are the original, deliberately distinct from [AppColors.seed]
/// so the two warm tones don't collide in the workflow diagram. Dark values
/// are lightened/desaturated (~Material 300–400 tone) so they keep contrast
/// and their alpha washes stay visible on dark surfaces.
@immutable
class GtdColors extends ThemeExtension<GtdColors> {
  const GtdColors({
    required this.inbox,
    required this.nextAction,
    required this.project,
    required this.waiting,
    required this.someday,
    required this.reference,
    required this.calendar,
  });

  final Color inbox;
  final Color nextAction;
  final Color project;
  final Color waiting;
  final Color someday;
  final Color reference;
  final Color calendar;

  static const GtdColors light = GtdColors(
    inbox: Color(0xFFE64A19),
    nextAction: Color(0xFF2E7D32),
    project: Color(0xFF1565C0),
    waiting: Color(0xFF6A1B9A),
    someday: Color(0xFF455A64),
    reference: Color(0xFF00838F),
    calendar: Color(0xFFD81B60),
  );

  static const GtdColors dark = GtdColors(
    inbox: Color(0xFFFF7043),
    nextAction: Color(0xFF66BB6A),
    project: Color(0xFF64B5F6),
    waiting: Color(0xFFBA68C8),
    someday: Color(0xFF90A4AE),
    reference: Color(0xFF4DD0E1),
    calendar: Color(0xFFF06292),
  );

  @override
  GtdColors copyWith({
    Color? inbox,
    Color? nextAction,
    Color? project,
    Color? waiting,
    Color? someday,
    Color? reference,
    Color? calendar,
  }) {
    return GtdColors(
      inbox: inbox ?? this.inbox,
      nextAction: nextAction ?? this.nextAction,
      project: project ?? this.project,
      waiting: waiting ?? this.waiting,
      someday: someday ?? this.someday,
      reference: reference ?? this.reference,
      calendar: calendar ?? this.calendar,
    );
  }

  @override
  GtdColors lerp(ThemeExtension<GtdColors>? other, double t) {
    if (other is! GtdColors) return this;
    return GtdColors(
      inbox: Color.lerp(inbox, other.inbox, t)!,
      nextAction: Color.lerp(nextAction, other.nextAction, t)!,
      project: Color.lerp(project, other.project, t)!,
      waiting: Color.lerp(waiting, other.waiting, t)!,
      someday: Color.lerp(someday, other.someday, t)!,
      reference: Color.lerp(reference, other.reference, t)!,
      calendar: Color.lerp(calendar, other.calendar, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GtdColors &&
        other.inbox == inbox &&
        other.nextAction == nextAction &&
        other.project == project &&
        other.waiting == waiting &&
        other.someday == someday &&
        other.reference == reference &&
        other.calendar == calendar;
  }

  @override
  int get hashCode => Object.hash(
        inbox,
        nextAction,
        project,
        waiting,
        someday,
        reference,
        calendar,
      );
}

extension GtdColorsX on BuildContext {
  /// The [GtdColors] for the active theme. Always present — registered on
  /// both [AppTheme.light] and [AppTheme.dark].
  GtdColors get gtd => Theme.of(this).extension<GtdColors>()!;
}

extension SurfaceLegibleColor on Color {
  /// An arbitrary (often user-chosen) colour adjusted to stay legible when
  /// used as a *foreground or tint* on the active theme's surfaces.
  ///
  /// Light mode is returned unchanged (zero regression). In dark mode, dark
  /// colours are lightened so chip text and low-alpha washes don't vanish on
  /// dark cards. Do not use this for solid swatches where the true colour
  /// must be shown (e.g. a colour picker).
  Color onSurfaceOf(Brightness brightness) {
    if (brightness == Brightness.light) return this;
    final hsl = HSLColor.fromColor(this);
    if (hsl.lightness >= 0.6) return this;
    return hsl.withLightness(0.72).toColor();
  }
}

extension AppearanceModeTheme on AppearanceMode {
  ThemeMode get themeMode => switch (this) {
    AppearanceMode.system => ThemeMode.system,
    AppearanceMode.light => ThemeMode.light,
    AppearanceMode.dark => ThemeMode.dark,
  };
}

extension AppPaletteColor on AppPalette {
  Color get seed => Color(seedArgb);
}

/// Contrast against the actual rendered background, including alpha washes.
/// Keep the hue of semantic/user colors and change only lightness when needed.
extension ColorContrast on Color {
  double contrastAgainst(Color background) {
    final a = computeLuminance();
    final b = background.computeLuminance();
    return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
  }

  Color get contrastingForeground =>
      Colors.black.contrastAgainst(this) >= Colors.white.contrastAgainst(this)
      ? Colors.black
      : Colors.white;

  Color foregroundOn(Color background, {double minimumContrast = 4.5}) {
    if (contrastAgainst(background) >= minimumContrast) return this;
    final hsl = HSLColor.fromColor(this);
    final target = background.contrastingForeground == Colors.black ? 0.0 : 1.0;
    var insufficient = hsl.lightness;
    var sufficient = target;
    // Find the closest readable tone. The passing endpoint is returned to
    // avoid falling just below the threshold due to channel quantization.
    for (var i = 0; i < 16; i++) {
      final candidate = (insufficient + sufficient) / 2;
      if (hsl.withLightness(candidate).toColor().contrastAgainst(background) >=
          minimumContrast) {
        sufficient = candidate;
      } else {
        insufficient = candidate;
      }
    }
    return hsl.withLightness(sufficient).toColor();
  }
}

class AppTheme {
  static ThemeData light({AppPalette palette = AppPalette.amber}) =>
      _build(Brightness.light, palette);
  static ThemeData dark({AppPalette palette = AppPalette.amber}) =>
      _build(Brightness.dark, palette);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: brightness,
    );
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      }),
    );
    return base.copyWith(
      extensions: [
        brightness == Brightness.dark ? GtdColors.dark : GtdColors.light,
      ],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          );
        }),
        height: 64,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        space: 1,
        thickness: 0.5,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
