import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/infrastructure/method_channel_app_icon_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.cleartray/app_icon');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const gateway = MethodChannelAppIconGateway();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    test('$platform loads native state and passes stable icon id', () async {
      debugDefaultTargetPlatformOverride = platform;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getState') {
          return {'supported': true, 'icon': 'cyan'};
        }
        expect(call.method, 'setIcon');
        expect(call.arguments, {'icon': 'amber'});
        return {'supported': true, 'icon': 'amber'};
      });
      expect((await gateway.load()).palette, AppPalette.cyan);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(androidNotificationIconPaletteKey),
        platform == TargetPlatform.android ? 'cyan' : isNull,
      );
      expect(
        (await gateway.setIcon(AppPalette.amber)).palette,
        AppPalette.amber,
      );
      expect(
        prefs.getString(androidNotificationIconPaletteKey),
        platform == TargetPlatform.android ? 'amber' : isNull,
      );
    });
  }
  test(
    'propagates native errors so UI does not claim a successful change',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'icon_unavailable'),
      );
      await expectLater(
        gateway.setIcon(AppPalette.blue),
        throwsA(isA<PlatformException>()),
      );
    },
  );
  test(
    'failed Android switch retains the last confirmed notification color',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      SharedPreferences.setMockInitialValues({
        androidNotificationIconPaletteKey: 'cyan',
      });
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'icon_change_failed'),
      );
      await expectLater(
        gateway.setIcon(AppPalette.rose),
        throwsA(isA<PlatformException>()),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(androidNotificationIconPaletteKey), 'cyan');
    },
  );
  test('unsupported platforms do not call native channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => fail('Unexpected platform call'),
    );
    expect((await gateway.load()).supported, isFalse);
  });
}
