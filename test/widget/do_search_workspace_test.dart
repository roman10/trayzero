import 'dart:async';

import 'package:cleartray/app/router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:cleartray/features/common/workspace_scroll_controller.dart';
import 'package:cleartray/features/engage/engage_controller.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:cleartray/features/engage/today_controller.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/search/search_controller.dart';
import 'package:cleartray/features/search/search_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _FailingItems extends ItemRepository {
  _FailingItems(super.db, super.clock);
  bool fail = true;
  @override
  Future<void> upsert(Item item) {
    if (fail) throw StateError('disk full');
    return super.upsert(item);
  }
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late TestEnv env;
  late ItemRepository items;
  setUp(() async {
    env = await TestEnv.create(prefsValues: {'onboarding_complete_v1': true});
    items = ItemRepository(env.db, env.clock);
    for (final id in ['alpha', 'beta']) {
      await items.upsert(
        anItem(
          id: id,
          title: 'Task $id',
          status: ItemStatus.nextAction,
        ).copyWith(energy: Energy.low, timeEstimateMinutes: 5),
      );
      await items.setFocusedAt({id: env.clock.now()});
    }
    await items.upsert(
      anItem(
        id: 'other',
        title: 'Other entry',
        status: ItemStatus.nextAction,
      ).copyWith(energy: Energy.high),
    );
  });
  tearDown(() => env.dispose());

  Future<ProviderContainer> openApp(
    WidgetTester tester,
    String source, {
    List<Override> overrides = const [],
    bool today = false,
  }) async {
    final container = env.container(overrides);
    if (today) await container.read(doViewProvider.notifier).set(DoView.today);
    container.read(engageFilterProvider.notifier).setEnergy(Energy.low);
    container
        .read(searchFilterProvider.notifier)
        .toggleStatus(ItemStatus.nextAction);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: container.read(routerProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    final router = container.read(routerProvider);
    router.go('/do');
    await settle(tester);
    if (source == 'search') {
      unawaited(router.push('/search'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Task');
      await settle(tester);
    }
    return container;
  }

  testWidgets('Time and Energy stays visible alongside scrolling contexts', (
    tester,
  ) async {
    final contexts = ContextRepository(env.db);
    for (var i = 0; i < 12; i++) {
      await contexts.upsert(
        GtdContext(
          id: 'context-$i',
          name: 'Sample context $i',
          icon: 'home',
          color: 0xFF1E88E5,
        ),
      );
    }
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(669, 951);
    addTearDown(tester.view.reset);
    final container = await openApp(tester, 'do');

    final timeEnergy = find.byKey(const Key('engage-filter-time-energy'));
    final contextScroll = find.ancestor(
      of: find.text('Sample context 0'),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(contextScroll).position;
    for (final size in [
      const Size(669, 951),
      const Size(951, 669),
      const Size(1032, 1376),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(timeEnergy.hitTestable(), findsOneWidget);
      final chipRect = tester.getRect(timeEnergy);
      expect(position.maxScrollExtent, greaterThan(0));
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.getRect(timeEnergy), chipRect);
    }

    await tester.tap(timeEnergy);
    await tester.pumpAndSettle();
    await tester.tap(find.text('< 5m'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.viewInsets = const FakeViewPadding(bottom: 315);
    await tester.pumpAndSettle();
    expect(container.read(engageFilterProvider).maxTimeMinutes, 5);
    position.jumpTo(0);
    await tester.pumpAndSettle();
    expect(timeEnergy.hitTestable(), findsNothing);
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(timeEnergy.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Do workspace keeps a usable list above the software keyboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1133, 744);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 20);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
    addTearDown(tester.view.reset);
    await openApp(tester, 'do');
    await tester.tap(find.widgetWithText(ItemCard, 'Task alpha'));
    await settle(tester);

    final editor = tester.state(find.byType(ItemEditScreen));
    final title = find.widgetWithText(TextField, 'Task alpha');
    final field = tester.widget<TextField>(title);
    await tester.enterText(title, 'Task draft');
    const selection = TextSelection.collapsed(offset: 4);
    field.controller!.selection = selection;

    tester.view.padding = const FakeViewPadding(top: 24);
    tester.view.viewInsets = const FakeViewPadding(bottom: 315);
    await tester.pump();
    expect(
      find.widgetWithText(ItemCard, 'Task beta').hitTestable(),
      findsOneWidget,
    );
    final rail = find.byType(NavigationRail);
    expect(
      find.descendant(of: rail, matching: find.text('Projects')).hitTestable(),
      findsOneWidget,
    );

    // Preserve the list on both Duo orientations. The same inset leaves
    // enough room for both scrollable panes.
    final list = find.byType(EngageScreen);
    for (final size in [const Size(669, 951), const Size(951, 669)]) {
      tester.view.physicalSize = size;
      await tester.pump();
      expect(list, findsOneWidget);
      expect(rail, size.width == 669 ? findsNothing : findsOneWidget);
    }

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(list, findsNothing);
    tester.view.physicalSize = const Size(1133, 744);
    tester.view.viewInsets = const FakeViewPadding(bottom: 470);
    await tester.pump();
    expect(list, findsNothing);
    tester.view.resetViewInsets();
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
    await tester.pump();
    expect(list, findsOneWidget);
    expect(tester.state(find.byType(ItemEditScreen)), same(editor));
    expect(field.controller!.text, 'Task draft');
    expect(field.controller!.selection, selection);
    expect(field.focusNode!.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final source in ['do', 'search']) {
    testWidgets(
      '$source preserves dirty editor, focus and filters across layout changes and selection',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1000, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final container = await openApp(tester, source);
        await tester.tap(find.widgetWithText(ItemCard, 'Task alpha'));
        await settle(tester);
        final state = tester.state(find.byType(ItemEditScreen));
        expect(find.widgetWithText(ItemCard, 'Task beta'), findsOneWidget);
        expect(
          tester
              .widget<ItemCard>(find.widgetWithText(ItemCard, 'Task alpha'))
              .highlighted,
          isTrue,
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Task alpha'),
          'Task edited',
        );
        final field = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Task edited'),
        );
        field.controller!.selection = const TextSelection.collapsed(offset: 3);
        final focus = field.focusNode!;
        for (final size in [
          const Size(375, 800),
          const Size(800, 375),
          const Size(669, 951),
          const Size(1000, 1000),
        ]) {
          await tester.binding.setSurfaceSize(size);
          await tester.pump();
          expect(tester.state(find.byType(ItemEditScreen)), same(state));
          expect(field.controller!.selection.baseOffset, 3);
          expect(focus.hasFocus, isTrue);
        }
        expect(container.read(engageFilterProvider).energy, Energy.low);
        if (source == 'search') {
          expect(container.read(searchQueryProvider), 'Task');
          expect(container.read(searchFilterProvider).statuses, {
            ItemStatus.nextAction,
          });
        }
        await tester.tap(find.widgetWithText(ItemCard, 'Task beta'));
        await settle(tester);
        expect((await items.getById('alpha'))!.title, 'Task edited');
        expect(find.widgetWithText(TextField, 'Task beta'), findsOneWidget);
        await tester.pageBack();
        await settle(tester);
        expect(find.byType(ItemEditScreen), findsNothing);
        expect(
          source == 'do'
              ? find.byType(EngageScreen)
              : find.byType(SearchScreen),
          findsOneWidget,
        );
        expect(find.widgetWithText(ItemCard, 'Task edited'), findsOneWidget);
      },
    );

    testWidgets(
      '$source retains the current draft on save failure and returns correctly after completion',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1000, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final failing = _FailingItems(env.db, env.clock);
        await openApp(
          tester,
          source,
          overrides: [itemRepositoryProvider.overrideWithValue(failing)],
        );
        await tester.tap(find.widgetWithText(ItemCard, 'Task alpha'));
        await settle(tester);
        await tester.enterText(
          find.widgetWithText(TextField, 'Task alpha'),
          'Task retained',
        );
        await tester.tap(find.widgetWithText(ItemCard, 'Task beta'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.widgetWithText(TextField, 'Task retained'), findsOneWidget);
        expect(
          find.text("Couldn't save your changes. Please try again."),
          findsOneWidget,
        );
        failing.fail = false;
        await tester.tap(find.widgetWithText(ItemCard, 'Task beta'));
        await settle(tester);
        expect((await items.getById('alpha'))!.title, 'Task retained');
        await tester.scrollUntilVisible(
          find.text('Mark complete'),
          250,
          scrollable: find
              .descendant(
                of: find.byType(ItemEditScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mark complete'));
        await settle(tester);
        expect((await items.getById('beta'))!.status, ItemStatus.done);
        expect(find.byType(ItemEditScreen), findsNothing);
        expect(find.widgetWithText(ItemCard, 'Task beta'), findsNothing);
      },
    );

    testWidgets('$source keeps compact full-screen editing', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openApp(tester, source);
      await tester.tap(find.widgetWithText(ItemCard, 'Task alpha'));
      await settle(tester);
      expect(find.byType(ItemEditScreen), findsOneWidget);
      expect(find.byType(ItemCard), findsNothing);
      await tester.pageBack();
      await settle(tester);
      expect(find.widgetWithText(ItemCard, 'Task alpha'), findsOneWidget);
    });
  }

  for (final source in ['do', 'search']) {
    testWidgets('$source falls back at 3x text without recreating the editor', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(tester, source);
      await tester.tap(find.widgetWithText(ItemCard, 'Task alpha'));
      await settle(tester);
      final state = tester.state(find.byType(ItemEditScreen));
      expect(find.widgetWithText(ItemCard, 'Task beta'), findsOneWidget);
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      await tester.pump();
      expect(find.byType(ItemCard), findsNothing);
      expect(tester.state(find.byType(ItemEditScreen)), same(state));
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      await tester.pump();
      expect(find.widgetWithText(ItemCard, 'Task beta'), findsOneWidget);
    });
  }

  testWidgets(
    'Search query changes can hide the current result without losing its draft',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = await openApp(tester, 'search');
      await tester.tap(find.widgetWithText(ItemCard, 'Task alpha'));
      await settle(tester);
      final state = tester.state(find.byType(ItemEditScreen));
      await tester.enterText(
        find.widgetWithText(TextField, 'Task alpha'),
        'Task unsaved',
      );
      // Change the context query while its selected item is still being edited.
      await tester.enterText(find.widgetWithText(TextField, 'Task'), 'beta');
      await settle(tester);
      expect(container.read(searchQueryProvider), 'beta');
      expect(find.widgetWithText(ItemCard, 'Task alpha'), findsNothing);
      expect(tester.state(find.byType(ItemEditScreen)), same(state));
      expect(find.widgetWithText(TextField, 'Task unsaved'), findsOneWidget);
      await tester.tap(find.widgetWithText(ItemCard, 'Task beta'));
      await settle(tester);
      expect((await items.getById('alpha'))!.title, 'Task unsaved');
      expect(find.widgetWithText(TextField, 'Task beta'), findsOneWidget);
      await tester.pageBack();
      await settle(tester);
      expect(find.widgetWithText(TextField, 'beta'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets(
    'Today and calendar items open Do workspaces with read-only context actions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await items.upsert(
        anItem(
          id: 'meeting',
          title: 'Team meeting',
          status: ItemStatus.calendar,
          dueAt: env.clock.now(),
        ),
      );
      final container = await openApp(tester, 'do', today: true);
      await tester.tap(find.widgetWithText(ItemCard, 'Team meeting'));
      await settle(tester);
      expect(container.read(doViewProvider), DoView.today);
      expect(find.widgetWithText(TextField, 'Team meeting'), findsOneWidget);
      for (final card in tester.widgetList<ItemCard>(find.byType(ItemCard))) {
        expect(card.onComplete, isNull);
        expect(card.onDelete, isNull);
        expect(card.onToggleFocus, isNull);
        expect(card.onMoveToProject, isNull);
      }
      await tester.tap(find.widgetWithText(ItemCard, 'Task beta'));
      await settle(tester);
      expect(find.widgetWithText(TextField, 'Task beta'), findsOneWidget);
      await tester.pageBack();
      await settle(tester);
      expect(container.read(doViewProvider), DoView.today);
    },
  );

  testWidgets(
    'Search keeps a far result visible through narrower layout and lets users browse away',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (var i = 0; i < 100; i++) {
        await items.upsert(
          anItem(
            id: 'long$i',
            title:
                'Task $i with a long description to coordinate the complete launch with regional partners and all supporting materials',
            status: ItemStatus.nextAction,
            createdAt: env.clock.now().add(Duration(seconds: i)),
          ),
        );
      }
      await openApp(tester, 'search');
      final result = find.byWidgetPredicate(
        (w) => w is ItemCard && w.item.id == 'long50',
      );
      final list = find.descendant(
        of: find.byType(SearchScreen),
        matching: find.byWidgetPredicate(
          (w) => w is Scrollable && w.controller is WorkspaceScrollController,
        ),
      );
      final sourcePosition = tester.state<ScrollableState>(list).position;
      for (var i = 0; i < 50 && result.evaluate().isEmpty; i++) {
        sourcePosition.jumpTo(
          (sourcePosition.pixels + 350).clamp(
            0.0,
            sourcePosition.maxScrollExtent,
          ),
        );
        await tester.pump();
      }
      expect(result, findsOneWidget);
      await tester.ensureVisible(result);
      await tester.pumpAndSettle();
      final sourceOffset = sourcePosition.pixels;
      expect(sourceOffset, greaterThan(0));
      await tester.tap(result);
      await settle(tester);
      expect(result, findsOneWidget);
      expect(tester.getRect(result).overlaps(tester.getRect(list)), isTrue);
      await tester.binding.setSurfaceSize(const Size(669, 951));
      await settle(tester);
      expect(tester.getRect(result).overlaps(tester.getRect(list)), isTrue);
      final position = tester.state<ScrollableState>(list).position;
      final selectedOffset = position.pixels;
      await tester.drag(list, const Offset(0, -350));
      await tester.pumpAndSettle();
      final pixels = position.pixels;
      expect(pixels, greaterThan(selectedOffset + 50));
      await tester.pump(const Duration(milliseconds: 500));
      expect(position.pixels, pixels);
      await tester.binding.setSurfaceSize(const Size(1100, 1000));
      await tester.pump();
      await tester.pageBack();
      await settle(tester);
      expect(
        tester.state<ScrollableState>(list).position.pixels,
        closeTo(sourceOffset, 1),
      );
    },
  );
}
