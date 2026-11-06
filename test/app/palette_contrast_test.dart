import 'package:cleartray/app/theme.dart';
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default themes retain the original seeded schemes', () {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.dark
          ? AppTheme.dark()
          : AppTheme.light();
      expect(
        theme.colorScheme,
        ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: brightness),
      );
    }
  });

  for (final palette in AppPalette.values) {
    for (final brightness in Brightness.values) {
      test(
        '${palette.id} ${brightness.name}: role pairs and custom washes are readable',
        () {
          final theme = brightness == Brightness.dark
              ? AppTheme.dark(palette: palette)
              : AppTheme.light(palette: palette);
          final scheme = theme.colorScheme;
          final gtd = theme.extension<GtdColors>()!;
          expect(
            gtd,
            brightness == Brightness.dark ? GtdColors.dark : GtdColors.light,
          );
          for (final (foreground, background) in [
            (scheme.onPrimary, scheme.primary),
            (scheme.onPrimaryContainer, scheme.primaryContainer),
            (scheme.onSurface, scheme.surfaceContainerLow),
            (scheme.onSurfaceVariant, scheme.surface),
            (scheme.onError, scheme.error),
          ]) {
            expect(
              foreground.contrastAgainst(background),
              greaterThanOrEqualTo(4.5),
            );
          }
          for (final color in [
            scheme.primary, scheme.secondary, scheme.tertiary, scheme.error,
            gtd.inbox, gtd.nextAction, gtd.project, gtd.waiting,
            gtd.someday, gtd.reference, gtd.calendar,
            const Color(0xFFFFE082), // pale user-chosen context
            const Color(0xFF6D4C41), // dark user-chosen context
          ]) {
            for (final backdrop in [
              scheme.surfaceContainerLow,
              scheme.surfaceContainerHigh,
              scheme.primaryContainer,
            ]) {
              for (final alpha in [0.12, 0.14, 0.15]) {
                final background = Color.alphaBlend(
                  color.withValues(alpha: alpha),
                  backdrop,
                );
                final foreground = color.foregroundOn(background);
                expect(
                  foreground.contrastAgainst(background),
                  greaterThanOrEqualTo(4.5),
                  reason: '$color on $background',
                );
              }
            }
            expect(
              color.contrastingForeground.contrastAgainst(color),
              greaterThanOrEqualTo(4.5),
            );
          }
        },
      );
    }
  }

  test('contrast correction retains an already-readable color', () {
    expect(Colors.black.foregroundOn(Colors.white), Colors.black);
    expect(Colors.white.foregroundOn(Colors.black), Colors.white);
  });

  test(
    'contrast correction preserves hue and selects the closest readable tone',
    () {
      const original = Color(0xFF6D4C41);
      final corrected = original.foregroundOn(const Color(0xFF222222));
      expect(
        corrected.contrastAgainst(const Color(0xFF222222)),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        HSLColor.fromColor(corrected).hue,
        closeTo(HSLColor.fromColor(original).hue, 1),
      );
    },
  );
}
