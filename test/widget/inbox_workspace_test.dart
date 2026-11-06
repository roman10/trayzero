import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _FailingItems extends ItemRepository {
  _FailingItems(super.db, super.clock);

  bool fail = false;

  @override
  Future<void> upsert(Item item) {
    if (fail) throw StateError('disk full');
    return super.upsert(item);
  }
}

void main() {
  testWidgets('Inbox workspace preserves selection, scroll, and drafts', (
    tester,
  ) async {
    final env = await TestEnv.create(
      prefsValues: {'onboarding_complete_v1': true},
    );
    addTearDown(env.dispose);
    final items = _FailingItems(env.db, env.clock);
    final container = env.container([
      itemRepositoryProvider.overrideWithValue(items),
    ]);
    for (var i = 0; i < 35; i++) {
      await items.upsert(
        anItem(
          id: 'item-$i',
          title: 'Inbox item $i',
          createdAt: env.clock.now().subtract(Duration(minutes: i)),
        ),
      );
    }

    const compact = Size(375, 800);
    const tablet = Size(1376, 1032);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = compact;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: container.read(routerProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder card(String title) => find.widgetWithText(ItemCard, title);
    Finder field(String title) => find.widgetWithText(TextField, title);

    await tester.tap(card('Inbox item 0'));
    await tester.pumpAndSettle();
    expect(field('Inbox item 0'), findsOneWidget);
    expect(find.byType(InboxScreen), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(card('Inbox item 0'), findsOneWidget);

    tester.view.physicalSize = tablet;
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    scroll.jumpTo(1200);
    await tester.pumpAndSettle();
    final firstVisible = tester
        .widgetList<ItemCard>(find.byType(ItemCard).hitTestable())
        .first
        .item;
    await tester.tap(card(firstVisible.title).hitTestable());
    await tester.pumpAndSettle();

    final editor = tester.state(find.byType(ItemEditScreen));
    expect(
      tester.widget<ItemCard>(card(firstVisible.title)).highlighted,
      isTrue,
    );
    expect(card('Inbox item 0'), findsNothing);
    expect(find.text('Process Inbox'), findsNothing);
    expect(
      tester.widget<ItemCard>(card(firstVisible.title)).onComplete,
      isNull,
    );

    await tester.enterText(field(firstVisible.title), 'Unsaved title');
    final titleField = tester.widget<TextField>(field('Unsaved title'));
    titleField.controller!.selection = const TextSelection.collapsed(offset: 3);
    for (final (size, wide) in [
      (const Size(669, 951), true),
      (compact, false),
      (const Size(951, 669), true),
      (tablet, true),
    ]) {
      tester.view.physicalSize = size;
      // Relayout without allowing the editor's debounce to save the draft.
      await tester.pump();
      expect(tester.state(find.byType(ItemEditScreen)), same(editor));
      expect(titleField.focusNode!.hasFocus, isTrue);
      expect(titleField.controller!.selection.baseOffset, 3);
      expect(find.byType(InboxScreen), wide ? findsOneWidget : findsNothing);
      expect(find.byType(NavigationRail), wide ? findsOneWidget : findsNothing);
    }
    expect((await items.getById(firstVisible.id))!.title, firstVisible.title);

    final next = tester
        .widgetList<ItemCard>(find.byType(ItemCard).hitTestable())
        .firstWhere((card) => card.item.id != firstVisible.id)
        .item;
    items.fail = true;
    await tester.tap(card(next.title).hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.state(find.byType(ItemEditScreen)), same(editor));
    expect(field('Unsaved title'), findsOneWidget);
    expect(
      find.text("Couldn't save your changes. Please try again."),
      findsOneWidget,
    );

    items.fail = false;
    await tester.tap(card(next.title).hitTestable());
    await tester.pumpAndSettle();
    expect((await items.getById(firstVisible.id))!.title, 'Unsaved title');
    expect(field(next.title), findsOneWidget);
    expect(tester.widget<ItemCard>(card(next.title)).highlighted, isTrue);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ItemEditScreen), findsNothing);
    expect(scroll.offset, 1200);
    expect(tester.takeException(), isNull);
  });
}
