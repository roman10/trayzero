import 'package:cleartray/app/theme.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/features/app_import/app_import_screen.dart';
import 'package:cleartray/features/app_import/app_import_source_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'harness.dart';

/// Pumps the two-page import flow (list → source page) in a router that
/// mirrors the production routes, so row taps and "Done" navigate for real.
/// `/settings` and `/settings/backup` are stubs showing their name.
Future<void> pumpImportFlow(
  WidgetTester tester, {
  required TestEnv env,
  List<Override> extraOverrides = const [],
  TextScaler? textScaler,
  String location = '/settings/import',
}) async {
  final container = ProviderContainer(overrides: env.overrides(extraOverrides));
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/settings', builder: (_, _) => const _Stub('settings')),
      GoRoute(
        path: '/settings/backup',
        builder: (_, _) => const _Stub('backup'),
      ),
      GoRoute(
        path: '/settings/import',
        builder: (_, _) => const AppImportScreen(),
      ),
      GoRoute(
        path: '/settings/import/:source',
        builder: (_, state) => AppImportSourceScreen(
          source: ImportSourceApp.values.byName(
            state.pathParameters['source']!,
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: textScaler == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The provider container behind [pumpImportFlow].
ProviderContainer importContainer(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

/// Scrolls the source list to the row named [name] and opens its page.
Future<void> openSource(WidgetTester tester, String name) async {
  final row = find.text(name);
  await tester.scrollUntilVisible(
    row,
    100,
    // At large text sizes the list is long.
    maxScrolls: 100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

class _Stub extends StatelessWidget {
  const _Stub(this.name);
  final String name;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text('stub:$name')));
}
