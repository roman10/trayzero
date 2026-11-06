import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/review/review_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  testWidgets('renders all buckets empty with the weekly-review card',
      (tester) async {
    await pumpApp(tester, const ReviewScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Weekly review'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Waiting for'), findsOneWidget);
    expect(find.text('Someday / Maybe'), findsOneWidget);
    expect(find.text('Reference'), findsOneWidget);
    expect(find.text('Completed this week'), findsOneWidget);
    // Every bucket shows a "0 items" subtitle.
    expect(find.text('0 items'), findsNWidgets(5));
  });

  testWidgets('counts items per bucket', (tester) async {
    await items.upsert(anItem(
      id: 'w1',
      title: 'Awaiting reply',
      status: ItemStatus.waiting,
    ));
    await items.upsert(anItem(
      id: 's1',
      title: 'Learn sailing',
      status: ItemStatus.someday,
    ));
    await items.upsert(anItem(
      id: 's2',
      title: 'Visit Japan',
      status: ItemStatus.someday,
    ));

    await pumpApp(tester, const ReviewScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1 item'), findsOneWidget); // waiting
    expect(find.text('2 items'), findsOneWidget); // someday
  });

  testWidgets('expanding a bucket reveals its items', (tester) async {
    await items.upsert(anItem(
      id: 'w1',
      title: 'Awaiting Sara reply',
      status: ItemStatus.waiting,
    ));

    await pumpApp(tester, const ReviewScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Awaiting Sara reply'), findsNothing);

    await tester.tap(find.text('Waiting for'));
    await tester.pumpAndSettle();

    expect(find.text('Awaiting Sara reply'), findsOneWidget);
  });
}
