import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HapticCue { taskCompleted, reviewFinished }

final playHapticCueProvider = Provider<Future<void> Function(HapticCue)>(
  (ref) => (_) async {},
);
