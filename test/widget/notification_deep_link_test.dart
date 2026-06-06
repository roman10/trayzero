import 'package:cleartray/app/router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Reproduces the on-device black screen: a notification tap / home-screen
/// widget opens a detail route via `.go()` from a *terminated* app, so the
/// route has nothing behind it. When the user then leaves that screen —
/// marking the item complete, popping back, or closing the capture sheet —
/// the navigator empties and the screen goes black.
///
/// [openDeepLink] is exactly what `main.dart` funnels every external deep
/// link through, so driving it here exercises the real fix end to end:
/// `find.byType(AppShell)` after the screen is left proves the pop landed
/// on a real tab, not an empty navigator. On the pre-fix `.go()` path the
/// shell is never built, so every one of these assertions fails.
void main() {
  late TestEnv env;
  late ItemRepository items;

  // The capture sheet boots speech_to_text in initState; its plugin has no
  // implementation under flutter_test, so pin the channel to "unavailable"
  // instead of letting a MissingPluginException surface mid-pump.
  const speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      speechChannel,
      (call) async => call.method == 'initialize' ? false : null,
    );
    env = await TestEnv.create(
      now: DateTime(2026, 5, 14, 9),
      prefsValues: {'onboarding_complete_v1': true},
    );
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, null);
    return env.dispose();
  });

  Future<void> bootFromColdNotification(
    WidgetTester tester,
    String location,
  ) async {
    final container = ProviderContainer(overrides: env.overrides());
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();

    // The terminated-app launch replay (main.dart) routes through this.
    openDeepLink(router, location);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'completing an item opened from a cold-launch notification returns '
      'to the Inbox, not a black screen', (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Pay rent',
      status: ItemStatus.inbox,
      dueAt: DateTime(2026, 5, 20, 9),
    ));

    await bootFromColdNotification(tester, '/item/a');

    // The detail screen is up, with the Inbox tab anchored beneath it.
    // The anchored shell sits behind an opaque fullscreen route, so it is
    // offstage here — skipOffstage:false asserts the anchor exists, not that
    // it is currently painted (it is back onstage once the screen is left).
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byType(AppShell, skipOffstage: false), findsOneWidget,
        reason: 'a shell tab must be anchored beneath the detail route');

    await tester.scrollUntilVisible(find.text('Mark complete'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();

    final saved = await items.getById('a');
    expect(saved!.status, ItemStatus.done);
    expect(find.text('Edit'), findsNothing,
        reason: 'the detail screen must be left after completing');
    expect(find.byType(AppShell), findsOneWidget,
        reason: 'completing must land on a real tab, not a black screen');
  });

  testWidgets(
      'the plain back gesture from a cold-launch notification item does '
      'not black-screen', (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Pay rent'));

    await bootFromColdNotification(tester, '/item/a');
    expect(find.text('Edit'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsNothing);
    expect(find.byType(AppShell), findsOneWidget,
        reason: 'back from a deep-linked item must reveal a real tab');
  });

  testWidgets(
      'closing the capture sheet opened from a home-widget tap returns to '
      'the Inbox, not a black screen', (tester) async {
    // main.dart maps a `cleartray://capture` widget tap to this.
    await bootFromColdNotification(tester, '/capture');

    expect(find.text('Brain dump'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Brain dump'), findsNothing);
    expect(find.byType(AppShell), findsOneWidget,
        reason: 'dismissing capture must land on a real tab, not black');
  });
}
