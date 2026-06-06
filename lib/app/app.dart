import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/capture/share_intent_listener.dart';
import '../features/common/notification_permission_refresher.dart';
import '../features/settings/settings_controller.dart';
import '../l10n/gen/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class TrayzeroApp extends ConsumerWidget {
  const TrayzeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Clamp text scale to keep layouts intact while still respecting user
        // preference up to a reasonable maximum.
        final clamped =
            media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.6);
        return MediaQuery(
          data: media.copyWith(textScaler: clamped),
          child: NotificationPermissionRefresher(
            child:
                ShareIntentListener(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
