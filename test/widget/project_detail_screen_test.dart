import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/projects/project_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Project _project({
  String id = 'p1',
  String title = 'Launch website',
  ProjectStatus status = ProjectStatus.active,
  String? outcome,
}) {
  final ts = DateTime(2026, 5, 14, 9);
  return Project(
    id: id,
    title: title,
    status: status,
    outcome: outcome,
    createdAt: ts,
    updatedAt: ts,
  );
}

/// The screen first loads the project via a Future (setState), then begins
/// watching the project-items stream — two async hops. Pump a few times so
/// both settle before asserting.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
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

  testWidgets('renders Stalled banner when project has no movement',
      (tester) async {
    await projects.upsert(_project());

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.text('Launch website'), findsOneWidget);
    expect(find.text('No next actions yet.'), findsOneWidget);
    expect(find.textContaining('Stalled'), findsOneWidget);
    expect(
      find.textContaining('moving through waiting or scheduled'),
      findsNothing,
    );
  });

  testWidgets('renders Awaiting banner when only waiting items exist',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'w',
      title: 'Awaiting designer mockups',
      status: ItemStatus.waiting,
      projectId: 'p1',
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(
      find.textContaining('moving through waiting or scheduled'),
      findsOneWidget,
    );
    expect(find.textContaining('Stalled'), findsNothing);
  });

  testWidgets('renders Awaiting banner when only scheduled items exist',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'c',
      title: 'Kickoff meeting',
      status: ItemStatus.calendar,
      projectId: 'p1',
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(
      find.textContaining('moving through waiting or scheduled'),
      findsOneWidget,
    );
    expect(find.textContaining('Stalled'), findsNothing);
  });

  testWidgets(
      'someday and reference items alone do not count as movement (stalled)',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'ref',
      title: 'Hosting comparison doc',
      status: ItemStatus.reference,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'sm',
      title: 'Maybe add a blog later',
      status: ItemStatus.someday,
      projectId: 'p1',
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.textContaining('Stalled'), findsOneWidget);
    expect(
      find.textContaining('moving through waiting or scheduled'),
      findsNothing,
    );
  });

  testWidgets('renders next actions and waiting items for the project',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'a',
      title: 'Buy domain',
      status: ItemStatus.nextAction,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'b',
      title: 'Awaiting designer mockups',
      status: ItemStatus.waiting,
      projectId: 'p1',
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.text('Buy domain'), findsOneWidget);
    expect(find.text('Awaiting designer mockups'), findsOneWidget);
    expect(find.text('WAITING FOR'), findsOneWidget);
    // Has a next action -> healthy, no banners.
    expect(find.textContaining('Stalled'), findsNothing);
    expect(
      find.textContaining('moving through waiting or scheduled'),
      findsNothing,
    );
  });

  testWidgets('next actions render as a reorderable list with drag handles',
      (tester) async {
    // The drag→persist→reorder behaviour is covered deterministically by
    // project_reorder_logic_test, reorder_project_actions_test and the
    // item_repository ordering tests. This only asserts the section is
    // wired as a ReorderableListView with a handle per action — driving
    // onReorder + pumpAndSettle here is flaky because flutter_slidable
    // keeps animation controllers alive (hence the fixed-pump _settle).
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'a',
      title: 'First action',
      status: ItemStatus.nextAction,
      projectId: 'p1',
      createdAt: DateTime(2026, 5, 14, 9),
    ));
    await items.upsert(anItem(
      id: 'b',
      title: 'Second action',
      status: ItemStatus.nextAction,
      projectId: 'p1',
      createdAt: DateTime(2026, 5, 14, 10),
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    expect(find.text('First action'), findsOneWidget);
    expect(find.text('Second action'), findsOneWidget);
    final list =
        tester.widget<ReorderableListView>(find.byType(ReorderableListView));
    expect(list.onReorderItem, isNotNull);
  });

  testWidgets('Add action dialog persists a new next action via the repo',
      (tester) async {
    await projects.upsert(_project());

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    await tester.tap(find.text('Add action'));
    await tester.pumpAndSettle();

    expect(find.text('Add next action'), findsOneWidget);
    await tester.enterText(
        find.byType(TextField).last, 'Email the host provider');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // FixedIdGenerator falls back to a `test-N` sequence; first id is test-1.
    final saved = await items.getById('test-1');
    expect(saved, isNotNull);
    expect(saved!.title, 'Email the host provider');
    expect(saved.status, ItemStatus.nextAction);
    expect(saved.projectId, 'p1');
    // Dialog dismissed; the new action now renders as a card in the list.
    expect(find.text('Add next action'), findsNothing);
    expect(find.text('Email the host provider'), findsOneWidget);
  });

  testWidgets(
      'secondary lists are collapsed by default: count shows, items hidden',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'na',
      title: 'Buy domain',
      status: ItemStatus.nextAction,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'ref',
      title: 'Hosting comparison doc',
      status: ItemStatus.reference,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'sm',
      title: 'Maybe add a blog later',
      status: ItemStatus.someday,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'done1',
      title: 'Picked a name',
      status: ItemStatus.done,
      projectId: 'p1',
      completedAt: DateTime(2026, 5, 13, 9),
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    // Headers carry the count and act as the progress signal while collapsed.
    expect(find.text('REFERENCE (1)'), findsOneWidget);
    expect(find.text('SOMEDAY (1)'), findsOneWidget);
    expect(find.text('COMPLETED (1)'), findsOneWidget);
    // The active next action is still visible without any interaction.
    expect(find.text('Buy domain'), findsOneWidget);
    // Collapsed bodies are not built.
    expect(find.text('Hosting comparison doc'), findsNothing);
    expect(find.text('Maybe add a blog later'), findsNothing);
    expect(find.text('Picked a name'), findsNothing);
  });

  testWidgets('tapping a secondary header expands its items', (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'na',
      title: 'Buy domain',
      status: ItemStatus.nextAction,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'ref',
      title: 'Hosting comparison doc',
      status: ItemStatus.reference,
      projectId: 'p1',
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.text('Hosting comparison doc'), findsNothing);

    await tester.tap(find.text('REFERENCE (1)'));
    await _settle(tester);

    expect(find.text('Hosting comparison doc'), findsOneWidget);

    // Tapping again collapses it back.
    await tester.tap(find.text('REFERENCE (1)'));
    await _settle(tester);
    expect(find.text('Hosting comparison doc'), findsNothing);
  });

  testWidgets(
      'completed items surface only via watchCompletedForProject section',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'na',
      title: 'Open work',
      status: ItemStatus.nextAction,
      projectId: 'p1',
    ));
    await items.upsert(anItem(
      id: 'done1',
      title: 'Registered the domain',
      status: ItemStatus.done,
      projectId: 'p1',
      completedAt: DateTime(2026, 5, 13, 9),
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.text('COMPLETED (1)'), findsOneWidget);
    expect(find.text('Registered the domain'), findsNothing);

    await tester.tap(find.text('COMPLETED (1)'));
    await _settle(tester);

    expect(find.text('Registered the domain'), findsOneWidget);
  });

  testWidgets('a project with only next actions shows no secondary sections',
      (tester) async {
    await projects.upsert(_project());
    await items.upsert(anItem(
      id: 'na',
      title: 'Buy domain',
      status: ItemStatus.nextAction,
      projectId: 'p1',
    ));

    await pumpApp(tester, const ProjectDetailScreen(projectId: 'p1'),
        env: env);
    await _settle(tester);

    expect(find.textContaining('REFERENCE'), findsNothing);
    expect(find.textContaining('SOMEDAY'), findsNothing);
    expect(find.textContaining('SCHEDULED'), findsNothing);
    expect(find.textContaining('NEEDS CLARIFYING'), findsNothing);
    expect(find.textContaining('COMPLETED'), findsNothing);
  });
}
