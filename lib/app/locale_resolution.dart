import 'package:flutter/widgets.dart';

import '../l10n/gen/app_localizations.dart';

/// Resolves the app locale from the device's preferred locales.
///
/// Mirrors Flutter's own [basicLocaleListResolution] (so script/region
/// inference such as zh-Hant is preserved) but overrides its default
/// "no match falls back to the first supported locale" behaviour — the first
/// supported locale is German, so an unmatched device would otherwise open in
/// German. We fall back to English instead.
///
/// Shared by [MaterialApp]'s localeListResolutionCallback and the first-run
/// seeding in main(), so seeded content lands in the same language the UI
/// renders in.
Locale resolveAppLocale(List<Locale> deviceLocales) {
  final hasMatch = deviceLocales.any((device) => AppLocalizations
      .supportedLocales
      .any((supported) => supported.languageCode == device.languageCode));
  if (!hasMatch) return const Locale('en');
  return basicLocaleListResolution(
      deviceLocales, AppLocalizations.supportedLocales);
}

/// Serialises a supported [Locale] to a SharedPreferences tag: `languageCode`
/// or `languageCode-scriptCode` (e.g. `zh-Hant`). Region is dropped — the app
/// only differentiates by language + script.
String localeToTag(Locale locale) => locale.scriptCode == null
    ? locale.languageCode
    : '${locale.languageCode}-${locale.scriptCode}';

/// Parses a stored tag back to one of [AppLocalizations.supportedLocales], or
/// null when the tag is empty/unknown (meaning: follow the system). Matching a
/// stored value against the canonical list keeps a single source of truth and
/// drops silently-unsupported tags left over from an older build.
Locale? localeFromTag(String? tag) {
  if (tag == null || tag.isEmpty) return null;
  final parts = tag.split('-');
  final languageCode = parts.first;
  final scriptCode = parts.length > 1 ? parts[1] : null;
  for (final supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == languageCode &&
        supported.scriptCode == scriptCode) {
      return supported;
    }
  }
  return null;
}
