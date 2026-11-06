import 'dart:io';
import 'dart:async';

import 'package:cleartray/core/microsoft_todo_gateway.dart';
import 'package:cleartray/features/app_import/app_import_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/harness.dart';
import '../support/import_flow.dart';
import '../support/microsoft_todo_fake.dart';
import '../support/things_fixture.dart';

void main() {
  late TestEnv env;
  setUp(
    () async => env = await TestEnv.create(now: DateTime(2026, 10, 26, 10)),
  );
  tearDown(() => env.dispose());

  Override pick(String fixture) => pickImportFileProvider.overrideWithValue(
    () async => (
      name: fixture,
      bytes: File('test/fixtures/import/$fixture').readAsBytesSync(),
    ),
  );

  late WidgetTester current;
  Future<int> itemCount() async =>
      (await current.runAsync(() => env.db.select(env.db.items).get()))!.length;

  /// Opens [source]'s page from the list (unless its page is already open)
  /// and returns the pinned [button] on it.
  Future<Finder> inCard(
    WidgetTester tester,
    String source,
    String button,
  ) async {
    final target = find.text(button);
    if (target.evaluate().isEmpty) await openSource(tester, source);
    return target;
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pump();
    // Drift completes its queries outside the fake clock: let real time
    // pass until the flow is no longer busy, then settle the frames.
    final container = importContainer(tester);
    for (var i = 0; i < 500; i++) {
      if (!container.read(appImportControllerProvider).busy) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// Scrolls the current list until [text] is built.
  Future<Finder> scrollTo(WidgetTester tester, String text) async {
    final target = find.text(text);
    await tester.scrollUntilVisible(
      target,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    return target;
  }

  /// Scrolls the collapsible preview card titled [title] into view and
  /// toggles it.
  Future<void> expand(WidgetTester tester, String title) async {
    final target = await scrollTo(tester, title);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  for (final sample in [
    (source: 'Todoist', fixture: 'todoist_official_template.csv', total: 4),
    (source: 'TickTick', fixture: 'ticktick_backup.csv', total: 7),
    (source: 'OmniFocus', fixture: 'omnifocus.taskpaper', total: 8),
  ]) {
    testWidgets('${sample.source} file → preview → import → Undo', (
      tester,
    ) async {
      current = tester;
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [pick(sample.fixture)],
      );
      await tap(tester, await inCard(tester, sample.source, 'Choose file'));
      expect(find.text('Review import'), findsOneWidget);
      expect(find.text('${sample.total} tasks'), findsOneWidget);
      expect(await itemCount(), 0);
      await tap(tester, find.textContaining('Import '));
      expect(find.text('${sample.total} tasks added'), findsOneWidget);
      expect(await itemCount(), sample.total);
      await tap(tester, find.text('Undo import'));
      expect(find.text('Import undone'), findsOneWidget);
      expect(await itemCount(), 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('source → preview → import → undo', (tester) async {
    current = tester;
    await pumpImportFlow(
      tester,
      env: env,
      extraOverrides: [pick('nirvana_export.csv')],
    );
    await tester.pumpAndSettle();
    expect(find.text('Todoist'), findsOneWidget);
    expect(
      await inCard(tester, 'Plain text / TaskPaper', 'Paste text'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tap(tester, await inCard(tester, 'Nirvana', 'Choose file'));
    expect(find.text('Review import'), findsOneWidget);
    expect(find.text('7 tasks'), findsOneWidget);
    expect(find.text('Nothing has been added yet.'), findsOneWidget);
    expect(find.text('Plan trip'), findsOneWidget);
    expect(await scrollTo(tester, 'Good to know'), findsOneWidget);
    expect(await itemCount(), 0);

    await tap(tester, find.textContaining('Import '));
    expect(find.text('7 tasks added'), findsOneWidget);
    expect(await itemCount(), 7);

    await tap(tester, find.text('Undo import'));
    expect(find.text('Import undone'), findsOneWidget);
    expect(await itemCount(), 0);
  });

  testWidgets(
    'Things database previews Areas, imports and undoes at large text',
    (tester) async {
      current = tester;
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpImportFlow(
        tester,
        env: env,
        textScaler: const TextScaler.linear(2),
        extraOverrides: [
          pickImportFileProvider.overrideWithValue(
            () async => (
              name: 'things.zip',
              bytes: thingsZip({'export/main.sqlite': thingsFixture()}),
            ),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tap(tester, await inCard(tester, 'Things 3', 'Choose file'));
      expect(find.text('3 tasks'), findsOneWidget);
      await expand(tester, 'Areas of focus');
      expect(await scrollTo(tester, 'New: Family'), findsOneWidget);
      expect(await itemCount(), 0);
      await tap(tester, find.textContaining('Import '));
      expect(find.text('3 tasks added'), findsOneWidget);
      expect(await itemCount(), 3);
      await tap(tester, await scrollTo(tester, 'Undo import'));
      expect(find.text('Import undone'), findsOneWidget);
      expect(await itemCount(), 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Google Tasks has preview, undo and a duplicate warning', (
    tester,
  ) async {
    current = tester;
    await pumpImportFlow(
      tester,
      env: env,
      extraOverrides: [pick('google_tasks.json')],
    );
    await tester.pumpAndSettle();
    await tap(tester, await inCard(tester, 'Google Tasks', 'Choose file'));
    expect(find.text('2 tasks'), findsOneWidget);
    expect(await itemCount(), 0);
    await tap(tester, find.textContaining('Import '));
    expect(await itemCount(), 2);
    final container = importContainer(tester);
    container.read(appImportControllerProvider.notifier).reset();
    await tester.pumpAndSettle();
    await tap(tester, await inCard(tester, 'Google Tasks', 'Choose file'));
    expect(
      find.textContaining('This exact input was imported before'),
      findsOneWidget,
    );
    // An informational notice, not an error: no error-container styling.
    expect(
      find.ancestor(
        of: find.textContaining('This exact input was imported before'),
        matching: find.byType(Card),
      ),
      findsNothing,
    );
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsWidgets);
    await tap(tester, find.text('Cancel'));
    expect(await itemCount(), 2);
    await tap(tester, await inCard(tester, 'Google Tasks', 'Choose file'));
    await tap(tester, find.textContaining('Import '));
    expect(await itemCount(), 4);
    await tap(tester, find.text('Undo import'));
    expect(await itemCount(), 2);
  });

  testWidgets('every source row shows a chevron, with or without a chip', (
    tester,
  ) async {
    current = tester;
    await pumpImportFlow(tester, env: env);
    await tester.pumpAndSettle();
    final rows = find.byType(InkWell);
    expect(rows, findsWidgets);
    for (final name in ['Todoist', 'Things 3']) {
      final row = find
          .ancestor(of: find.text(name), matching: find.byType(InkWell))
          .first;
      expect(
        find.descendant(of: row, matching: find.byIcon(Icons.chevron_right)),
        findsOneWidget,
        reason: name,
      );
    }
  });

  testWidgets('cancel from the preview writes nothing', (tester) async {
    current = tester;
    await pumpImportFlow(
      tester,
      env: env,
      extraOverrides: [pick('ticktick_backup.csv')],
    );
    await tester.pumpAndSettle();
    await tap(tester, await inCard(tester, 'TickTick', 'Choose file'));
    expect(find.text('Review import'), findsOneWidget);

    await tap(tester, find.text('Cancel'));
    expect(find.text('Review import'), findsNothing);
    expect(find.text('Choose file'), findsWidgets);
    expect(await itemCount(), 0);
  });

  testWidgets('a file from the wrong app explains itself', (tester) async {
    await pumpImportFlow(
      tester,
      env: env,
      extraOverrides: [pick('omnifocus.taskpaper')],
    );
    await tester.pumpAndSettle();
    await tap(tester, await inCard(tester, 'TickTick', 'Choose file'));
    expect(
      find.text(
        'This does not look like a TickTick export. Check the steps and '
        'try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('pasted text previews and imports, at large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpImportFlow(
      tester,
      env: env,
      textScaler: const TextScaler.linear(2),
    );
    await tester.pumpAndSettle();

    await tap(
      tester,
      await inCard(tester, 'Plain text / TaskPaper', 'Paste text'),
    );
    expect(find.text('Paste tasks'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'Garden:\n\t- Buy soil @errands\n\t- Prune roses\nCall Mom\n',
    );
    await tester.pumpAndSettle();
    await tap(tester, find.text('Preview'));

    expect(find.text('3 tasks'), findsOneWidget);
    expect(await scrollTo(tester, 'Garden'), findsOneWidget);
    await expand(tester, 'Contexts & tags');
    expect(await scrollTo(tester, 'New: @errands'), findsOneWidget);
    await tap(tester, find.textContaining('Import '));
    expect(find.text('3 tasks added'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The result buttons keep a 48dp touch target.
    for (final label in ['Undo import', 'Done']) {
      final button = await scrollTo(tester, label);
      final size = tester.getSize(
        find.ancestor(
          of: button,
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });
  testWidgets('Microsoft sign-in → preview → import → Undo, with large text', (
    tester,
  ) async {
    current = tester;
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gateway = FakeMicrosoftTodoGateway();
    await pumpImportFlow(
      tester,
      env: env,
      textScaler: const TextScaler.linear(2),
      extraOverrides: [microsoftTodoGatewayProvider.overrideWithValue(gateway)],
    );
    await tester.pumpAndSettle();
    await tap(tester, await inCard(tester, 'Microsoft To Do', 'Connect'));
    expect(gateway.reads, 1);
    expect(find.text('5 tasks'), findsOneWidget);
    expect(await itemCount(), 0);
    expect(await scrollTo(tester, 'Garage'), findsOneWidget);
    expect(await scrollTo(tester, 'Good to know'), findsOneWidget);
    await tap(tester, find.textContaining('Import '));
    expect(find.text('5 tasks added'), findsOneWidget);
    expect(await itemCount(), 5);
    await tap(tester, await scrollTo(tester, 'Undo import'));
    expect(find.text('Import undone'), findsOneWidget);
    expect(await itemCount(), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Microsoft preview cancellation writes nothing', (tester) async {
    current = tester;
    await pumpImportFlow(
      tester,
      env: env,
      extraOverrides: [
        microsoftTodoGatewayProvider.overrideWithValue(
          FakeMicrosoftTodoGateway(),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tap(tester, await inCard(tester, 'Microsoft To Do', 'Connect'));
    await tap(tester, find.text('Cancel'));
    expect(find.text('Review import'), findsNothing);
    expect(await itemCount(), 0);
  });

  testWidgets(
    'unconfigured Microsoft import is visibly unavailable and disabled',
    (tester) async {
      await pumpImportFlow(tester, env: env);
      await tester.pumpAndSettle();
      final button = await inCard(tester, 'Microsoft To Do', 'Connect');
      expect(
        find.text('Microsoft To Do import is unavailable in this build.'),
        findsOneWidget,
      );
      final widget = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: button,
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(widget.onPressed, isNull);
    },
  );

  testWidgets(
    'Microsoft network failure explains that nothing was imported and permits retry',
    (tester) async {
      current = tester;
      var failRead = true;
      final gateway = FakeMicrosoftTodoGateway(
        onRead: (_) async {
          if (failRead) {
            throw const MicrosoftTodoException(MicrosoftTodoFailure.network);
          }
          return microsoftTodoSnapshot();
        },
      );
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [
          microsoftTodoGatewayProvider.overrideWithValue(gateway),
        ],
      );
      await tester.pumpAndSettle();
      await tap(tester, await inCard(tester, 'Microsoft To Do', 'Connect'));
      expect(
        find.text(
          'Could not read all Microsoft tasks. Nothing was imported. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(await itemCount(), 0);
      failRead = false;
      await tap(tester, await inCard(tester, 'Microsoft To Do', 'Connect'));
      expect(find.text('5 tasks'), findsOneWidget);
      expect(gateway.reads, 2);
    },
  );

  testWidgets(
    'Microsoft read has a cancel action; a late response cannot show preview',
    (tester) async {
      current = tester;
      final pending = Completer<List<Map<String, Object?>>>();
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [
          microsoftTodoGatewayProvider.overrideWithValue(
            FakeMicrosoftTodoGateway(onRead: (_) => pending.future),
          ),
        ],
      );
      await tester.pumpAndSettle();
      final connect = await inCard(tester, 'Microsoft To Do', 'Connect');
      await tester.ensureVisible(connect);
      await tester.pumpAndSettle();
      await tester.tap(connect);
      await tester.pump();
      // The progress indicator deliberately keeps animating while reading.
      final cancel = await scrollTo(tester, 'Cancel');
      await tester.ensureVisible(cancel);
      await tester.pump();
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      pending.complete(microsoftTodoSnapshot());
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(find.text('Review import'), findsNothing);
      expect(await itemCount(), 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a stacked source page ignores another source\'s result', (
    tester,
  ) async {
    current = tester;
    // Fast double tap on the list stacks two source pages that share the
    // controller: Todoist underneath, Nirvana on top.
    await pumpImportFlow(
      tester,
      env: env,
      extraOverrides: [pick('nirvana_export.csv')],
      location: '/settings/import/todoist',
    );
    // push() completes only when the page pops; don't wait for it.
    unawaited(
      GoRouter.of(
        tester.element(find.byType(Scaffold).first),
      ).push('/settings/import/nirvana'),
    );
    await tester.pumpAndSettle();

    await tap(tester, find.text('Choose file'));
    await tap(tester, find.textContaining('Import '));
    expect(find.text('7 tasks added'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Todoist'), findsOneWidget);
    expect(find.text('7 tasks added'), findsNothing);
    expect(find.text('Choose file'), findsOneWidget);
  });

  group('preview polish', () {
    testWidgets('shows header, status tiles and a close button', (
      tester,
    ) async {
      current = tester;
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [pick('nirvana_export.csv')],
      );
      await tap(tester, await inCard(tester, 'Nirvana', 'Choose file'));
      expect(find.text('From Nirvana'), findsOneWidget);
      expect(find.text('7 tasks'), findsOneWidget);
      expect(find.text('Import 7 tasks'), findsOneWidget);
      // One tile per non-empty list, with its count; plus Projects.
      final p = importContainer(
        tester,
      ).read(appImportControllerProvider).preview!;
      final grid = find.byType(Wrap);
      expect(grid, findsWidgets);
      for (final entry in p.byStatus.entries) {
        expect(
          find.descendant(
            of: find.byType(Wrap),
            matching: find.text('${entry.value}'),
          ),
          findsWidgets,
        );
      }
      expect(find.text('${p.projects.length}'), findsWidgets);
      // The X cancels back to the source page, writing nothing.
      await tap(tester, find.byIcon(Icons.close));
      expect(find.text('Review import'), findsNothing);
      expect(find.text('Choose file'), findsWidgets);
      expect(await itemCount(), 0);
    });

    testWidgets('Show all reveals every project beyond the first three', (
      tester,
    ) async {
      current = tester;
      await tester.binding.setSurfaceSize(const Size(360, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpImportFlow(tester, env: env);
      await tap(
        tester,
        await inCard(tester, 'Plain text / TaskPaper', 'Paste text'),
      );
      await tester.enterText(
        find.byType(TextField),
        'Alpha:\n\t- a1\nBravo:\n\t- b1\nCharlie:\n\t- c1\nDelta:\n\t- d1\nEcho:\n\t- e1\n',
      );
      await tester.pumpAndSettle();
      await tap(tester, find.text('Preview'));
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Delta'), findsNothing);
      expect(find.text('Echo'), findsNothing);
      await tester.tap(find.text('Show all 5'));
      await tester.pumpAndSettle();
      expect(find.text('Delta'), findsOneWidget);
      expect(find.text('Echo'), findsOneWidget);
      expect(find.text('Show all 5'), findsNothing);
    });

    testWidgets('Good to know starts collapsed, then shows the notes', (
      tester,
    ) async {
      current = tester;
      await tester.binding.setSurfaceSize(const Size(360, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [pick('nirvana_export.csv')],
      );
      await tap(tester, await inCard(tester, 'Nirvana', 'Choose file'));
      final p = importContainer(
        tester,
      ).read(appImportControllerProvider).preview!;
      expect(p.warnings, isNotEmpty);
      expect(find.text('Good to know'), findsOneWidget);
      expect(find.textContaining('${p.warnings.length} note'), findsOneWidget);
      final detail = find.byIcon(Icons.info_outline);
      expect(detail.hitTestable(), findsNothing);
      await tester.tap(find.text('Good to know'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('no overflow at 2x text on a 360x690 surface', (tester) async {
      current = tester;
      await tester.binding.setSurfaceSize(const Size(360, 690));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpImportFlow(
        tester,
        env: env,
        textScaler: const TextScaler.linear(2),
        extraOverrides: [pick('nirvana_export.csv')],
      );
      await tap(tester, await inCard(tester, 'Nirvana', 'Choose file'));
      expect(find.text('Review import'), findsOneWidget);
      await expand(tester, 'Good to know');
      expect(tester.takeException(), isNull);
      final importButton = find.ancestor(
        of: find.textContaining('Import 7'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.getSize(importButton).height, greaterThanOrEqualTo(48));
    });
  });

  group('source list and source page', () {
    /// A tall surface so the whole list is built and on screen.
    void tallTest(String name, Future<void> Function(WidgetTester) body) =>
        testWidgets(name, (tester) async {
          await tester.binding.setSurfaceSize(const Size(400, 1600));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await body(tester);
        });

    tallTest('the list shows grouped rows with subtitles, not hint text', (
      tester,
    ) async {
      await pumpImportFlow(tester, env: env);
      expect(find.text('From an export file'), findsOneWidget);
      expect(find.text('Anything else'), findsOneWidget);
      expect(find.text('Takeout · Tasks.json'), findsOneWidget);
      expect(find.text('CSV template or backup ZIP'), findsOneWidget);
      expect(find.text('Microsoft To Do'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      // No wall of text: step paragraphs live on the source page only.
      expect(find.textContaining('Settings › General'), findsNothing);
      // Apple Reminders is hidden where the platform cannot read it.
      expect(find.text('Connect directly'), findsOneWidget);
      expect(find.text('Choose file'), findsNothing);
    });

    tallTest('a row opens its page with steps and a pinned action', (
      tester,
    ) async {
      await pumpImportFlow(tester, env: env);
      await openSource(tester, 'TickTick');
      expect(find.text('Choose file'), findsOneWidget);
      expect(find.textContaining('Generate Backup'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Paste text'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('From an export file'), findsOneWidget);
    });

    tallTest('the Things device toggle switches the steps', (tester) async {
      await pumpImportFlow(tester, env: env);
      await openSource(tester, 'Things 3');
      expect(find.textContaining('Send Things Database'), findsOneWidget);
      expect(find.text('491348'), findsOneWidget);
      expect(
        find.textContaining("Repeats and reminders don't"),
        findsOneWidget,
      );
      await tester.tap(find.text('Mac'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Send Things Database'), findsNothing);
      expect(find.text('491348'), findsNothing);
      expect(find.text('Quit Things on your Mac.'), findsOneWidget);
      await tester.tap(find.text('iPhone / iPad'));
      await tester.pumpAndSettle();
      expect(find.text('491348'), findsOneWidget);
    });

    tallTest('an error shows on the source page and not on the next', (
      tester,
    ) async {
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [pick('omnifocus.taskpaper')],
      );
      await tap(tester, await inCard(tester, 'TickTick', 'Choose file'));
      expect(find.textContaining('does not look like a TickTick'), findsOne);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await openSource(tester, 'Nirvana');
      expect(find.textContaining('does not look like'), findsNothing);
    });

    tallTest('Done returns to settings; the footer opens backup', (
      tester,
    ) async {
      current = tester;
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [pick('nirvana_export.csv')],
      );
      await tester.scrollUntilVisible(
        find.text('Backup & restore'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Backup & restore'));
      await tester.pumpAndSettle();
      expect(find.text('stub:backup'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tap(tester, await inCard(tester, 'Nirvana', 'Choose file'));
      await tap(tester, find.textContaining('Import '));
      await tap(tester, find.text('Done'));
      expect(find.text('stub:settings'), findsOneWidget);
    });
  });
}
