import 'dart:async';

import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/features/capture/capture_sheet.dart';
import 'package:cleartray/features/common/keyboard_shortcut_actions.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/harness.dart';

Future<void> pressCommand(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
}

void main() {
  const ios = TargetPlatformVariant({TargetPlatform.iOS});

  Future<ProviderContainer> boot(WidgetTester tester) async {
    ReceiveSharingIntent.setMockValues(
      initialMedia: [],
      mediaStream: const Stream.empty(),
    );
    final env = await TestEnv.create(
      prefsValues: {'onboarding_complete_v1': true},
    );
    addTearDown(env.dispose);
    final container = env.container();
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TrayzeroApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('Search and Capture work on phone, Duo, and iPad widths', (
    tester,
  ) async {
    final container = await boot(tester);
    final router = container.read(routerProvider);
    for (final size in const [
      Size(390, 844),
      Size(669, 951),
      Size(1376, 1032),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpAndSettle();
      await pressCommand(tester, LogicalKeyboardKey.keyF);
      // A second press before the first frame must not stack Search.
      await pressCommand(tester, LogicalKeyboardKey.keyF);
      await tester.pumpAndSettle();
      final search = find.byType(SearchScreen);
      expect(search, findsOneWidget, reason: 'viewport $size');
      final query = find.descendant(
        of: search,
        matching: find.byType(TextField),
      );
      await tester.enterText(query, 'Follow up');
      final focus = tester.widget<TextField>(query).focusNode!;
      focus.unfocus();
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      await pressCommand(tester, LogicalKeyboardKey.keyF);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(find.text('Follow up'), findsOneWidget);

      await pressCommand(tester, LogicalKeyboardKey.keyN);
      await tester.pumpAndSettle();
      final capture = find.byType(CaptureSheet);
      expect(capture, findsOneWidget, reason: 'viewport $size');
      final title = find
          .descendant(of: capture, matching: find.byType(TextField))
          .first;
      expect(tester.widget<TextField>(title).focusNode!.hasFocus, isTrue);
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(capture, findsNothing);
      expect(find.text('Follow up'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(search, findsNothing);
      expect(find.byType(InboxScreen), findsOneWidget);
    }
    await tester.pump(const Duration(milliseconds: 1));
  }, variant: ios);

  testWidgets('shortcut hints fit roomy Inbox and Do actions', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = await boot(tester);
    final router = container.read(routerProvider);
    for (final tab in ['/inbox', '/do']) {
      router.go(tab);
      await tester.pumpAndSettle();
      final search = find.byType(SearchShortcutButton);
      final capture = find.byType(CaptureShortcutButton);
      final fab = find.byType(FloatingActionButton);
      Size? compactDoFabSize;
      for (final (size, showHints) in const [
        (Size(390, 844), false),
        (Size(844, 390), false),
        (Size(466, 678), false),
        (Size(669, 951), true),
        (Size(951, 669), true),
        (Size(1376, 1032), true),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(search.hitTestable(), findsOneWidget);
        expect(capture.hitTestable(), findsOneWidget);
        for (final (action, label, chord) in [
          (search, 'Search', '⌘F'),
          (capture, 'Capture', '⌘N'),
        ]) {
          expect(
            find.descendant(of: action, matching: find.text(chord)),
            showHints ? findsOneWidget : findsNothing,
            reason: '$tab at $size',
          );
          expect(find.bySemanticsLabel(chord), findsNothing);
          final node = tester.getSemantics(action);
          final data = node.getSemanticsData();
          expect(data.hint, showHints ? chord : '');
          expect([data.label, data.tooltip], contains(label));
          if (showHints) {
            expect(
              data.hasAction(SemanticsAction.tap),
              isTrue,
              reason: '$tab $size $chord ${node.toStringDeep()}',
            );
          }
        }
        if (tab == '/do') {
          final fabSize = tester.getSize(fab);
          compactDoFabSize ??= fabSize;
          expect(fabSize, compactDoFabSize);
        }
        expect(tester.takeException(), isNull);
      }
    }
    semantics.dispose();
    await tester.pump(const Duration(milliseconds: 1));
  }, variant: ios);

  testWidgets('open capture keeps its draft and blocks other app shortcuts', (
    tester,
  ) async {
    await boot(tester);
    await pressCommand(tester, LogicalKeyboardKey.keyN);
    await pressCommand(tester, LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    final capture = find.byType(CaptureSheet);
    expect(capture, findsOneWidget);
    final title = find
        .descendant(of: capture, matching: find.byType(TextField))
        .first;
    await tester.enterText(title, 'An unsaved idea');
    await pressCommand(tester, LogicalKeyboardKey.keyF);
    await pressCommand(tester, LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsNothing);
    expect(capture, findsOneWidget);
    expect(tester.widget<TextField>(title).controller!.text, 'An unsaved idea');

    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect(capture, findsNothing);
    expect(find.text('An unsaved idea'), findsOneWidget);
  }, variant: ios);

  testWidgets('search opens above a draft editor and returns to it', (
    tester,
  ) async {
    final container = await boot(tester);
    final repo = container.read(itemRepositoryProvider);
    await repo.upsert(anItem(id: 'draft', title: 'Original title'));
    final router = container.read(routerProvider);
    unawaited(router.push('/item/draft'));
    await tester.pumpAndSettle();
    final editor = find.byType(ItemEditScreen);
    final title = find
        .descendant(of: editor, matching: find.byType(TextField))
        .first;
    final state = tester.state(editor);
    await tester.enterText(title, 'Edited title');
    await pressCommand(tester, LogicalKeyboardKey.keyF);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(tester.state(editor), same(state));
    expect(tester.widget<TextField>(title).controller!.text, 'Edited title');
    await tester.pump(const Duration(seconds: 2));
  }, variant: ios);
}
