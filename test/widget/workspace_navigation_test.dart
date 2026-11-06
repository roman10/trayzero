import 'dart:async';

import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/projects/project_detail_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/harness.dart';

class _FailingItems extends ItemRepository {
  _FailingItems(super.db, super.clock);

  bool fail = true;

  @override
  Future<void> upsert(Item item) {
    if (fail) throw StateError('item save failed');
    return super.upsert(item);
  }
}

class _DelayedProjects extends ProjectRepository {
  _DelayedProjects(super.db);

  final firstWrite = Completer<void>();

  @override
  Future<void> updateOutcome(String id, String? outcome, DateTime now) async {
    if (outcome == 'First edit') await firstWrite.future;
    await super.updateOutcome(id, outcome, now);
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Finder _destination(String label) => find.descendant(
  of: find.byType(NavigationRail),
  matching: find.text(label),
);

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(prefsValues: {'onboarding_complete_v1': true});
    await ProjectRepository(env.db).upsert(
      Project(
        id: 'p',
        title: 'Launch plan',
        status: ProjectStatus.active,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      ),
    );
    items = ItemRepository(env.db, env.clock);
    for (final id in ['a', 'b']) {
      await items.upsert(
        anItem(
          id: id,
          title: 'Task $id',
          projectId: 'p',
          status: ItemStatus.nextAction,
        ),
      );
    }
  });
  tearDown(() => env.dispose());

  Future<GoRouter> open(
    WidgetTester tester,
    String tab, {
    List<Override> overrides = const [],
  }) async {
    final container = env.container(overrides);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    router.go(tab);
    await _settle(tester);
    return router;
  }

  testWidgets('Do editor preserves its list before adding the rail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, '/do');
    await tester.tap(find.widgetWithText(ItemCard, 'Task a'));
    await _settle(tester);
    final editor = tester.state(find.byType(ItemEditScreen));
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.widgetWithText(ItemCard, 'Task b'), findsNothing);

    await tester.binding.setSurfaceSize(const Size(669, 951));
    await tester.pump();
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.widgetWithText(ItemCard, 'Task b'), findsOneWidget);

    for (final size in [const Size(951, 669), const Size(1376, 1032)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pump();
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 1);
      expect(find.widgetWithText(ItemCard, 'Task b'), findsOneWidget);
      expect(tester.state(find.byType(ItemEditScreen)), same(editor));
    }

    await tester.pageBack();
    await _settle(tester);
    expect(find.byType(ItemEditScreen), findsNothing);
    expect(find.widgetWithText(ItemCard, 'Task a'), findsOneWidget);
  });

  testWidgets('project task retains its draft when switching tabs fails', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1133, 744);
    addTearDown(tester.view.reset);
    final failing = _FailingItems(env.db, env.clock);
    await open(
      tester,
      '/projects',
      overrides: [itemRepositoryProvider.overrideWithValue(failing)],
    );
    await tester.tap(find.text('Launch plan'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(ItemCard, 'Task a'));
    await _settle(tester);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      2,
    );

    final draft = find.widgetWithText(TextField, 'Unsaved title');
    await tester.enterText(
      find.widgetWithText(TextField, 'Task a'),
      'Unsaved title',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 315);
    await tester.pump();
    await tester.tap(_destination('Inbox'));
    await _settle(tester);
    expect(draft, findsOneWidget);
    final error = find.text("Couldn't save your changes. Please try again.");
    expect(error, findsOneWidget);
    expect(tester.getBottomLeft(error).dy, lessThan(744 - 315));
    expect((await items.getById('a'))!.title, 'Task a');

    failing.fail = false;
    await tester.tap(_destination('Inbox'));
    tester.view.resetViewInsets();
    await _settle(tester);
    expect(find.byType(ItemEditScreen), findsNothing);
    expect(find.byType(ProjectDetailScreen), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      0,
    );
    expect((await items.getById('a'))!.title, 'Unsaved title');
  });

  testWidgets('project rail awaits the latest queued outcome edit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(669, 951));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final projects = _DelayedProjects(env.db);
    await open(
      tester,
      '/projects',
      overrides: [projectRepositoryProvider.overrideWithValue(projects)],
    );
    await tester.tap(find.text('Launch plan'));
    await _settle(tester);
    final outcome = find.byType(TextField);
    await tester.enterText(outcome, 'First edit');
    await tester.enterText(outcome, 'Latest edit');
    await tester.tap(_destination('Do'));
    await _settle(tester);
    expect(find.byType(ProjectDetailScreen), findsOneWidget);

    await projects.changeStatus('p', ProjectStatus.onHold, env.clock.now());
    projects.firstWrite.complete();
    await _settle(tester);
    expect(find.byType(ProjectDetailScreen), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      1,
    );
    final project = (await projects.getById('p'))!;
    expect(project.outcome, 'Latest edit');
    expect(project.status, ProjectStatus.onHold);
  });
}
