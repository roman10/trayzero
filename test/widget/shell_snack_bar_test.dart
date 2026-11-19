import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/capture/capture_sheet.dart';
import 'package:cleartray/features/common/delete_with_undo.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/shell/app_shell.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _DeleteHost extends ConsumerWidget {
  const _DeleteHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () => deleteWithUndo(context, ref, 'a'),
        child: const Text('Delete'),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => showCaptureSheet(context),
      child: const Icon(Icons.add),
    ),
  );
}

void main() {
  late TestEnv env;
  late ItemRepository items;
  setUp(() async {
    env = await TestEnv.create();
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  for (final (locale, scale) in [
    (const Locale('en'), 2.0),
    (const Locale('de'), 1.5),
  ]) {
    testWidgets('Undo and Close remain usable with $locale at ${scale}x text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await items.upsert(anItem(id: 'a'));
      await pumpApp(
        tester,
        const AppShell(location: '/inbox', child: _DeleteHost()),
        env: env,
        locale: locale,
        textScaler: TextScaler.linear(scale),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(SnackBar));
      final undo = find.text(AppLocalizations.of(context).undo);
      final close = find.byTooltip(
        MaterialLocalizations.of(context).closeButtonTooltip,
      );
      expect(tester.getRect(undo).overlaps(tester.getRect(close)), isFalse);
      expect(
        tester.getRect(find.byType(SnackBar)).bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byType(FloatingActionButton)).top,
        ),
      );
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(await items.getById('a'), isNull);
    });
  }

  for (final size in [const Size(375, 667), const Size(1024, 900)]) {
    testWidgets('deletion toast clears stationary Capture at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await items.upsert(anItem(id: 'a'));
      await pumpApp(
        tester,
        const AppShell(location: '/inbox', child: _DeleteHost()),
        env: env,
      );
      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      final original = tester.getRect(fab);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(tester.getRect(fab), original);
      expect(
        tester.getRect(find.byType(SnackBar)).bottom,
        lessThanOrEqualTo(original.top),
      );
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.byType(CaptureSheet), findsOneWidget);
      // Opening Capture must not prematurely close the deletion Undo window.
      expect(await items.getById('a'), isNotNull);
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect((await items.getById('a'))!.status, ItemStatus.inbox);
    });
  }

  testWidgets('Inbox completion toast leaves Capture immediately tappable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await items.upsert(anItem(id: 'a', title: 'Call the bank'));
    await pumpApp(
      tester,
      const AppShell(location: '/inbox', child: InboxScreen()),
      env: env,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Mark Call the bank done'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(CaptureSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.status, ItemStatus.inbox);
  });
}
