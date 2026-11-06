import 'dart:async';

import 'package:cleartray/infrastructure/speech_to_text_dictation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugin.csdcorp.com/speech_to_text');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late SpeechToText speech;
  late List<String> calls;
  late List<SpeechToTextDictation> sessions;
  bool available = true;
  Completer<bool>? initializeGate;

  setUp(() {
    speech = SpeechToText.withMethodChannel();
    calls = [];
    sessions = [];
    available = true;
    initializeGate = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'initialize' =>
          initializeGate == null ? available : await initializeGate!.future,
        'listen' => true,
        _ => null,
      };
    });
  });
  tearDown(() async {
    for (final session in sessions) {
      await session.cancel();
    }
    messenger.setMockMethodCallHandler(channel, null);
  });

  SpeechToTextDictation session() {
    final result = SpeechToTextDictation(speech: speech);
    sessions.add(result);
    return result;
  }

  Future<bool> start(
    SpeechToTextDictation session, {
    void Function()? stopped,
    void Function()? error,
  }) => session.start(
    onText: (_) {},
    onStopped: stopped ?? () {},
    onError: error ?? () {},
  );

  test('constructing a session does not access the platform', () {
    session();
    expect(calls, isEmpty);
  });

  test(
    'each new capture receives status/error callbacks after cached init',
    () async {
      final first = session();
      var firstStops = 0;
      var firstErrors = 0;
      expect(
        await start(
          first,
          stopped: () => firstStops++,
          error: () => firstErrors++,
        ),
        true,
      );
      final oldStatus = speech.statusListener!;
      final oldError = speech.errorListener!;

      final second = session();
      var secondStops = 0;
      var secondErrors = 0;
      expect(
        await start(
          second,
          stopped: () => secondStops++,
          error: () => secondErrors++,
        ),
        true,
      );
      expect(calls.where((method) => method == 'initialize'), hasLength(1));
      speech.statusListener!('notListening');
      speech.errorListener!(SpeechRecognitionError('error_permission', true));
      oldStatus('done');
      oldError(SpeechRecognitionError('old_error', true));
      expect(firstStops, 0);
      expect(firstErrors, 0);
      expect(secondStops, 1);
      expect(secondErrors, 1);

      await first.cancel();
      expect(calls.where((method) => method == 'cancel'), isEmpty);
      await second.cancel();
      expect(calls.where((method) => method == 'cancel'), hasLength(1));
      speech.statusListener!('done');
      speech.errorListener!(SpeechRecognitionError('late_error', true));
      expect(secondStops, 1);
      expect(secondErrors, 1);
    },
  );

  test(
    'cancelling while permission is pending prevents listening afterwards',
    () async {
      initializeGate = Completer<bool>();
      final capture = session();
      var stopped = false;
      var failed = false;
      final started = start(
        capture,
        stopped: () => stopped = true,
        error: () => failed = true,
      );
      await Future<void>.delayed(Duration.zero);
      await capture.cancel();
      initializeGate!.complete(true);
      expect(await started, false);
      expect(calls.where((method) => method == 'listen'), isEmpty);
      speech.statusListener!('done');
      speech.errorListener!(SpeechRecognitionError('late_error', true));
      expect(stopped, false);
      expect(failed, false);
    },
  );

  test(
    'unavailable initialization can be retried on the next microphone tap',
    () async {
      available = false;
      final capture = session();
      expect(await start(capture), false);
      expect(calls, ['initialize']);
      available = true;
      expect(await start(capture), true);
      expect(calls, ['initialize', 'initialize', 'listen']);
      await capture.stop();
      expect(calls.last, 'stop');
    },
  );
}
