import 'package:cleartray/features/common/complete_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late int completed;

  setUp(() async {
    env = await TestEnv.create();
    completed = 0;
  });

  tearDown(() => env.dispose());

  Future<void> pumpCircle(WidgetTester tester) => pumpApp(
    tester,
    Scaffold(
      body: Center(
        child: CompleteCircle(title: 'Pay rent', onComplete: () => completed++),
      ),
    ),
    env: env,
  );

  /// Records the haptic feedback types requested through the platform channel.
  List<Object?> recordHaptics(WidgetTester tester) {
    final types = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') types.add(call.arguments);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return types;
  }

  group('touch target', () {
    testWidgets('is 48dp square around the smaller visible ring', (
      tester,
    ) async {
      await pumpCircle(tester);

      expect(
        tester.getSize(find.byType(CompleteCircle)),
        const Size.square(CompleteCircle.targetSize),
      );
      expect(
        tester.getSize(find.byType(AnimatedContainer)),
        const Size.square(CompleteCircle.diameter),
      );
    });

    testWidgets('completes on a tap in the target but outside the ring', (
      tester,
    ) async {
      await pumpCircle(tester);
      final center = tester.getCenter(find.byType(CompleteCircle));

      // Near the target's corner: outside the 24dp ring, inside the 48dp box.
      await tester.tapAt(center + const Offset(20, 20));
      await tester.pump(CompleteCircle.feedbackDuration);

      expect(completed, 1);
    });

    testWidgets('ignores a tap just outside the target', (tester) async {
      await pumpCircle(tester);
      final center = tester.getCenter(find.byType(CompleteCircle));

      await tester.tapAt(center + const Offset(CompleteCircle.targetSize, 0));
      await tester.pump(CompleteCircle.feedbackDuration);

      expect(completed, 0);
    });

    testWidgets('exposes a labelled button to accessibility', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCircle(tester);

      expect(find.bySemanticsLabel('Mark Pay rent done'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('completion feedback', () {
    testWidgets('fills the ring with a check as soon as it is tapped', (
      tester,
    ) async {
      await pumpCircle(tester);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.byType(CompleteCircle));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.pump(CompleteCircle.feedbackDuration); // drain the timer
    });

    testWidgets('completes only after the feedback has played', (tester) async {
      await pumpCircle(tester);

      await tester.tap(find.byType(CompleteCircle));
      await tester.pump(
        CompleteCircle.feedbackDuration - const Duration(milliseconds: 1),
      );
      expect(completed, 0);

      await tester.pump(const Duration(milliseconds: 1));
      expect(completed, 1);
    });

    testWidgets('completes once even when tapped repeatedly', (tester) async {
      await pumpCircle(tester);

      await tester.tap(find.byType(CompleteCircle));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(CompleteCircle));
      await tester.pump(CompleteCircle.feedbackDuration);

      expect(completed, 1);
    });

    testWidgets('still completes if the card is removed mid-feedback', (
      tester,
    ) async {
      await pumpCircle(tester);

      await tester.tap(find.byType(CompleteCircle));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(CompleteCircle.feedbackDuration);

      expect(completed, 1);
    });
  });

  group('haptics', () {
    testWidgets('clicks when haptics are enabled', (tester) async {
      final haptics = recordHaptics(tester);
      await pumpCircle(tester);

      await tester.tap(find.byType(CompleteCircle));
      await tester.pump(CompleteCircle.feedbackDuration);

      expect(haptics, ['HapticFeedbackType.selectionClick']);
    });

    testWidgets('stays silent when haptics are disabled in settings', (
      tester,
    ) async {
      final haptics = recordHaptics(tester);
      await env.prefs.setBool('haptics_enabled', false);
      await pumpCircle(tester);

      await tester.tap(find.byType(CompleteCircle));
      await tester.pump(CompleteCircle.feedbackDuration);

      expect(haptics, isEmpty);
      expect(completed, 1);
    });
  });
}
