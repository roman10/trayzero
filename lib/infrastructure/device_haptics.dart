import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/haptic_feedback.dart';

const androidHapticsChannel = MethodChannel('app.cleartray/haptics');

Future<void> playDeviceHaptic(HapticCue cue) async {
  if (kIsWeb) return;
  try {
    switch ((defaultTargetPlatform, cue)) {
      case (TargetPlatform.android, HapticCue.reviewFinished):
        await androidHapticsChannel.invokeMethod<void>('confirm');
      case (TargetPlatform.iOS, HapticCue.reviewFinished):
        await HapticFeedback.successNotification();
      case (
        TargetPlatform.android || TargetPlatform.iOS,
        HapticCue.taskCompleted,
      ):
        await HapticFeedback.lightImpact();
      default:
        break;
    }
  } on PlatformException catch (error) {
    debugPrint('[haptics] Could not play feedback: $error');
  } on MissingPluginException catch (error) {
    debugPrint('[haptics] Could not play feedback: $error');
  }
}
