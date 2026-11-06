import 'dart:async';
import 'dart:io';

import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/features/app_import/app_import_controller.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/process/process_inbox_controller.dart';
import 'package:cleartray/features/app_import/app_import_screen.dart';
import 'package:cleartray/features/app_import/app_import_source_screen.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/features/capture/capture_sheet.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/process/process_inbox_screen.dart';
import 'package:cleartray/features/projects/projects_screen.dart';
import 'package:cleartray/features/projects/project_detail_screen.dart';
import 'package:cleartray/features/review/review_screen.dart';
import 'package:cleartray/features/review/weekly_review_screen.dart';
import 'package:cleartray/features/settings/backup_screen.dart';
import 'package:cleartray/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/harness.dart';
import '../support/import_flow.dart';

// Synthetic Flutter window sizes, not Duo hardware/runtime certification.
const sizes = [
  Size(466, 678),
  Size(678, 466),
  Size(669, 951),
  Size(951, 669),
  Size(320, 480),
  Size(466, 678),
];

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  Future<void> resize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'window $size');
  }

  final screens = <String, Widget>{
    'Inbox': const InboxScreen(),
    'Do': const EngageScreen(),
    'Projects': const ProjectsScreen(),
    'Review': const ReviewScreen(),
    'Process': const ProcessInboxScreen(),
    'Edit': const ItemEditScreen(itemId: 'a'),
    'Imports': const AppImportScreen(),
    'Import source': const AppImportSourceScreen(
      source: ImportSourceApp.todoist,
    ),
    'Backups': const BackupScreen(),
  };

  for (final screen in [
    'Edit',
    'Backup',
    'Project',
    'Weekly Review',
    'Search',
  ]) {
    testWidgets('$screen honors changing asymmetric side insets', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await tester.binding.setSurfaceSize(sizes.first);
      await ItemRepository(env.db, env.clock).upsert(anItem(id: 'a'));
      await ProjectRepository(env.db).upsert(
        Project(
          id: 'p',
          title: 'A project',
          status: ProjectStatus.active,
          createdAt: env.clock.now(),
          updatedAt: env.clock.now(),
        ),
      );
      await pumpApp(tester, switch (screen) {
        'Edit' => const ItemEditScreen(itemId: 'a'),
        'Backup' => const BackupScreen(),
        'Project' => const ProjectDetailScreen(projectId: 'p'),
        'Search' => const SearchScreen(),
        _ => const WeeklyReviewScreen(),
      }, env: env);
      await tester.pumpAndSettle();
      for (final left in [false, true, false]) {
        final insets = FakeViewPadding(
          left: left ? 84 : 0,
          right: left ? 0 : 84,
        );
        tester.view.padding = insets;
        tester.view.viewPadding = insets;
        await tester.pumpAndSettle();
        final control = screen == 'Backup'
            ? find.byKey(const ValueKey('automatic_folder_backup'))
            : screen == 'Search'
            ? find.widgetWithText(FilterChip, 'All projects')
            : find.byType(TextField).first;
        if (screen == 'Search') {
          await tester.scrollUntilVisible(
            control,
            150,
            scrollable: find.descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            ),
          );
        }
        await tester.ensureVisible(control);
        await tester.pumpAndSettle();
        final rect = tester.getRect(control);
        expect(rect.left, greaterThanOrEqualTo(insets.left));
        expect(rect.right, lessThanOrEqualTo(sizes.first.width - insets.right));
        expect(tester.takeException(), isNull);
      }
    });
  }

  for (final scale in [1.0, 2.0, 3.0]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} resizes at ${scale}x text', (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(sizes.first);
        await ItemRepository(env.db, env.clock).upsert(
          anItem(
            id: 'a',
            title: 'Prepare a proposal',
            notes: 'Keep these notes',
          ),
        );
        await pumpApp(
          tester,
          entry.value,
          env: env,
          textScaler: TextScaler.linear(scale),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final state = entry.value is StatefulWidget
            ? tester.state(find.byType(entry.value.runtimeType))
            : null;
        for (final size in sizes) {
          await resize(tester, size);
          if (state != null) {
            expect(
              tester.state(find.byType(entry.value.runtimeType)),
              same(state),
            );
          }
        }
      });
    }
  }

  testWidgets('Process retains the current step and choices through resizing', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await ItemRepository(env.db, env.clock).upsert(anItem(id: 'a'));
    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProcessInboxScreen)),
    );
    final controller = container.read(processInboxControllerProvider.notifier);
    for (var i = 0; i < 5; i++) {
      controller.advance();
    }
    controller.setEnergy(Energy.low);
    controller.setTimeEstimate(15);
    await tester.pumpAndSettle();
    final draft = container.read(processInboxControllerProvider);
    for (final size in sizes) {
      await resize(tester, size);
      expect(container.read(processInboxControllerProvider), same(draft));
      expect(
        container.read(processInboxControllerProvider).step,
        ProcessStep.detail,
      );
    }
    expect(
      (await ItemRepository(env.db, env.clock).getById('a'))!.status,
      ItemStatus.inbox,
    );
  });

  testWidgets('route capture opens once across parent rebuilds and resizes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ValueListenableBuilder<int>(
                  valueListenable: rebuild,
                  builder: (_, value, _) =>
                      // Force a new widget instance to reproduce parent rebuilds.
                      // ignore: prefer_const_constructors
                      CaptureScreen(initialText: 'Shared idea'),
                ),
              ),
            ),
            child: const Text('Open route capture'),
          ),
        ),
      ),
      env: env,
    );
    await tester.tap(find.text('Open route capture'));
    await tester.pumpAndSettle();
    final title = tester
        .widget<TextField>(find.byType(TextField).first)
        .controller!;
    title.value = const TextEditingValue(
      text: 'Preserve this draft',
      selection: TextSelection(baseOffset: 2, extentOffset: 8),
    );
    for (final size in sizes) {
      rebuild.value++;
      tester.view.viewInsets = FakeViewPadding(
        bottom: size.height < 600 ? 180 : 280,
      );
      await resize(tester, size);
      expect(find.byType(CaptureSheet, skipOffstage: false), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller,
        same(title),
      );
      expect(title.text, 'Preserve this draft');
      expect(
        title.selection,
        const TextSelection(baseOffset: 2, extentOffset: 8),
      );
    }
    await tester.ensureVisible(find.text('Add to inbox'));
    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect(find.text('Open route capture'), findsOneWidget);
    expect(
      (await ItemRepository(env.db, env.clock).allActive()).single.title,
      'Preserve this draft',
    );
  });

  testWidgets('Inbox selection controls fit while resizing at 3x text', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(sizes.first);
    await ItemRepository(
      env.db,
      env.clock,
    ).upsert(anItem(id: 'a', title: 'Select this task'));
    await pumpApp(
      tester,
      const InboxScreen(),
      env: env,
      textScaler: const TextScaler.linear(3),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Select this task'), 200);
    await tester.longPress(find.text('Select this task'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final size in sizes) {
      await resize(tester, size);
    }
    await tester.ensureVisible(find.text('Next action'));
    await tester.pumpAndSettle();
    expect(find.text('Next action').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Next action'));
    await tester.pumpAndSettle();
    expect(
      (await ItemRepository(env.db, env.clock).getById('a'))!.status,
      ItemStatus.nextAction,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor preserves focused draft and selection while resizing', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(anItem(id: 'a', title: 'Old title'));
    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pumpAndSettle();
    final field = find.widgetWithText(TextField, 'Old title');
    final controller = tester.widget<TextField>(field).controller!;
    await tester.enterText(field, 'Edited through resize');
    controller.selection = const TextSelection(baseOffset: 2, extentOffset: 9);
    final state = tester.state(find.byType(ItemEditScreen));
    for (final size in sizes) {
      tester.view.viewInsets = FakeViewPadding(
        bottom: size.height < 600 ? 180 : 280,
      );
      await resize(tester, size);
      expect(tester.state(find.byType(ItemEditScreen)), same(state));
      expect(controller.text, 'Edited through resize');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 2, extentOffset: 9),
      );
      expect(
        tester
            .widget<TextField>(
              find.widgetWithText(TextField, 'Edited through resize'),
            )
            .focusNode!
            .hasFocus,
        isTrue,
      );
    }
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.title, 'Edited through resize');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('all navigation destinations remain selected through resizing', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    ReceiveSharingIntent.setMockValues(
      initialMedia: [],
      mediaStream: const Stream.empty(),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Trayzero',
      packageName: 'app.cleartray',
      version: '1.0.8',
      buildNumber: '52',
      buildSignature: '',
    );
    await env.prefs.setBool('onboarding_complete_v1', true);
    final container = env.container();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TrayzeroApp(),
      ),
    );
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    for (var index = 0; index < navTabs.length; index++) {
      await resize(
        tester,
        index.isEven ? const Size(669, 951) : const Size(466, 678),
      );
      final railFinder = find.byType(NavigationRail);
      if (railFinder.evaluate().isNotEmpty) {
        final rail = tester.widget<NavigationRail>(railFinder);
        final icon = rail.selectedIndex == index
            ? navTabs[index].filled
            : navTabs[index].icon;
        await tester.tap(
          find.descendant(of: railFinder, matching: find.byIcon(icon)),
        );
      } else {
        await tester.tap(
          find
              .descendant(
                of: find.byType(NavigationBar),
                matching: find.byType(NavigationDestination),
              )
              .at(index),
        );
      }
      await tester.pumpAndSettle();
      for (final size in sizes) {
        await resize(tester, size);
        expect(
          router.routeInformationProvider.value.uri.path,
          navTabs[index].path,
        );
        final rail = find.byType(NavigationRail);
        final selected = rail.evaluate().isNotEmpty
            ? tester.widget<NavigationRail>(rail).selectedIndex
            : tester
                  .widget<NavigationBar>(find.byType(NavigationBar))
                  .selectedIndex;
        expect(selected, index);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'pending import and preview survive resize, then import and Undo',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pick = Completer<PickedImportFile?>();
      await pumpImportFlow(
        tester,
        env: env,
        extraOverrides: [
          pickImportFileProvider.overrideWithValue(() => pick.future),
        ],
      );
      await openSource(tester, 'Todoist');
      await tester.tap(find.text('Choose file'));
      await tester.pump();
      final container = importContainer(tester);
      final controller = container.read(appImportControllerProvider.notifier);
      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        // The pending file read deliberately keeps its progress spinner active.
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(
          container.read(appImportControllerProvider.notifier),
          same(controller),
        );
        expect(
          container.read(appImportControllerProvider).step,
          AppImportStep.reading,
        );
      }
      pick.complete((
        name: 'todoist_official_template.csv',
        bytes: File(
          'test/fixtures/import/todoist_official_template.csv',
        ).readAsBytesSync(),
      ));
      Future<void> settleImport() async {
        for (var i = 0; i < 500; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
          if (!container.read(appImportControllerProvider).busy) break;
        }
        await tester.pumpAndSettle();
        expect(container.read(appImportControllerProvider).busy, isFalse);
      }

      await settleImport();
      final preview = container.read(appImportControllerProvider).preview;
      expect(preview, isNotNull);
      for (final size in sizes) {
        await resize(tester, size);
        expect(
          container.read(appImportControllerProvider).preview,
          same(preview),
        );
        expect(find.text('Review import'), findsOneWidget);
      }
      await tester.ensureVisible(find.textContaining('Import 4'));
      await tester.tap(find.textContaining('Import 4'));
      await settleImport();
      expect(find.text('4 tasks added'), findsOneWidget);
      await tester.tap(find.text('Undo import'));
      await settleImport();
      expect(find.text('Import undone'), findsOneWidget);
      expect(
        (await tester.runAsync(() => env.db.select(env.db.items).get()))!,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
