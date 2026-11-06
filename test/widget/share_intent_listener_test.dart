import 'dart:async';

import 'package:cleartray/application/providers.dart';
import 'package:cleartray/features/capture/share_intent_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/harness.dart';

class _Sharing extends ReceiveSharingIntent {
  final initial = Completer<List<SharedMediaFile>>();
  final events = StreamController<List<SharedMediaFile>>.broadcast();
  @override
  Future<List<SharedMediaFile>> getInitialMedia() => initial.future;
  @override
  Stream<List<SharedMediaFile>> getMediaStream() => events.stream;
  @override
  Future<void> reset() async {}
}

void main() {
  testWidgets('long shared text does not split an emoji in the saved title', (
    tester,
  ) async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final previous = ReceiveSharingIntent.instance;
    final sharing = _Sharing();
    ReceiveSharingIntent.instance = sharing;
    addTearDown(() async {
      ReceiveSharingIntent.instance = previous;
      await sharing.events.close();
    });
    final prefix = List.filled(116, 'a').join();
    final text = '$prefix😀 continues after the title limit';
    sharing.initial.complete([
      SharedMediaFile(path: text, type: SharedMediaType.text),
    ]);
    await pumpApp(
      tester,
      const Scaffold(body: ShareIntentListener(child: SizedBox())),
      env: env,
    );
    await tester.pump(const Duration(milliseconds: 100));
    final items = await env
        .container()
        .read(itemRepositoryProvider)
        .allActive();
    expect(items, hasLength(1));
    expect(items.single.title, '$prefix…');
    expect(items.single.notes, text);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cold and warm shares reach Inbox even while initial read is pending',
    (tester) async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final previous = ReceiveSharingIntent.instance;
      final sharing = _Sharing();
      ReceiveSharingIntent.instance = sharing;
      addTearDown(() async {
        ReceiveSharingIntent.instance = previous;
        await sharing.events.close();
      });
      await pumpApp(
        tester,
        const Scaffold(body: ShareIntentListener(child: SizedBox())),
        env: env,
      );
      sharing.events.add([
        SharedMediaFile(
          path: 'https://example.com/warm',
          type: SharedMediaType.url,
        ),
      ]);
      await tester.pump(const Duration(milliseconds: 100));
      sharing.initial.complete([
        SharedMediaFile(path: 'Cold shared text', type: SharedMediaType.text),
      ]);
      await tester.pump(const Duration(milliseconds: 100));
      final items = await env
          .container()
          .read(itemRepositoryProvider)
          .allActive();
      expect(
        items.map((i) => i.title),
        unorderedEquals(['https://example.com/warm', 'Cold shared text']),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    },
  );
}
