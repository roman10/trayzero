import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/appearance_controller.dart';
import '../features/capture/share_intent_listener.dart';
import '../features/common/notification_permission_refresher.dart';
import '../features/common/time_sensitive_items_refresher.dart';
import '../features/settings/settings_controller.dart';
import '../l10n/gen/app_localizations.dart';
import 'app_keyboard_shortcuts.dart';
import 'locale_resolution.dart';
import 'router.dart';
import 'theme.dart';

class TrayzeroApp extends ConsumerWidget {
  const TrayzeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appearance = ref.watch(appearanceProvider);
    final localeOverride = ref.watch(localeOverrideProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      themeMode: appearance.mode.themeMode,
      theme: AppTheme.light(palette: appearance.palette),
      darkTheme: AppTheme.dark(palette: appearance.palette),
      routerConfig: router,
      // Non-null forces that language; null falls through to the device-locale
      // resolution in localeListResolutionCallback below.
      locale: localeOverride,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (deviceLocales, supportedLocales) =>
          resolveAppLocale(deviceLocales ?? const <Locale>[]),
      builder: (context, child) {
        return TimeSensitiveItemsRefresher(
          child: NotificationPermissionRefresher(
            child: ShareIntentListener(
              child: AppKeyboardShortcuts(
                router: router,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
