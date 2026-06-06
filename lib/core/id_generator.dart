import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of fresh ids for newly-created entities. Abstracted so tests can
/// inject a deterministic sequence (mirrors the [Clock] / [FakeClock] shape).
abstract class IdGenerator {
  const IdGenerator();
  String newId();
}

/// Test fake — emits ids from a predefined queue. When the queue is empty,
/// falls back to an auto-incrementing `test-N` sequence so tests never run
/// out of ids unexpectedly.
class FixedIdGenerator extends IdGenerator {
  FixedIdGenerator([List<String> queue = const []]) : _queue = [...queue];
  final List<String> _queue;
  int _autoCounter = 0;
  @override
  String newId() {
    if (_queue.isNotEmpty) return _queue.removeAt(0);
    _autoCounter += 1;
    return 'test-$_autoCounter';
  }
}

/// Overridden in `main.dart` with the real uuid-backed impl. Throwing here
/// makes accidental real-id generation in tests visible.
final idGeneratorProvider = Provider<IdGenerator>((ref) {
  throw UnimplementedError('idGeneratorProvider must be overridden');
});
