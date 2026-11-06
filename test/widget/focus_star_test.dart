import 'dart:ui' show SemanticsAction, SemanticsActionEvent, Tristate;

import 'package:cleartray/features/common/focus_star.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late int toggles;

  setUp(() async {
    env = await TestEnv.create();
    toggles = 0;
  });
  tearDown(() => env.dispose());

  Future<void> pumpStar(WidgetTester tester, {bool focused = false}) => pumpApp(
    tester,
    Scaffold(
      body: Center(
        child: FocusStar(
          title: 'Pay rent',
          focused: focused,
          onToggle: () => toggles++,
        ),
      ),
    ),
    env: env,
  );

  List<Object?> recordHaptics(WidgetTester tester) {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return haptics;
  }

  for (final focused in [false, true]) {
    for (final hapticsEnabled in [false, true]) {
      testWidgets(
        'accessibility toggles focused=$focused with haptics=$hapticsEnabled',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            final haptics = recordHaptics(tester);
            await env.prefs.setBool('haptics_enabled', hapticsEnabled);
            await pumpStar(tester, focused: focused);

            final label = focused
                ? 'Remove Pay rent from Today'
                : 'Add Pay rent to Today';
            final finder = find.bySemanticsLabel(label);
            expect(finder, findsOneWidget);
            final node = tester.getSemantics(finder);
            final data = node.getSemanticsData();
            expect(data.hasAction(SemanticsAction.tap), isTrue);
            expect(data.flagsCollection.isButton, isTrue);
            expect(data.flagsCollection.isEnabled, Tristate.isTrue);
            expect(
              data.flagsCollection.isToggled,
              focused ? Tristate.isTrue : Tristate.isFalse,
            );

            tester.binding.performSemanticsAction(
              SemanticsActionEvent(
                nodeId: node.id,
                viewId: tester.view.viewId,
                type: SemanticsAction.tap,
              ),
            );
            await tester.pump();

            expect(toggles, 1);
            expect(
              haptics,
              hapticsEnabled ? ['HapticFeedbackType.selectionClick'] : isEmpty,
            );
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }

  testWidgets('touch toggles once across the full 48dp target', (tester) async {
    final haptics = recordHaptics(tester);
    await pumpStar(tester);
    expect(
      tester.getSize(find.byType(FocusStar)),
      const Size.square(FocusStar.targetSize),
    );

    await tester.tapAt(
      tester.getCenter(find.byType(FocusStar)) + const Offset(20, 20),
    );
    await tester.pumpAndSettle();

    expect(toggles, 1);
    expect(haptics, ['HapticFeedbackType.selectionClick']);
  });
}
