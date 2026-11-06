import 'dart:async';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/features/projects/project_detail_screen.dart';
import 'package:cleartray/features/projects/projects_screen.dart';
import 'package:cleartray/features/shell/app_shell.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/adaptive_workspace.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/process/process_inbox_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _DelayedProjects extends ProjectRepository {
  _DelayedProjects(super.db);
  final saved = Completer<void>();
  @override
  Future<void> updateOutcome(String id, String? outcome, DateTime now) async {
    if (outcome == 'Finished outcome') await saved.future;
    await super.updateOutcome(id, outcome, now);
  }
}

class _FailingItems extends ItemRepository {
  _FailingItems(super.db, super.clock);
  bool fail = true;
  @override
  Future<void> upsert(Item item) {
    if (fail) throw StateError('disk full');
    return super.upsert(item);
  }
}

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(prefsValues: {'onboarding_complete_v1': true});
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  Future<ProviderContainer> routerApp(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    final container = env.container(overrides);
    await ProjectRepository(env.db).upsert(
      Project(
        id: 'p',
        title: 'Launch',
        status: ProjectStatus.active,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      ),
    );
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
    await settle(tester);
    return container;
  }

  testWidgets(
    'project editor retains dirty text, focus and selection through resize',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = await routerApp(tester);
      final router = container.read(routerProvider);
      router.go('/projects');
      await settle(tester);
      await tester.tap(find.text('Launch'));
      await settle(tester);
      await tester.tap(find.text('Task a'));
      await settle(tester);
      final editorState = tester.state(find.byType(ItemEditScreen));
      final field = find.widgetWithText(TextField, 'Task a');
      await tester.enterText(field, 'Unsaved task');
      final controller = tester
          .widget<TextField>(find.widgetWithText(TextField, 'Unsaved task'))
          .controller!;
      controller.selection = const TextSelection.collapsed(offset: 4);
      final focus = FocusManager.instance.primaryFocus;
      // No 600ms autosave delay between editing and resizing.
      await tester.binding.setSurfaceSize(const Size(375, 800));
      await tester.pump();
      expect(tester.state(find.byType(ItemEditScreen)), same(editorState));
      expect(find.widgetWithText(TextField, 'Unsaved task'), findsOneWidget);
      expect(controller.selection.baseOffset, 4);
      expect(FocusManager.instance.primaryFocus, same(focus));
      expect(find.text('Task b'), findsNothing);
      for (final size in [
        const Size(800, 375),
        const Size(669, 951),
        const Size(951, 669),
        const Size(900, 1000),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pump();
        expect(tester.state(find.byType(ItemEditScreen)), same(editorState));
        expect(controller.selection.baseOffset, 4);
      }
      expect(find.text('Task b'), findsOneWidget);
      // Rapid sidebar selection must persist before disposing the old editor.
      await tester.tap(find.text('Task b'));
      await settle(tester);
      expect((await items.getById('a'))!.title, 'Unsaved task');
      expect(find.widgetWithText(TextField, 'Task b'), findsOneWidget);
      await tester.pageBack();
      await settle(tester);
      // Replacement means one Back returns to the project, not Task a.
      expect(find.byType(ItemEditScreen), findsNothing);
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
    },
  );

  testWidgets(
    'failed save keeps editor selected; retry saves before switching',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final failing = _FailingItems(env.db, env.clock);
      final container = await routerApp(
        tester,
        overrides: [itemRepositoryProvider.overrideWithValue(failing)],
      );
      final router = container.read(routerProvider);
      router.go('/projects');
      await settle(tester);
      unawaited(router.push('/project/p'));
      await settle(tester);
      await tester.tap(find.text('Task a'));
      await settle(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Task a'),
        'Draft on full disk',
      );
      await tester.tap(find.text('Task b'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        find.widgetWithText(TextField, 'Draft on full disk'),
        findsOneWidget,
      );
      expect(
        find.text("Couldn't save your changes. Please try again."),
        findsOneWidget,
      );
      expect((await items.getById('a'))!.title, 'Task a');
      failing.fail = false;
      await tester.tap(find.text('Task b'));
      await settle(tester);
      expect((await items.getById('a'))!.title, 'Draft on full disk');
      expect(find.widgetWithText(TextField, 'Task b'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Mark complete'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ItemEditScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Mark complete'));
      await settle(tester);
      expect((await items.getById('b'))!.status, ItemStatus.done);
      expect(find.byType(ItemEditScreen), findsNothing);
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
    },
  );

  testWidgets(
    'project sidebar replaces the detail and tolerates a late outcome save',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final projects = _DelayedProjects(env.db);
      final container = await routerApp(
        tester,
        overrides: [projectRepositoryProvider.overrideWithValue(projects)],
      );
      await ProjectRepository(env.db).upsert(
        Project(
          id: 'q',
          title: 'Another project',
          status: ProjectStatus.active,
          createdAt: env.clock.now(),
          updatedAt: env.clock.now(),
        ),
      );
      final router = container.read(routerProvider);
      router.go('/projects');
      await settle(tester);
      await tester.tap(find.text('Launch'));
      await settle(tester);
      await tester.enterText(find.byType(TextField).first, 'Finished outcome');
      await tester.tap(find.text('Another project'));
      await settle(tester);
      expect(
        tester
            .widget<ProjectDetailScreen>(find.byType(ProjectDetailScreen))
            .projectId,
        'q',
      );
      projects.saved.complete();
      await settle(tester);
      expect((await projects.getById('p'))!.outcome, 'Finished outcome');
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await settle(tester);
      expect(find.byType(ProjectDetailScreen), findsNothing);
      expect(find.byType(ProjectsScreen), findsOneWidget);
    },
  );

  testWidgets('selected completed task remains visible in project context', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = await routerApp(tester);
    final item = (await items.getById('a'))!;
    await items.upsert(
      item.copyWith(status: ItemStatus.done, completedAt: env.clock.now()),
    );
    final router = container.read(routerProvider);
    router.go('/projects');
    await settle(tester);
    unawaited(router.push('/item/a?project=p'));
    await settle(tester);
    final tile = find.widgetWithText(ListTile, 'Task a');
    expect(tester.widget<ListTile>(tile).selected, isTrue);
    final editorState = tester.state(find.byType(ItemEditScreen));
    await tester.tap(tile);
    await tester.pump();
    expect(tester.state(find.byType(ItemEditScreen)), same(editorState));
  });

  testWidgets(
    'project list position survives opening details and collapsing the pane',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = await routerApp(tester);
      for (var i = 0; i < 40; i++) {
        await ProjectRepository(env.db).upsert(
          Project(
            id: 'project$i',
            title: 'Project $i',
            status: ProjectStatus.active,
            createdAt: env.clock.now(),
            updatedAt: env.clock.now().add(Duration(seconds: i)),
          ),
        );
      }
      container.read(routerProvider).go('/projects');
      await settle(tester);
      final scrollable = find
          .descendant(
            of: find.byType(ProjectsScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Project 18'),
        250,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
      final offset = tester.state<ScrollableState>(scrollable).position.pixels;
      expect(offset, greaterThan(0));
      await tester.tap(find.text('Project 18'));
      await settle(tester);
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        closeTo(offset, .1),
      );
      await tester.binding.setSurfaceSize(const Size(375, 800));
      await tester.pump();
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      await tester.pump();
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        closeTo(offset, .1),
      );
    },
  );

  testWidgets(
    'selected project stays visible after long titles reflow in the sidebar',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = await routerApp(tester);
      String title(int i) =>
          'Project $i: coordinate the complete launch plan with our regional partners and prepare all supporting materials';
      for (var i = 0; i < 40; i++) {
        await ProjectRepository(env.db).upsert(
          Project(
            id: 'long$i',
            title: title(i),
            status: ProjectStatus.active,
            createdAt: env.clock.now(),
            updatedAt: env.clock.now().add(Duration(seconds: i)),
          ),
        );
      }
      container.read(routerProvider).go('/projects');
      await settle(tester);
      Finder selected() => find.descendant(
        of: find.byType(ProjectsScreen),
        matching: find.text(title(18)),
      );
      await tester.ensureVisible(selected());
      await tester.pumpAndSettle();
      await tester.tap(selected());
      await settle(tester);
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      final scrollable = find
          .descendant(
            of: find.byType(ProjectsScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      void expectVisible() {
        final viewport = tester.getRect(scrollable);
        final selectedRect = tester.getRect(selected());
        expect(selectedRect.top, greaterThanOrEqualTo(viewport.top));
        expect(selectedRect.bottom, lessThanOrEqualTo(viewport.bottom));
      }

      expectVisible();
      await tester.binding.setSurfaceSize(const Size(375, 800));
      await tester.pump();
      await tester.binding.setSurfaceSize(const Size(669, 951));
      await settle(tester);
      expectVisible();
      // Saving project metadata can move the selected project to the top of
      // the repository's most-recently-updated order without a route change.
      final projects = ProjectRepository(env.db);
      final selectedProject = (await projects.getById('long18'))!;
      await projects.upsert(
        selectedProject.copyWith(
          updatedAt: env.clock.now().add(const Duration(hours: 1)),
        ),
      );
      await settle(tester);
      expectVisible();
    },
  );

  testWidgets(
    'Process Inbox uses its actual scroll viewport for compact fallback',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 520);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await items.upsert(
        anItem(id: 'viewport', title: 'Keep the current decision'),
      );
      await pumpApp(tester, const ProcessInboxScreen(), env: env);
      await settle(tester);
      Finder arrangement() => find
          .descendant(
            of: find.byType(AdaptiveWorkbench),
            matching: find.byType(Flex),
          )
          .first;
      // The app bar and content padding leave less than the 480-point budget.
      expect(tester.widget<Flex>(arrangement()).direction, Axis.vertical);
      await tester.tap(find.text('Yes — there is something to do'));
      await tester.pump();
      tester.view.physicalSize = const Size(900, 1000);
      await tester.pump();
      expect(tester.widget<Flex>(arrangement()).direction, Axis.horizontal);
      expect(find.text('Will it take less than 2 minutes?'), findsOneWidget);
      tester.view.physicalSize = const Size(900, 520);
      await tester.pump();
      expect(tester.widget<Flex>(arrangement()).direction, Axis.vertical);
      expect(find.text('Will it take less than 2 minutes?'), findsOneWidget);
    },
  );

  testWidgets(
    'rail respects horizontal safe areas and stays put above the keyboard',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final settings = ValueNotifier((side: 50.0, keyboard: 0.0));
      addTearDown(settings.dispose);
      await pumpApp(
        tester,
        ValueListenableBuilder(
          valueListenable: settings,
          builder: (context, value, _) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.symmetric(horizontal: value.side),
              viewInsets: EdgeInsets.only(bottom: value.keyboard),
            ),
            child: const AppShell(
              location: '/projects',
              child: Scaffold(body: TextField()),
            ),
          ),
        ),
        env: env,
      );
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      final state = tester.state(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Shell draft');
      final rail = find.byType(NavigationRail);
      for (final keyboard in [0.0, 1.0, 600.0, 0.0]) {
        settings.value = (side: 0.0, keyboard: keyboard);
        await tester.pump();
        expect(rail, findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(tester.getBottomLeft(rail).dy, 900 - keyboard);
      }
      final field = find.widgetWithText(TextField, 'Shell draft');
      expect(tester.state(field), same(state));
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rail changes preserve the shell child and compact bottom navigation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      final container = await routerApp(tester);
      container.read(routerProvider).go('/projects');
      await settle(tester);
      final navigator = tester.state(find.byType(Navigator).last);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      await tester.binding.setSurfaceSize(const Size(1000, 900));
      await tester.pump();
      expect(find.byType(NavigationRail), findsOneWidget);
      final rail = find.byType(NavigationRail);
      for (final label in ['Inbox', 'Do', 'Projects', 'Review', 'More']) {
        expect(
          find.descendant(of: rail, matching: find.text(label)),
          findsOneWidget,
        );
        final destination = find.descendant(
          of: rail,
          matching: find.bySemanticsLabel(RegExp('\\b$label\\b')),
        );
        expect(destination, findsOneWidget);
        final node = tester.getSemantics(destination).getSemanticsData();
        expect(node.hasAction(SemanticsAction.tap), isTrue);
        expect(
          node.flagsCollection.isSelected == Tristate.isTrue,
          label == 'Projects',
        );
      }
      expect(tester.widget<NavigationRail>(rail).selectedIndex, 2);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.state(find.byType(Navigator).last), same(navigator));
      await tester.binding.setSurfaceSize(const Size(375, 800));
      await tester.pump();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.state(find.byType(Navigator).last), same(navigator));
      semantics.dispose();
    },
  );

  testWidgets(
    'Process Inbox decision and dialog draft survive both directions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await items.upsert(anItem(id: 'a', title: 'Arrange trip'));
      await pumpApp(tester, const ProcessInboxScreen(), env: env);
      await settle(tester);
      expect(
        tester.getTopLeft(find.text('Arrange trip')).dx,
        lessThan(tester.getTopLeft(find.text('Is this actionable?')).dx),
      );
      await tester.tap(find.text('Yes — there is something to do'));
      await tester.pump();
      await tester.binding.setSurfaceSize(const Size(375, 800));
      await tester.pump();
      expect(find.text('Will it take less than 2 minutes?'), findsOneWidget);
      await tester.tap(find.text('No — keep clarifying'));
      await tester.pump();
      await tester.tap(find.text('Yes — delegate & wait for them'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sam');
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      expect(find.widgetWithText(TextField, 'Sam'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'OK'));
      await settle(tester);
      expect((await items.getById('a'))!.waitingOn, 'Sam');
    },
  );

  testWidgets(
    'large text and keyboard reduce to one pane without replacing detail',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final settings = ValueNotifier((scale: 1.0, keyboard: 0.0));
      addTearDown(settings.dispose);
      await pumpApp(
        tester,
        ValueListenableBuilder(
          valueListenable: settings,
          builder: (context, value, _) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(value.scale),
              viewInsets: EdgeInsets.only(bottom: value.keyboard),
            ),
            child: const AdaptiveWorkspace(
              primary: Scaffold(body: Text('Context pane')),
              detail: Scaffold(body: TextField()),
            ),
          ),
        ),
        env: env,
      );
      final state = tester.state(find.byType(TextField));
      expect(find.text('Context pane'), findsOneWidget);
      await tester.binding.setSurfaceSize(const Size(667, 375));
      await tester.pump();
      expect(find.text('Context pane'), findsNothing);
      expect(tester.state(find.byType(TextField)), same(state));
      await tester.binding.setSurfaceSize(const Size(900, 900));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Draft');
      settings.value = (scale: 3.0, keyboard: 0.0);
      await tester.pump();
      expect(find.text('Context pane'), findsNothing);
      expect(tester.state(find.byType(TextField)), same(state));
      expect(find.widgetWithText(TextField, 'Draft'), findsOneWidget);
      settings.value = (scale: 1.0, keyboard: 600.0);
      await tester.pump();
      expect(find.text('Context pane'), findsNothing);
      settings.value = (scale: 1.0, keyboard: 0.0);
      await tester.pump();
      expect(find.text('Context pane'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
