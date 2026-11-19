import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptic_feedback.dart';
import '../settings/settings_controller.dart';

void playHaptic(WidgetRef ref, HapticCue cue) {
  if (ref.read(hapticsEnabledProvider)) {
    unawaited(ref.read(playHapticCueProvider)(cue));
  }
}
