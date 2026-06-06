import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Project _project({required String id, required String title}) {
  final ts = DateTime(2026, 5, 14, 9);
  return Project(
    id: id,
    title: title,
    status: ProjectStatus.active,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  late TestEnv env;
  late ItemRepository items;
  late ProjectRepository projects;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
    projects = ProjectRepository(env.db);
  });
  tearDown(() => env.dispose());

  Future<void> type(WidgetTester tester, String q) async {
    await tester.enterText(find.byType(TextField), q);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('prompts for two characters before searching', (tester) async {
    await pumpApp(tester, const SearchScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Type at least two characters'), findsOneWidget);
  });

  testWidgets('toggling a status chip re-filters without retyping',
      (tester) async {
    await items.upsert(
        anItem(id: 'a', title: 'Report alpha', status: ItemStatus.inbox));
    await items.upsert(
        anItem(id: 'b', title: 'Report beta', status: ItemStatus.nextAction));

    await pumpApp(tester, const SearchScreen(), env: env);
    await type(tester, 'report');

    expect(find.text('Report alpha'), findsOneWidget);
    expect(find.text('Report beta'), findsOneWidget);

    // Narrow to Inbox only — no retyping.
    await tester.tap(find.widgetWithText(FilterChip, 'Inbox'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Report alpha'), findsOneWidget);
    expect(find.text('Report beta'), findsNothing);
  });

  testWidgets('completed items are hidden until the Completed chip is on',
      (tester) async {
    await items.upsert(
        anItem(id: 'a', title: 'Report live', status: ItemStatus.nextAction));
    await items.upsert(anItem(
      id: 'b',
      title: 'Report finished',
      status: ItemStatus.done,
      completedAt: DateTime(2026, 5, 13),
    ));

    await pumpApp(tester, const SearchScreen(), env: env);
    await type(tester, 'report');

    expect(find.text('Report live'), findsOneWidget);
    expect(find.text('Report finished'), findsNothing);

    final completedChip = find.widgetWithText(FilterChip, 'Completed');
    await tester.ensureVisible(completedChip);
    await tester.pump();
    await tester.tap(completedChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Report finished'), findsOneWidget);
  });

  testWidgets('clear-filters button resets to unfiltered results',
      (tester) async {
    await items.upsert(
        anItem(id: 'a', title: 'Report alpha', status: ItemStatus.inbox));
    await items.upsert(
        anItem(id: 'b', title: 'Report beta', status: ItemStatus.nextAction));

    await pumpApp(tester, const SearchScreen(), env: env);
    await type(tester, 'report');

    await tester.tap(find.widgetWithText(FilterChip, 'Inbox'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Report beta'), findsNothing);

    await tester.tap(find.byTooltip('Clear filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Report alpha'), findsOneWidget);
    expect(find.text('Report beta'), findsOneWidget);
  });

  testWidgets('empty-state copy differs with vs without active filters',
      (tester) async {
    await items.upsert(
        anItem(id: 'a', title: 'Report alpha', status: ItemStatus.inbox));

    await pumpApp(tester, const SearchScreen(), env: env);

    // No filter, no match → "No matches for ...".
    await type(tester, 'zzzzz');
    expect(find.textContaining('No matches for'), findsOneWidget);

    // A query that matches but is filtered out → filtered empty state.
    await type(tester, 'report');
    await tester.tap(find.widgetWithText(FilterChip, 'Waiting'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Nothing matches'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  // The project chip sits at the end of the horizontal status strip; on the
  // default 800px test surface it is off-screen and the lazy sliver never
  // builds it. Widen the viewport so the whole strip is laid out.
  void useWideSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('picking a project from the sheet narrows results',
      (tester) async {
    useWideSurface(tester);
    await projects.upsert(_project(id: 'p1', title: 'Website'));
    await items.upsert(anItem(
        id: 'a',
        title: 'Report alpha',
        status: ItemStatus.nextAction,
        projectId: 'p1'));
    await items.upsert(anItem(
        id: 'b', title: 'Report beta', status: ItemStatus.nextAction));

    await pumpApp(tester, const SearchScreen(), env: env);
    await type(tester, 'report');
    expect(find.text('Report alpha'), findsOneWidget);
    expect(find.text('Report beta'), findsOneWidget);

    // Open the project picker chip and choose the project.
    await tester.tap(find.widgetWithText(FilterChip, 'All projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Website'));
    await tester.pumpAndSettle();

    expect(find.text('Report alpha'), findsOneWidget);
    expect(find.text('Report beta'), findsNothing);
    // The chip now reflects the active project selection.
    expect(find.widgetWithText(FilterChip, 'Website'), findsOneWidget);
  });

  testWidgets('a deleted selected project self-heals to all projects',
      (tester) async {
    useWideSurface(tester);
    await projects.upsert(_project(id: 'p1', title: 'Website'));
    await items.upsert(anItem(
        id: 'a',
        title: 'Report alpha',
        status: ItemStatus.nextAction,
        projectId: 'p1'));
    await items.upsert(anItem(
        id: 'b', title: 'Report beta', status: ItemStatus.nextAction));

    await pumpApp(tester, const SearchScreen(), env: env);
    await type(tester, 'report');

    await tester.tap(find.widgetWithText(FilterChip, 'All projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Website'));
    await tester.pumpAndSettle();
    expect(find.text('Report beta'), findsNothing);

    // The selected project disappears (deleted elsewhere) — the dangling
    // filter must drop rather than silently hide everything.
    await projects.delete('p1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(FilterChip, 'All projects'), findsOneWidget);
    expect(find.text('Report alpha'), findsOneWidget);
    expect(find.text('Report beta'), findsOneWidget);
  });
}
