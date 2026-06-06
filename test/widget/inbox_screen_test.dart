import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/settings/settings_controller.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _wrap({
  required AppDatabase db,
  required SharedPreferences prefs,
  required Clock clock,
  required IdGenerator ids,
}) async {
  return UncontrolledProviderScope(
    container: ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock),
        idGeneratorProvider.overrideWithValue(ids),
      ],
    ),
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const InboxScreen(),
    ),
  );
}

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;
  late Clock clock;
  late IdGenerator ids;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = await SharedPreferences.getInstance();
    clock = FakeClock(DateTime(2026, 5, 14));
    ids = FixedIdGenerator();
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows empty-state when inbox is empty', (tester) async {
    await tester
        .pumpWidget(await _wrap(db: db, prefs: prefs, clock: clock, ids: ids));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Inbox zero'), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
  });

  testWidgets('shows captured items', (tester) async {
    final repo = ItemRepository(db, clock);
    final now = DateTime(2026, 5, 14);
    await repo.upsert(Item(
      id: 'a',
      title: 'Sample inbox item',
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    ));
    await tester
        .pumpWidget(await _wrap(db: db, prefs: prefs, clock: clock, ids: ids));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Sample inbox item'), findsOneWidget);
    expect(find.textContaining('Process inbox'), findsOneWidget);
  });
}
