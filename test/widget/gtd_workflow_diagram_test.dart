import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/features/common/gtd_workflow_diagram.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('renders all five GTD stages, decision tree and footnote',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: GtdWorkflowDiagram()),
        ),
      ),
    );

    expect(find.text('1. Capture'), findsOneWidget);
    expect(find.text('2. Clarify'), findsOneWidget);
    expect(find.text('3. Organize'), findsOneWidget);
    expect(find.text('4. Reflect'), findsOneWidget);
    expect(find.text('5. Engage'), findsOneWidget);

    // Decision-tree branch is rendered via RichText spans.
    expect(
      find.textContaining('Takes under 2 minutes?', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('live under Review'), findsOneWidget);
  });

  testWidgets('highlight marks only the matching stage', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: GtdWorkflowDiagram(highlight: GtdStage.capture),
          ),
        ),
      ),
    );

    expect(find.text("You're here"), findsOneWidget);
  });

  testWidgets('tapping a navigable pill dismisses the sheet and navigates',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showGtdWorkflowSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/projects',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('PROJECTS SCREEN'))),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('How GTD works'), findsOneWidget);

    // The pill is below the fold — scroll it into view, then tap.
    await tester.ensureVisible(find.text('Projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    // Sheet is gone and we navigated.
    expect(find.text('How GTD works'), findsNothing);
    expect(find.text('PROJECTS SCREEN'), findsOneWidget);
  });

  testWidgets('non-navigable bucket pills are not tappable links',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: GtdWorkflowDiagram()),
        ),
      ),
    );

    // "Waiting for" is a label-only bucket: present, but no InkWell ancestor.
    final waiting = find.text('Waiting for');
    expect(waiting, findsOneWidget);
    expect(
      find.ancestor(of: waiting, matching: find.byType(InkWell)),
      findsNothing,
    );
  });
}
