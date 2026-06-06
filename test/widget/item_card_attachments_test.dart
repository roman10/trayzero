import 'package:cleartray/application/providers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });

  tearDown(() => env.dispose());

  testWidgets('shows per-kind attachment chips when an item has media',
      (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: ItemCard(item: anItem(id: 'i1', title: 'Has media'))),
      env: env,
      extraOverrides: [
        attachmentSummariesProvider.overrideWith(
          (ref) => Stream.value(const {
            'i1': AttachmentSummary(images: 2, audio: 1),
          }),
        ),
      ],
    );
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });

  testWidgets('shows no attachment chips for an item without media',
      (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: ItemCard(item: anItem(id: 'i2', title: 'No media'))),
      env: env,
      extraOverrides: [
        attachmentSummariesProvider.overrideWith(
          (ref) => Stream.value(const <String, AttachmentSummary>{}),
        ),
      ],
    );
    await tester.pump();

    expect(find.byIcon(Icons.image_outlined), findsNothing);
    expect(find.byIcon(Icons.mic_none), findsNothing);
    expect(find.byIcon(Icons.attach_file), findsNothing);
  });
}
