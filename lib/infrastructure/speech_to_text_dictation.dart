import 'package:speech_to_text/speech_to_text.dart';

import '../core/dictation.dart';

class SpeechToTextDictation implements Dictation {
  SpeechToTextDictation({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  // speech_to_text uses a singleton. An old sheet must neither receive a new
  // sheet's callbacks nor cancel its microphone when the old sheet disposes.
  static SpeechToTextDictation? _owner;
  bool _cancelled = false;
  void Function(String)? _onText;
  void Function()? _onStopped;
  void Function()? _onError;
  bool get _active => !_cancelled && identical(_owner, this);

  @override
  Future<bool> start({
    required void Function(String text) onText,
    required void Function() onStopped,
    required void Function() onError,
  }) async {
    _cancelled = false;
    _owner = this;
    _onText = onText;
    _onStopped = onStopped;
    _onError = onError;
    void errorListener(error) {
      if (!_active) return;
      _cancelled = true;
      _onError?.call();
    }

    void statusListener(String status) {
      if (_active && (status == 'notListening' || status == 'done')) {
        _onStopped?.call();
      }
    }

    final available = await _speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
    if (!_active || !available) return false;
    // initialize short-circuits after its first success. Rebind listeners on
    // every start so subsequent capture sheets receive status/error updates.
    _speech.errorListener = errorListener;
    _speech.statusListener = statusListener;
    await _speech.listen(
      onResult: (result) {
        if (_active) _onText?.call(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
    return _active;
  }

  @override
  Future<void> stop() async {
    if (_active) await _speech.stop();
  }

  @override
  Future<void> cancel() async {
    _cancelled = true;
    // The singleton may retain its native callbacks after cancellation. Drop
    // the UI callbacks so it cannot retain the disposed capture sheet.
    _onText = null;
    _onStopped = null;
    _onError = null;
    if (!identical(_owner, this)) return;
    _owner = null;
    await _speech.cancel();
  }
}
