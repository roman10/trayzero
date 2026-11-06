// Run only on a disposable simulator/device: this deliberately changes its icon.
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/infrastructure/method_channel_app_icon_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native app icon selection persists and rejects unknown icons', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      markTestSkipped('Mobile native icon check');
      return;
    }
    runApp(const MaterialApp(home: Scaffold(body: Text('Icon check'))));
    await tester.pumpAndSettle();
    const gateway = MethodChannelAppIconGateway();
    expect((await gateway.load()).supported, isTrue);
    final before = await gateway.load();
    await expectLater(
      const MethodChannel(
        'app.cleartray/app_icon',
      ).invokeMethod('setIcon', {'icon': 'unknown'}),
      throwsA(isA<PlatformException>()),
    );
    expect((await gateway.load()).palette, before.palette);
    // On iOS, a fresh change presents a system alert. A second run with
    // ICON_VERIFY_ONLY checks persistence across termination/reinstallation
    // without presenting another native alert.
    if (const bool.fromEnvironment('ICON_VERIFY_ONLY')) {
      expect(before.palette, AppPalette.cyan);
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint(
        'Acknowledge the native icon-change alert to finish this check.',
      );
    }
    final selected = await gateway.setIcon(AppPalette.cyan);
    expect(selected.palette, AppPalette.cyan);
    expect((await gateway.load()).palette, AppPalette.cyan);
    if (defaultTargetPlatform == TargetPlatform.android) {
      expect(
        (await gateway.setIcon(AppPalette.amber)).palette,
        AppPalette.amber,
      );
    }
  });
}
