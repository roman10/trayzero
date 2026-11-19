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
/// Acknowledges successfully applied or redundant entries after the use cases
/// return. Failed entries remain queued for the next drain. Concurrent drains
/// (startup, resume, or a native signal) coalesce into one run and a re-run
/// if another request arrives while that run is in progress.
final class DrainExternalQueue {
  DrainExternalQueue({
    required HomeWidgetBridge bridge,
    required ItemRepository items,
    required CompleteItem completeItem,
    required CaptureItem captureItem,
    Future<void> Function()? publishTodayAfterCompletion,
  }) : _bridge = bridge,
       _items = items,
       _completeItem = completeItem,
       _captureItem = captureItem,
       _publishTodayAfterCompletion = publishTodayAfterCompletion;

  final HomeWidgetBridge _bridge;
  final ItemRepository _items;
  final CompleteItem _completeItem;
  final CaptureItem _captureItem;
  final Future<void> Function()? _publishTodayAfterCompletion;

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
      queue = await _bridge.readQueue();
    } catch (e, st) {
      debugPrint('[widget] queue read FAILED: $e\n$st');
      return;
    }
    final completionReceipts = <String>[];
    for (final c in queue.completions) {
      try {
        await _complete(c);
        completionReceipts.add(c.receipt);
      } catch (e, st) {
        debugPrint('[widget] queued completion FAILED: $e\n$st');
      }
    }
    if (completionReceipts.isNotEmpty) {
      try {
        // Publish committed state before clearing the widget's pending overlay.
        await _publishTodayAfterCompletion?.call();
        await _bridge.acknowledgeQueue(completionReceipts: completionReceipts);
      } catch (e, st) {
        debugPrint('[widget] completion acknowledgment FAILED: $e\n$st');
      }
    }
    final captureReceipts = <String>[];
    for (final c in queue.captures) {
      try {
        await _capture(c);
        captureReceipts.add(c.receipt);
      } catch (e, st) {
        debugPrint('[widget] queued capture FAILED: $e\n$st');
      }
    }
    if (captureReceipts.isNotEmpty) {
      try {
        await _bridge.acknowledgeQueue(captureReceipts: captureReceipts);
      } catch (e, st) {
        debugPrint('[widget] capture acknowledgment FAILED: $e\n$st');
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
      queuedCaptureId: 'widget-capture-${c.receipt}',
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
