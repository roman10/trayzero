import 'package:cleartray/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dark mode is "proper" only if the GTD semantic colours adapt to
/// brightness. They can't come from the [ColorScheme], so they ride along as
/// a [GtdColors] [ThemeExtension] registered on both themes.
void main() {
  group('GtdColors theme extension', () {
    test('is registered on both light and dark themes', () {
      expect(AppTheme.light().extension<GtdColors>(), isNotNull);
      expect(AppTheme.dark().extension<GtdColors>(), isNotNull);
    });

    test('light keeps the original palette, dark diverges', () {
      final light = AppTheme.light().extension<GtdColors>()!;
      final dark = AppTheme.dark().extension<GtdColors>()!;

      // Light is unchanged from the historical constants.
      expect(light.calendar, const Color(0xFFD81B60));
      expect(light.someday, const Color(0xFF455A64));

      // Every semantic colour is retuned for dark — none reused verbatim.
      expect(dark.inbox, isNot(light.inbox));
      expect(dark.nextAction, isNot(light.nextAction));
      expect(dark.project, isNot(light.project));
      expect(dark.waiting, isNot(light.waiting));
      expect(dark.someday, isNot(light.someday));
      expect(dark.reference, isNot(light.reference));
      expect(dark.calendar, isNot(light.calendar));
    });

    test('dark colours clear ~3:1 contrast against the dark surface', () {
      final dark = AppTheme.dark().extension<GtdColors>()!;
      final surface = AppTheme.dark().colorScheme.surface;

      double contrast(Color a, Color b) {
        final la = a.computeLuminance();
        final lb = b.computeLuminance();
        final hi = la > lb ? la : lb;
        final lo = la > lb ? lb : la;
        return (hi + 0.05) / (lo + 0.05);
      }

      for (final c in [
        dark.inbox,
        dark.nextAction,
        dark.project,
        dark.waiting,
        dark.someday,
        dark.reference,
        dark.calendar,
      ]) {
        expect(contrast(c, surface), greaterThan(3.0),
            reason: '$c must read on the dark surface');
      }
    });

    test('value equality holds for copyWith-derived instances', () {
      const a = GtdColors.light;
      expect(a.copyWith(), a);
      expect(a.copyWith().hashCode, a.hashCode);
      expect(a.copyWith(inbox: const Color(0xFF000000)), isNot(a));
      expect(GtdColors.light == GtdColors.dark, isFalse);
    });

    test('lerp returns the endpoints at t=0 and t=1', () {
      const a = GtdColors.light;
      const b = GtdColors.dark;
      expect(a.lerp(b, 0).calendar, a.calendar);
      expect(a.lerp(b, 1).calendar, b.calendar);
    });
  });

  group('SurfaceLegibleColor.onSurfaceOf', () {
    test('light mode is byte-identical (zero regression)', () {
      for (final hex in [0xFF6D4C41, 0xFF1E88E5, 0xFFFFFFFF, 0xFF000000]) {
        final c = Color(hex);
        expect(c.onSurfaceOf(Brightness.light), c);
      }
    });

    test('dark mode lightens dark colours so they read on dark surfaces', () {
      const brown = Color(0xFF6D4C41); // a low-lightness context colour
      final out = brown.onSurfaceOf(Brightness.dark);
      expect(out, isNot(brown));
      expect(HSLColor.fromColor(out).lightness, greaterThan(0.6));
      // Hue is preserved — it's still recognisably the same colour.
      expect(
        HSLColor.fromColor(out).hue,
        closeTo(HSLColor.fromColor(brown).hue, 0.5),
      );
    });

    test('dark mode leaves already-light colours untouched', () {
      const pale = Color(0xFFFFE082); // lightness well above the threshold
      expect(pale.onSurfaceOf(Brightness.dark), pale);
    });
  });

  group('filled-chip foreground rule', () {
    test('chooses readable content for deep, pale and middle-tone fills', () {
      for (final fill in [
        const Color(0xFF1565C0),
        const Color(0xFFFFE082),
        // A brightness heuristic chooses white here, below 4.5:1 for text.
        const Color(0xFFE64A19),
      ]) {
        expect(fill.contrastingForeground.contrastAgainst(fill),
            greaterThanOrEqualTo(4.5));
      }
      expect(const Color(0xFFE64A19).contrastingForeground, Colors.black);
    });
  });
}
