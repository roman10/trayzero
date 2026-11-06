import 'dart:async';

import 'package:cleartray/infrastructure/home_widget_bridge_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(const MethodChannel('home_widget'), (
      call,
    ) async {
      if (call.method == 'initiallyLaunchedFromHomeWidget') {
        return 'cleartray://capture';
      }
      return true;
    });
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
  });

  for (final subscribeBeforeInit in [false, true]) {
    test(
      'cold launch delivered once with early listener=$subscribeBeforeInit',
      () async {
        final bridge = HomeWidgetBridgeImpl();
        final taps = <Uri>[];
        StreamSubscription<Uri>? subscription;
        if (subscribeBeforeInit) {
          subscription = bridge.widgetTaps.listen(taps.add);
        }
        await bridge.init();
        await Future<void>.delayed(Duration.zero);
        subscription ??= bridge.widgetTaps.listen(taps.add);
        await Future<void>.delayed(Duration.zero);
        expect(taps, [Uri.parse('cleartray://capture')]);
        await subscription.cancel();
        final second = bridge.widgetTaps.listen(taps.add);
        await bridge.init();
        await Future<void>.delayed(Duration.zero);
        expect(taps, [Uri.parse('cleartray://capture')]);
        await second.cancel();
      },
    );
  }
}
