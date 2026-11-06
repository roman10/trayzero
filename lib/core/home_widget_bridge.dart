import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Platform port for home-screen widgets and other system entry points
/// (ADR 0009). The Android widget providers, tile, and shortcuts live under
/// android/app/src/main; the iOS WidgetKit extension and App Intents under
/// ios/. This bridge is the only thing Dart code ever talks to.
abstract class HomeWidgetBridge {
  Future<void> init();
  Future<void> publishInboxCount(int count);

  /// Publishes Today's focused Items for the Today widget. Implementations
  /// skip the write when the snapshot is unchanged.
  Future<void> publishToday(TodayWidgetSnapshot snapshot);

  /// Emits `cleartray://` links from widget taps, the Quick Settings tile,
  /// launcher shortcuts, and App Intents (e.g. `cleartray://capture`,
  /// `cleartray://today`). Cold-launch and warm-launch links both come
  /// through this single stream.
  Stream<Uri> get widgetTaps;

  /// Fires when native code queued work while the app is alive, so the
  /// queue can be drained without waiting for the next resume.
  Stream<void> get queueChanged;

  /// Asks native code for a launch link an App Intent left while Dart was
  /// not listening. Delivered through [widgetTaps]. Called on resume.
  Future<void> checkPendingLaunch();

  /// Reads the work queued by widgets and App Intents and removes exactly
  /// the entries returned. Entries queued concurrently are kept.
  Future<ExternalQueue> takeQueue();
}

/// A widget checkbox tap: complete Item [id], tapped at [at].
typedef QueuedCompletion = ({String id, DateTime at});

/// Text captured without opening the app (iOS "Add to Inbox" intent).
typedef QueuedCapture = ({String text, DateTime at});

/// Work queued outside the app, drained through the normal use cases.
class ExternalQueue {
  const ExternalQueue({this.completions = const [], this.captures = const []});

  final List<QueuedCompletion> completions;
  final List<QueuedCapture> captures;

  bool get isEmpty => completions.isEmpty && captures.isEmpty;
}

/// One row of the Today widget.
typedef TodayWidgetRow = ({String id, String title});

/// What the Today widget renders (ADR 0009). [day] is the local date the
/// snapshot was built for; native code treats a snapshot from an earlier
/// day as empty, because its Items are now carry-over.
class TodayWidgetSnapshot {
  const TodayWidgetSnapshot({
    required this.day,
    required this.items,
    required this.more,
    required this.done,
  });

  static const version = 1;

  final DateTime day;
  final List<TodayWidgetRow> items;

  /// Focused Items not listed in [items].
  final int more;

  /// Focused Items completed today.
  final int done;

  Map<String, Object> toJson() => {
    'v': version,
    'day': _isoDay(day),
    'items': [
      for (final i in items) {'id': i.id, 'title': i.title},
    ],
    'more': more,
    'done': done,
  };

  static String _isoDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final homeWidgetBridgeProvider = Provider<HomeWidgetBridge>((ref) {
  throw UnimplementedError('homeWidgetBridgeProvider must be overridden');
});
