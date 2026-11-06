import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A capture-owned speech session. Starting may request device permission;
/// constructing a session must not initialize speech or request permission.
abstract class Dictation {
  Future<bool> start({
    required void Function(String text) onText,
    required void Function() onStopped,
    required void Function() onError,
  });

  /// Stops listening and allows a final recognition result to arrive.
  Future<void> stop();

  /// Discards pending recognition, including a start still awaiting permission.
  Future<void> cancel();
}

/// Each capture owns its session so closing it cannot stop a later capture.
final dictationFactoryProvider = Provider<Dictation Function()>((ref) {
  throw UnimplementedError('dictationFactoryProvider must be overridden');
});
