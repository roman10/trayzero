import 'package:cleartray/features/settings/feedback_links.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> boot(WidgetTester tester, Future<bool> Function(Uri) launch) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [externalLinkLauncherProvider.overrideWithValue(launch)],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: FeedbackSettingsRows()),
          ),
        ),
      );

  testWidgets(
    'rating opens the store; feedback composes email without sending',
    (tester) async {
      final urls = <Uri>[];
      await boot(tester, (url) async {
        urls.add(url);
        return true;
      });
      await tester.tap(find.text('Rate Trayzero'));
      await tester.pump();
      expect(urls.single, trayzeroRatingUrl(TargetPlatform.android));
      await tester.tap(find.text('Send feedback'));
      await tester.pump();
      expect(urls.last.scheme, 'mailto');
      expect(urls.last.path, 'support@trayzero.app');
      expect(urls.last.queryParameters['subject'], 'Trayzero feedback');
      expect(
        trayzeroRatingUrl(TargetPlatform.iOS).queryParameters['action'],
        'write-review',
      );
      expect(trayzeroRatingUrl(TargetPlatform.iOS).path, '/app/id6771756447');
    },
  );

  testWidgets('missing email app leaves a selectable support address', (
    tester,
  ) async {
    await boot(tester, (_) async => false);
    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(SelectableText, 'support@trayzero.app'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rate Trayzero'));
    await tester.pump();
    expect(find.text("Couldn't open link"), findsOneWidget);
  });

  testWidgets('launcher exceptions use the same feedback fallback', (
    tester,
  ) async {
    await boot(tester, (_) async => throw StateError('unavailable'));
    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('support@trayzero.app'), findsOneWidget);
  });
}
