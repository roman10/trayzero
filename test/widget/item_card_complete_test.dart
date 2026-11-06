import 'package:cleartray/features/common/complete_circle.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late int opened;
  late int completed;

  setUp(() async {
    env = await TestEnv.create();
    opened = 0;
    completed = 0;
  });

  tearDown(() => env.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    bool withComplete = true,
    bool selectionMode = false,
  }) => pumpApp(
    tester,
    Scaffold(
      body: ItemCard(
        item: anItem(id: 'i1', title: 'Pay rent'),
        onTap: () => opened++,
        onComplete: withComplete ? () => completed++ : null,
        selectionMode: selectionMode,
      ),
    ),
    env: env,
  );

  testWidgets('a tap on the ring completes without opening the item', (
    tester,
  ) async {
    await pumpCard(tester);

    await tester.tap(find.byType(CompleteCircle));
    await tester.pump(CompleteCircle.feedbackDuration);

    expect(completed, 1);
    expect(opened, 0);
  });

  testWidgets('a tap beside the ring, inside its touch target, completes', (
    tester,
  ) async {
    await pumpCard(tester);
    final center = tester.getCenter(find.byType(CompleteCircle));

    // Just right of the 24dp ring, where the old 22dp control let taps fall
    // through to the card and open the item.
    await tester.tapAt(center + const Offset(18, 0));
    await tester.pump(CompleteCircle.feedbackDuration);

    expect(completed, 1);
    expect(opened, 0);
  });

  testWidgets('a tap on the title opens the item without completing', (
    tester,
  ) async {
    await pumpCard(tester);

    await tester.tap(find.text('Pay rent'));
    await tester.pump(CompleteCircle.feedbackDuration);

    expect(opened, 1);
    expect(completed, 0);
  });

  testWidgets('has no completion circle when the card cannot be completed', (
    tester,
  ) async {
    await pumpCard(tester, withComplete: false);

    expect(find.byType(CompleteCircle), findsNothing);
  });

  testWidgets('has no completion circle in selection mode', (tester) async {
    await pumpCard(tester, selectionMode: true);

    expect(find.byType(CompleteCircle), findsNothing);
  });
}
