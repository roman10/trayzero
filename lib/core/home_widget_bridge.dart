import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Platform port for the home-screen widget. The Android widget provider
/// and iOS WidgetKit extension live under android/app/src/main and
/// ios/CleartrayInboxWidget respectively; this bridge is the only thing
/// Dart code ever talks to.
abstract class HomeWidgetBridge {
  Future<void> init();
  Future<void> publishInboxCount(int count);

  /// Emits deep-link URIs produced by widget taps (e.g.
  /// `cleartray://capture`, `cleartray://inbox`). Both cold-launch and
  /// warm-launch taps come through this single stream.
  Stream<Uri> get widgetTaps;
}

final homeWidgetBridgeProvider = Provider<HomeWidgetBridge>((ref) {
  throw UnimplementedError('homeWidgetBridgeProvider must be overridden');
});
