import 'package:cleartray/infrastructure/home_widget_bridge_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Queue encoding shared with the native widget code, and launch links
/// delivered over `app.cleartray/launch_link` (ADR 0009).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const launch = MethodChannel('app.cleartray/launch_link');

  group('queue encoding', () {
    test('decodes entries and drops corrupt values', () {
      expect(HomeWidgetBridgeImpl.decodeQueue('[{"id":"a","at":1},3,"x"]'), [
        {'id': 'a', 'at': 1},
      ]);
      expect(HomeWidgetBridgeImpl.decodeQueue('{not json'), isEmpty);
      expect(HomeWidgetBridgeImpl.decodeQueue('{"id":"a"}'), isEmpty);
      expect(HomeWidgetBridgeImpl.decodeQueue(null), isEmpty);
    });

    test('parses completions and captures; rejects malformed entries', () {
      final at = DateTime.fromMillisecondsSinceEpoch(1761465600000);
      expect(
        HomeWidgetBridgeImpl.completionFrom({
          'receipt': 'a1',
          'id': 'a',
          'at': 1761465600000,
        }),
        (receipt: 'a1', id: 'a', at: at),
      );
      expect(
        HomeWidgetBridgeImpl.completionFrom({
          'receipt': 'a1',
          'id': '',
          'at': 1,
        }),
        isNull,
      );
      expect(
        HomeWidgetBridgeImpl.completionFrom({'receipt': 'a1', 'id': 'a'}),
        isNull,
      );
      expect(
        HomeWidgetBridgeImpl.captureFrom({
          'receipt': 'milk1',
          'text': 'milk',
          'at': 1761465600000.0,
        }),
        (receipt: 'milk1', text: 'milk', at: at),
      );
      expect(
        HomeWidgetBridgeImpl.captureFrom({
          'receipt': 'milk1',
          'text': 3,
          'at': 1,
        }),
        isNull,
      );
    });
  });

  group('platform bridge', () {
    setUp(() {
      messenger.setMockMethodCallHandler(
        const MethodChannel('home_widget'),
        (call) async =>
            call.method == 'initiallyLaunchedFromHomeWidget' ? null : true,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('home_widget/updates'),
        (_) async => null,
      );
    });
    tearDown(() {
      messenger.setMockMethodCallHandler(
        const MethodChannel('home_widget'),
        null,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('home_widget/updates'),
        null,
      );
      messenger.setMockMethodCallHandler(launch, null);
    });

    test(
      'reads pending work and acknowledges it by receipt over the native channel',
      () async {
        final calls = <MethodCall>[];
        messenger.setMockMethodCallHandler(launch, (call) async {
          calls.add(call);
          if (call.method == 'readExternalQueue') {
            if (call.arguments == 'today_completions') {
              return '[{"receipt":"tap1","id":"task1","at":1},'
                  '{"receipt":"corrupt","id":"","at":1}]';
            }
            return '[{"receipt":"capture1","text":"milk","at":2}]';
          }
          return null;
        });
        final bridge = HomeWidgetBridgeImpl();
        final queue = await bridge.readQueue();

        expect(queue.completions.single.receipt, 'tap1');
        expect(queue.captures.single.receipt, 'capture1');
        expect(
          calls
              .where((call) => call.method == 'acknowledgeExternalQueue')
              .map((call) => call.arguments),
          [
            {
              'key': 'today_completions',
              'receipts': ['corrupt'],
            },
          ],
        );

        await bridge.acknowledgeQueue(
          completionReceipts: [queue.completions.single.receipt],
          captureReceipts: [queue.captures.single.receipt],
        );

        expect(
          calls
              .where((call) => call.method == 'acknowledgeExternalQueue')
              .skip(1)
              .map((call) => call.arguments),
          [
            {
              'key': 'today_completions',
              'receipts': ['tap1'],
            },
            {
              'key': 'inbox_captures',
              'receipts': ['capture1'],
            },
          ],
        );
      },
    );

    test(
      'a pending App Intent link is held until the router listens',
      () async {
        var pending = 'cleartray://today';
        messenger.setMockMethodCallHandler(launch, (call) async {
          if (call.method != 'takePending') return null;
          final link = pending;
          pending = '';
          return link.isEmpty ? null : link;
        });
        final bridge = HomeWidgetBridgeImpl();
        await bridge.init();
        final taps = <Uri>[];
        final sub = bridge.widgetTaps.listen(taps.add);
        await Future<void>.delayed(Duration.zero);
        expect(taps, [Uri.parse('cleartray://today')]);

        await bridge.checkPendingLaunch();
        await Future<void>.delayed(Duration.zero);
        expect(taps, hasLength(1), reason: 'taken once');
        await sub.cancel();
      },
    );

    test('native open and queueChanged calls reach the streams', () async {
      messenger.setMockMethodCallHandler(launch, (_) async => null);
      final bridge = HomeWidgetBridgeImpl();
      await bridge.init();
      final taps = <Uri>[];
      var changes = 0;
      final s1 = bridge.widgetTaps.listen(taps.add);
      final s2 = bridge.queueChanged.listen((_) => changes++);

      Future<void> nativeCall(String method, [Object? args]) =>
          messenger.handlePlatformMessage(
            launch.name,
            launch.codec.encodeMethodCall(MethodCall(method, args)),
            (_) {},
          );
      await nativeCall('open', 'cleartray://capture');
      await nativeCall('queueChanged');
      await Future<void>.delayed(Duration.zero);
      expect(taps, [Uri.parse('cleartray://capture')]);
      expect(changes, 1);
      await s1.cancel();
      await s2.cancel();
    });
  });
}
