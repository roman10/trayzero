import 'dart:async';

import 'package:cleartray/core/apple_reminders_gateway.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/features/app_import/app_import_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/apple_reminders_fake.dart';
import '../support/harness.dart';
import '../support/import_flow.dart';

void main() {
  late TestEnv env;
  late FakeAppleRemindersGateway gateway;
  setUp(() async {
    env = await TestEnv.create();
    gateway = FakeAppleRemindersGateway();
  });
  tearDown(() => env.dispose());

  /// Pumps the import list and, unless [open] is false, opens the Apple
  /// Reminders source page.
  Future<void> pump(
    WidgetTester tester, {
    double scale = 1,
    bool open = true,
  }) async {
    await pumpImportFlow(
      tester,
      env: env,
      textScaler: TextScaler.linear(scale),
      extraOverrides: [
        appleRemindersGatewayProvider.overrideWithValue(gateway),
      ],
    );
    if (open) await openSource(tester, 'Apple Reminders');
  }

  Future<void> tap(WidgetTester tester, String text) async {
    final target = find.text(text);
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        target,
        120,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pump();
    final container = importContainer(tester);
    for (
      var i = 0;
      i < 500 && container.read(appImportControllerProvider).busy;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
    'selected lists → preview → import → Undo; source and existing data stay intact',
    (tester) async {
      gateway.reminders = const [
        AppleReminder(id: 'a', listId: 'home', title: 'Buy milk'),
        AppleReminder(id: 'b', listId: 'work', title: 'Do not import'),
        AppleReminder(
          id: 'c',
          listId: 'home',
          title: 'Already done',
          completed: true,
        ),
      ];
      await pump(tester);
      expect(gateway.requests, 0); // Opening Settings never prompts.
      await tap(tester, 'Choose lists');
      expect(gateway.requests, 1);
      expect(find.text('iCloud'), findsWidgets);
      final previewButton = find.widgetWithText(FilledButton, 'Preview');
      expect(tester.widget<FilledButton>(previewButton).onPressed, isNull);
      await tap(tester, 'Home');
      await tap(tester, 'Preview');
      expect(find.text('1 task'), findsOneWidget);
      expect(gateway.reads, [
        {'home'},
      ]);
      expect(
        await tester.runAsync(() => env.db.select(env.db.items).get()),
        isEmpty,
      );
      await tap(
        tester,
        'Cancel',
      ); // Back to selected lists, no extra permissions.
      final checkbox = tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('apple-list-home')),
      );
      expect(checkbox.value, isTrue);
      expect(gateway.requests, 1);
      await tap(tester, 'Preview');
      await tap(tester, 'Import 1 task');
      expect(find.text('1 task added'), findsOneWidget);
      final imported = await tester.runAsync(
        () => env.db.select(env.db.items).get(),
      );
      expect(imported!.single.title, 'Buy milk');
      await tap(tester, 'Undo import');
      expect(find.text('Import undone'), findsOneWidget);
      expect(
        await tester.runAsync(() => env.db.select(env.db.items).get()),
        isEmpty,
      );
      expect(gateway.reminders, hasLength(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('denied permission explains recovery and permits retry', (
    tester,
  ) async {
    gateway.error = const AppleRemindersException(AppleRemindersFailure.denied);
    await pump(tester);
    await tap(tester, 'Choose lists');
    expect(find.textContaining('Reminders access is off.'), findsOneWidget);
    expect(
      await tester.runAsync(() => env.db.select(env.db.items).get()),
      isEmpty,
    );
    gateway.error = null;
    await tap(tester, 'Choose lists');
    expect(find.text('Home'), findsOneWidget);
    expect(gateway.requests, 2);
  });

  testWidgets(
    'empty lists, empty tasks and stale lists have recoverable states',
    (tester) async {
      gateway.lists = [];
      await pump(tester);
      await tap(tester, 'Choose lists');
      expect(
        find.text('No reminder lists are available on this device.'),
        findsOneWidget,
      );
      gateway.lists = const [AppleRemindersList(id: 'home', title: 'Home')];
      await tap(tester, 'Reload lists');
      await tap(tester, 'Home');
      await tap(tester, 'Preview');
      expect(find.text('No open tasks found to import.'), findsOneWidget);
      gateway.error = const AppleRemindersException(
        AppleRemindersFailure.listsChanged,
      );
      await tap(tester, 'Preview');
      expect(
        find.textContaining('A selected list is no longer available.'),
        findsOneWidget,
      );
      expect(
        await tester.runAsync(() => env.db.select(env.db.items).get()),
        isEmpty,
      );
    },
  );

  testWidgets('selection and preview fit a compact phone at 3x text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    gateway.reminders = const [
      AppleReminder(id: 'a', listId: 'home', title: 'Call Mum'),
    ];
    await pump(tester, scale: 3);
    await tap(tester, 'Choose lists');
    await tap(tester, 'Home');
    await tap(tester, 'Preview');
    final container = importContainer(tester);
    expect(
      container.read(appImportControllerProvider).step,
      AppImportStep.preview,
    );
    await tester.scrollUntilVisible(
      find.text('1 task'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1 task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unsupported platforms hide the native source and never request access',
    (tester) async {
      gateway.supported = false;
      await pump(tester, open: false);
      final container = importContainer(tester);
      expect(
        container
            .read(appImportSourcesProvider)
            .any((source) => source.name == 'appleReminders'),
        isFalse,
      );
      expect(find.text('Apple Reminders'), findsNothing);
      expect(gateway.requests, 0);
    },
  );

  test(
    'parallel taps and disposal during permission request do not publish stale state',
    () async {
      final pending = Completer<List<AppleRemindersList>>();
      gateway.onRequest = () => pending.future;
      final container = env.container([
        appleRemindersGatewayProvider.overrideWithValue(gateway),
      ]);
      final listener = container.listen(appImportControllerProvider, (_, _) {});
      final controller = container.read(appImportControllerProvider.notifier);
      final first = controller.loadAppleLists();
      await controller.loadAppleLists();
      expect(gateway.requests, 1);
      listener.close();
      container.dispose();
      pending.complete(gateway.lists);
      await first;
    },
  );
  test(
    'a pending file picker blocks competing file, paste and native imports; cancellation restores sources',
    () async {
      final pending = Completer<PickedImportFile?>();
      var picks = 0;
      final container = env.container([
        appleRemindersGatewayProvider.overrideWithValue(gateway),
        pickImportFileProvider.overrideWithValue(() {
          picks++;
          return pending.future;
        }),
      ]);
      final listener = container.listen(appImportControllerProvider, (_, _) {});
      addTearDown(listener.close);
      final controller = container.read(appImportControllerProvider.notifier);
      final picking = controller.chooseFile(ImportSourceApp.todoist);
      expect(container.read(appImportControllerProvider).busy, isTrue);
      await controller.chooseFile(ImportSourceApp.tickTick);
      await controller.loadAppleLists();
      await controller.pasteText(ImportSourceApp.plainText, 'Must not import');
      expect(picks, 1);
      expect(gateway.requests, 0);
      pending.complete(null);
      await picking;
      expect(
        container.read(appImportControllerProvider).step,
        AppImportStep.sources,
      );
      expect(await env.db.select(env.db.items).get(), isEmpty);
    },
  );

  test(
    'picker failures produce a recoverable error instead of escaping the event handler',
    () async {
      final container = env.container([
        pickImportFileProvider.overrideWithValue(
          () async => throw StateError('Picker failed'),
        ),
      ]);
      final listener = container.listen(appImportControllerProvider, (_, _) {});
      addTearDown(listener.close);
      await container
          .read(appImportControllerProvider.notifier)
          .chooseFile(ImportSourceApp.todoist);
      final state = container.read(appImportControllerProvider);
      expect(state.step, AppImportStep.sources);
      expect(state.error, AppImportError.unreadable);
    },
  );

  test(
    'a file-picker result after disposal is ignored without touching the database',
    () async {
      final pending = Completer<PickedImportFile?>();
      final container = env.container([
        pickImportFileProvider.overrideWithValue(() => pending.future),
      ]);
      final listener = container.listen(appImportControllerProvider, (_, _) {});
      final picking = container
          .read(appImportControllerProvider.notifier)
          .chooseFile(ImportSourceApp.plainText);
      listener.close();
      container.dispose();
      pending.complete((name: 'tasks.txt', bytes: 'Do not import'.codeUnits));
      await picking;
      expect(await env.db.select(env.db.items).get(), isEmpty);
    },
  );
}
