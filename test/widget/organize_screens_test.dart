import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/areas/areas_screen.dart';
import 'package:cleartray/features/contexts/contexts_screen.dart';
import 'package:cleartray/features/settings/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Contexts and Areas share one edit pattern with Tags: tap a row to edit,
/// Delete lives in the editor and asks for confirmation.
void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });
  tearDown(() => env.dispose());

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Finder dialogDelete() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text('Delete'),
  );

  testWidgets('contexts: rows sit in a SettingsGroup; delete is confirmed', (
    tester,
  ) async {
    final repo = ContextRepository(env.db);
    await repo.upsert(
      const GtdContext(id: 'c', name: '@home', icon: 'home', color: 0xFF1E88E5),
    );
    await pumpApp(tester, const ContextsScreen(), env: env);
    await settle(tester);

    expect(find.byType(SettingsGroup), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);

    await tester.tap(find.text('@home'));
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    // Confirmation dialog first; nothing is deleted yet.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect((await tester.runAsync(() => repo.watchAll().first))!, hasLength(1));

    await tester.tap(dialogDelete());
    await settle(tester);
    expect((await tester.runAsync(() => repo.watchAll().first))!, isEmpty);
  });

  testWidgets('areas: tap edits in a sheet with Delete, confirmed', (
    tester,
  ) async {
    final repo = AreaRepository(env.db);
    await repo.upsert(const Area(id: 'a', name: 'Health'));
    await pumpApp(tester, const AreasScreen(), env: env);
    await settle(tester);

    expect(find.byType(SettingsGroup), findsOneWidget);
    await tester.tap(find.text('Health'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Fitness');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(
      ((await tester.runAsync(() => repo.watchAll().first))!).single.name,
      'Fitness',
    );

    await tester.tap(find.text('Fitness'));
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(dialogDelete());
    await settle(tester);
    expect((await tester.runAsync(() => repo.watchAll().first))!, isEmpty);
  });
}
