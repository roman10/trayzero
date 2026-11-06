import 'package:flutter/foundation.dart';

import '../core/home_widget_bridge.dart';
import '../data/repositories/item_repository.dart';
import '../domain/entities/entities.dart';
import 'capture_item.dart';
import 'complete_item.dart';

/// Applies work queued outside the app (ADR 0009): Today widget checkbox
/// taps and iOS "Add to Inbox" captures. Extensions and widgets cannot
/// open the database, so they append to a shared queue; this use case runs
/// each entry through the same use case an in-app action would hit.
///
/// Best-effort like [DrainPendingNotificationIntents]: one failing entry
/// must not abort the rest or the app launch. Concurrent drains (startup,
/// resume, and a native signal can overlap) are coalesced into one run
/// followed by at most one re-run.
final class DrainExternalQueue {
  DrainExternalQueue({
    required HomeWidgetBridge bridge,
    required ItemRepository items,
    required CompleteItem completeItem,
    required CaptureItem captureItem,
  }) : _bridge = bridge,
       _items = items,
       _completeItem = completeItem,
       _captureItem = captureItem;

  final HomeWidgetBridge _bridge;
  final ItemRepository _items;
  final CompleteItem _completeItem;
  final CaptureItem _captureItem;

  Future<void>? _running;
  bool _again = false;

  Future<void> call() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _drainOnce();
    } while (_again);
  }

  Future<void> _drainOnce() async {
    ExternalQueue queue;
    try {
      queue = await _bridge.takeQueue();
    } catch (e, st) {
      debugPrint('[widget] queue read FAILED: $e\n$st');
      return;
    }
    for (final c in queue.completions) {
      try {
        await _complete(c);
      } catch (e, st) {
        debugPrint('[widget] queued completion FAILED: $e\n$st');
      }
    }
    for (final c in queue.captures) {
      try {
        await _capture(c);
      } catch (e, st) {
        debugPrint('[widget] queued capture FAILED: $e\n$st');
      }
    }
  }

  Future<void> _complete(QueuedCompletion c) async {
    final item = await _items.getById(c.id);
    // Deleted, already done (in the app or from a notification), or
    // trashed since the tap: nothing to complete, and completing again
    // would spawn a second recurrence successor.
    if (item == null ||
        item.completedAt != null ||
        item.status == ItemStatus.done ||
        item.status == ItemStatus.trashed) {
      return;
    }
    await _completeItem(c.id, at: c.at);
  }

  /// Raw capture: Siri text is not run through the quick-capture parser,
  /// because there is no chip preview to undo a misreading (ADR 0009).
  Future<void> _capture(QueuedCapture c) async {
    final text = c.text.trim();
    if (text.isEmpty) return;
    final long = text.length > _maxTitle;
    await _captureItem(
      title: long ? '${_cut(text, _maxTitle - 3)}…' : text,
      notes: long ? text : null,
    );
  }

  /// First [end] UTF-16 units of [text], backing off one so an emoji's
  /// surrogate pair is never split into an invalid string.
  static String _cut(String text, int end) {
    final unit = text.codeUnitAt(end - 1);
    final splitsPair = unit >= 0xD800 && unit <= 0xDBFF;
    return text.substring(0, splitsPair ? end - 1 : end);
  }

  static const _maxTitle = 120;
}
