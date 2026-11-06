import 'dart:async';

import 'package:cleartray/application/providers.dart';
import 'package:cleartray/application/read_microsoft_todo_import.dart';
import 'package:cleartray/core/microsoft_todo_gateway.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/app_import/app_import_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';
import '../support/microsoft_todo_fake.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create(now: DateTime(2026, 11, 3, 10)));
  tearDown(() => env.dispose());

  test(
    'read and preview write nothing; confirm merges names, maps dates and Undo preserves existing rows',
    () async {
      final gateway = FakeMicrosoftTodoGateway();
      final container = env.container([
        microsoftTodoGatewayProvider.overrideWithValue(gateway),
      ]);
      final projects = container.read(projectRepositoryProvider);
      final contexts = container.read(contextRepositoryProvider);
      final existing = Project(
        id: 'existing-project',
        title: ' garage ',
        status: ProjectStatus.active,
        createdAt: env.clock.now(),
        updatedAt: env.clock.now(),
      );
      await projects.upsert(existing);
      await contexts.upsert(
        const GtdContext(
          id: 'existing-context',
          name: '@Home',
          icon: 'home',
          color: 0,
        ),
      );
      final capture = container.read(captureItemProvider);
      final original = await capture(title: 'Keep me');
      final read = container.read(readMicrosoftTodoImportProvider);
      final plan = await read(isCancelled: () => false);
      final importer = container.read(importFromAppProvider);
      final preview = await importer.preview(plan);
      expect(preview.total, 5);
      expect(preview.byStatus[ItemStatus.calendar], 1);
      expect(preview.projects.single.isNew, isFalse);
      expect(await env.db.select(env.db.items).get(), hasLength(1));
      final receipt = await importer(plan);
      expect(receipt.itemIds, hasLength(5));
      expect(receipt.projectIds, isEmpty);
      final paint = await (env.db.select(
        env.db.items,
      )..where((t) => t.title.equals('Paint shelves'))).getSingle();
      expect(paint.status, ItemStatus.calendar);
      expect(paint.projectId, 'existing-project');
      expect(paint.contextId, 'existing-context');
      expect(paint.dueAt, DateTime(2026, 11, 6, 9));
      expect(paint.deferUntil, DateTime(2026, 11, 4));
      expect(env.scheduler.scheduled, isNotEmpty);
      await importer.undo(receipt);
      final remaining = await env.db.select(env.db.items).get();
      expect(remaining.single.id, original.id);
      expect((await projects.watchAll().first).single.id, 'existing-project');
      expect((await contexts.all()).single.id, 'existing-context');
      expect(await container.read(tagRepositoryProvider).all(), isEmpty);
    },
  );

  test(
    'database failure rolls back all imported items and newly created organization',
    () async {
      final container = env.container([
        microsoftTodoGatewayProvider.overrideWithValue(
          FakeMicrosoftTodoGateway(),
        ),
      ]);
      await env.db.customStatement(
        "CREATE TRIGGER reject_import BEFORE INSERT ON items WHEN NEW.title = 'Buy brushes' BEGIN SELECT RAISE(ABORT, 'test write failure'); END",
      );
      final plan = await container.read(readMicrosoftTodoImportProvider)(
        isCancelled: () => false,
      );
      await expectLater(
        container.read(importFromAppProvider)(plan),
        throwsA(anything),
      );
      expect(await env.db.select(env.db.items).get(), isEmpty);
      expect(await env.db.select(env.db.projects).get(), isEmpty);
      expect(await env.db.select(env.db.contexts).get(), isEmpty);
      expect(await env.db.select(env.db.tags).get(), isEmpty);
      expect(env.scheduler.scheduled, isEmpty);
    },
  );

  test(
    'cancelled reads cannot publish a preview or write even if the gateway finishes late',
    () async {
      final pending = Completer<List<Map<String, Object?>>>();
      bool Function()? cancelled;
      final gateway = FakeMicrosoftTodoGateway(
        onRead: (check) {
          cancelled = check;
          return pending.future;
        },
      );
      final container = env.container([
        microsoftTodoGatewayProvider.overrideWithValue(gateway),
      ]);
      final keep = container.listen(appImportControllerProvider, (_, _) {});
      addTearDown(keep.close);
      final controller = container.read(appImportControllerProvider.notifier);
      final future = controller.connectMicrosoftTodo();
      expect(
        container.read(appImportControllerProvider).step,
        AppImportStep.reading,
      );
      controller.cancelMicrosoftRead();
      expect(cancelled!(), isTrue);
      pending.complete(microsoftTodoSnapshot());
      await future;
      expect(
        container.read(appImportControllerProvider).step,
        AppImportStep.sources,
      );
      expect(await env.db.select(env.db.items).get(), isEmpty);
    },
  );

  test(
    'provider disposal discards an authentication response arriving after navigation',
    () async {
      final pending = Completer<List<Map<String, Object?>>>();
      final container = env.container([
        microsoftTodoGatewayProvider.overrideWithValue(
          FakeMicrosoftTodoGateway(onRead: (_) => pending.future),
        ),
      ]);
      final keep = container.listen(appImportControllerProvider, (_, _) {});
      final future = container
          .read(appImportControllerProvider.notifier)
          .connectMicrosoftTodo();
      keep.close();
      await container.pump();
      pending.complete(microsoftTodoSnapshot());
      await future;
      expect(await env.db.select(env.db.items).get(), isEmpty);
    },
  );

  test(
    'concurrent connect taps start a single read; retry works after failure',
    () async {
      final pending = Completer<List<Map<String, Object?>>>();
      final gateway = FakeMicrosoftTodoGateway(onRead: (_) => pending.future);
      final container = env.container([
        microsoftTodoGatewayProvider.overrideWithValue(gateway),
      ]);
      final keep = container.listen(appImportControllerProvider, (_, _) {});
      addTearDown(keep.close);
      final controller = container.read(appImportControllerProvider.notifier);
      final first = controller.connectMicrosoftTodo();
      await controller.connectMicrosoftTodo();
      expect(gateway.reads, 1);
      pending.completeError(
        const MicrosoftTodoException(MicrosoftTodoFailure.network),
      );
      await first;
      expect(
        container.read(appImportControllerProvider).error,
        AppImportError.microsoftNetwork,
      );
      await controller.connectMicrosoftTodo();
      expect(gateway.reads, 2);
      expect(await env.db.select(env.db.items).get(), isEmpty);
    },
  );

  for (final entry in {
    MicrosoftTodoFailure.signIn: AppImportError.microsoftSignIn,
    MicrosoftTodoFailure.permission: AppImportError.microsoftPermission,
    MicrosoftTodoFailure.network: AppImportError.microsoftNetwork,
    MicrosoftTodoFailure.unavailable: AppImportError.microsoftUnavailable,
  }.entries) {
    test(
      '${entry.key} leaves local data untouched and offers a source-level error',
      () async {
        final container = env.container([
          microsoftTodoGatewayProvider.overrideWithValue(
            FakeMicrosoftTodoGateway(
              onRead: (_) async => throw MicrosoftTodoException(entry.key),
            ),
          ),
        ]);
        final keep = container.listen(appImportControllerProvider, (_, _) {});
        addTearDown(keep.close);
        await container
            .read(appImportControllerProvider.notifier)
            .connectMicrosoftTodo();
        expect(container.read(appImportControllerProvider).error, entry.value);
        expect(
          container.read(appImportControllerProvider).step,
          AppImportStep.sources,
        );
        expect(await env.db.select(env.db.items).get(), isEmpty);
      },
    );
  }

  test(
    'closing the sign-in browser returns to sources without an error',
    () async {
      final container = env.container([
        microsoftTodoGatewayProvider.overrideWithValue(
          FakeMicrosoftTodoGateway(
            onRead: (_) async => throw const MicrosoftTodoException(
              MicrosoftTodoFailure.cancelled,
            ),
          ),
        ),
      ]);
      final keep = container.listen(appImportControllerProvider, (_, _) {});
      addTearDown(keep.close);
      await container
          .read(appImportControllerProvider.notifier)
          .connectMicrosoftTodo();
      final state = container.read(appImportControllerProvider);
      expect(state.step, AppImportStep.sources);
      expect(state.error, isNull);
    },
  );
}
