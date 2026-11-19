import 'package:cleartray/app/locale_resolution.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppLocale', () {
    test('falls back to English when Polish is the only preference', () {
      expect(resolveAppLocale(const [Locale('pl')]), const Locale('en'));
    });

    test('selects German when the preferred Polish locale is unsupported', () {
      expect(
        resolveAppLocale(const [Locale('pl'), Locale('de')]),
        const Locale('de'),
      );
    });
  });
}
