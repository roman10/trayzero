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

    test('removes only the entries read, keeping concurrent appends', () {
      final taken = [
        {'id': 'a', 'at': 1},
        {'id': 'a', 'at': 1},
      ];
      final latest = [
        {'id': 'a', 'at': 1},
        {'id': 'a', 'at': 1},
        {'id': 'a', 'at': 1}, // A third, identical tap appended meanwhile.
        {'id': 'b', 'at': 2},
      ];
      expect(HomeWidgetBridgeImpl.removeTaken(latest, taken), [
        {'id': 'a', 'at': 1},
        {'id': 'b', 'at': 2},
      ]);
    });

    test('parses completions and captures; rejects malformed entries', () {
      final at = DateTime.fromMillisecondsSinceEpoch(1761465600000);
      expect(
        HomeWidgetBridgeImpl.completionFrom({'id': 'a', 'at': 1761465600000}),
        (id: 'a', at: at),
      );
      expect(HomeWidgetBridgeImpl.completionFrom({'id': '', 'at': 1}), isNull);
      expect(HomeWidgetBridgeImpl.completionFrom({'id': 'a'}), isNull);
      expect(
        HomeWidgetBridgeImpl.captureFrom({
          'text': 'milk',
          'at': 1761465600000.0,
        }),
        (text: 'milk', at: at),
      );
      expect(HomeWidgetBridgeImpl.captureFrom({'text': 3, 'at': 1}), isNull);
    });
  });

  group('launch links', () {
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
