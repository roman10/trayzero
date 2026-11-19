import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../core/home_widget_bridge.dart';

/// Widget storage, launch links, and the external work queue (ADR 0009),
/// backed by the `home_widget` plugin plus the `app.cleartray/launch_link`
/// channel.
///
/// Android launches arrive through home_widget's launch intent. iOS links
/// (widget URLs, App Intents) arrive through the launch-link channel,
/// because home_widget only claims URLs carrying a `homeWidget` query.
class HomeWidgetBridgeImpl implements HomeWidgetBridge {
  HomeWidgetBridgeImpl({
    MethodChannel launchChannel = const MethodChannel(
      'app.cleartray/launch_link',
    ),
  }) : _launchChannel = launchChannel;

  static const _appGroupId = 'group.app.cleartray';
  // Qualified, so updates also resolve in the `.debug` application id.
  static const _androidInboxProvider =
      'app.cleartray.CleartrayInboxWidgetProvider';
  static const _iOSInboxWidget = 'CleartrayInboxWidget';
  static const _androidTodayProvider = 'app.cleartray.TodayWidgetProvider';
  static const _iOSTodayWidget = 'TrayzeroTodayWidget';

  static const todaySnapshotKey = 'today_snapshot';
  static const todayCompletionsKey = 'today_completions';
  static const inboxCapturesKey = 'inbox_captures';

  final MethodChannel _launchChannel;
  Future<void>? _init;
  String? _lastTodayJson;
  final _pendingLinks = <Uri>[];
  late final StreamController<Uri> _widgetTapController =
      StreamController<Uri>.broadcast(
        onListen: () {
          final links = List.of(_pendingLinks);
          _pendingLinks.clear();
          links.forEach(_widgetTapController.add);
        },
      );
  final _queueChangedController = StreamController<void>.broadcast();

  @override
  Stream<Uri> get widgetTaps => _widgetTapController.stream;

  @override
  Stream<void> get queueChanged => _queueChangedController.stream;

  /// Startup initializes the bridge before attaching the router listener.
  /// Retain launch links until that first listener is ready.
  void _emitLink(Uri uri) {
    if (_widgetTapController.hasListener) {
      _widgetTapController.add(uri);
    } else {
      _pendingLinks.add(uri);
    }
  }

  /// Memoized so concurrent callers (publish, drain) all wait for the App
  /// Group to be set before touching widget storage.
  @override
  Future<void> init() => _init ??= _initOnce();

  Future<void> _initOnce() async {
    _launchChannel.setMethodCallHandler(_onNativeCall);
    try {
      await HomeWidget.setAppGroupId(_appGroupId);

      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) _emitLink(initialUri);

      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) _emitLink(uri);
      });
    } on Object catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('HomeWidget init skipped: $e');
      }
    }
    await checkPendingLaunch();
  }

  Future<Object?> _onNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'open':
        final uri = Uri.tryParse(call.arguments as String? ?? '');
        if (uri != null) _emitLink(uri);
      case 'queueChanged':
        _queueChangedController.add(null);
    }
    return null;
  }

  @override
  Future<void> checkPendingLaunch() async {
    try {
      final link = await _launchChannel.invokeMethod<String>('takePending');
      final uri = link == null ? null : Uri.tryParse(link);
      if (uri != null) _emitLink(uri);
    } on MissingPluginException {
      // Host without the channel (tests, unsupported platforms).
    } on PlatformException catch (e) {
      debugPrint('[widget] pending launch read FAILED: $e');
    }
  }

  @override
  Future<void> publishInboxCount(int count) async {
    await init();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await HomeWidget.saveWidgetData<int>('inbox_count', count);
      await HomeWidget.updateWidget(
        qualifiedAndroidName: _androidInboxProvider,
        iOSName: _iOSInboxWidget,
      );
    } on Object catch (_) {
      // Widget not installed — no-op.
    }
  }

  @override
  Future<void> publishToday(TodayWidgetSnapshot snapshot) async {
    await init();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final json = jsonEncode(snapshot.toJson());
    if (json == _lastTodayJson) return;
    final saved = await HomeWidget.saveWidgetData<String>(todaySnapshotKey, json);
    if (saved != true) {
      throw StateError('Could not save the Today widget snapshot');
    }
    await _refreshToday();
    _lastTodayJson = json;
  }

  Future<void> _refreshToday() => HomeWidget.updateWidget(
    qualifiedAndroidName: _androidTodayProvider,
    iOSName: _iOSTodayWidget,
  );

  @override
  Future<ExternalQueue> readQueue() async {
    await init();
    try {
      return ExternalQueue(
        completions: await _read(todayCompletionsKey, completionFrom),
        captures: await _read(inboxCapturesKey, captureFrom),
      );
    } on MissingPluginException {
      return const ExternalQueue();
    }
  }

  Future<List<T>> _read<T>(
    String key,
    T? Function(Map<String, Object?>) parse,
  ) async {
    final raw = await _launchChannel.invokeMethod<String>(
      'readExternalQueue',
      key,
    );
    final entries = <T>[];
    final malformedReceipts = <String>[];
    for (final data in decodeQueue(raw)) {
      final entry = parse(data);
      if (entry != null) {
        entries.add(entry);
      } else if (data['receipt'] case final String receipt
          when receipt.isNotEmpty) {
        malformedReceipts.add(receipt);
      }
    }
    await _acknowledge(key, malformedReceipts);
    return entries;
  }

  @override
  Future<void> acknowledgeQueue({
    List<String> completionReceipts = const [],
    List<String> captureReceipts = const [],
  }) async {
    await init();
    await _acknowledge(todayCompletionsKey, completionReceipts);
    await _acknowledge(inboxCapturesKey, captureReceipts);
    if (completionReceipts.isNotEmpty) {
      // Skipped entries can leave the snapshot unchanged, so they also need
      // a refresh to clear the widget's pending overlay.
      try {
        await _refreshToday();
      } on Object catch (e) {
        debugPrint('[widget] queue refresh FAILED: $e');
      }
    }
  }

  Future<void> _acknowledge(String key, List<String> receipts) async {
    if (receipts.isEmpty) return;
    await _launchChannel.invokeMethod<void>('acknowledgeExternalQueue', {
      'key': key,
      'receipts': receipts,
    });
  }

  /// Decodes a JSON-array queue. A corrupt value decodes as empty and is
  /// dropped by the next write, like the notification journal.
  @visibleForTesting
  static List<Map<String, Object?>> decodeQueue(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return [
        for (final e in decoded)
          if (e is Map) e.cast<String, Object?>(),
      ];
    } on FormatException {
      return [];
    }
  }

  static DateTime? _time(Object? ms) {
    if (ms is! num || !ms.isFinite || ms.abs() > 8640000000000000) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms.toInt());
  }

  @visibleForTesting
  static QueuedCompletion? completionFrom(Map<String, Object?> e) {
    final receipt = e['receipt'];
    final id = e['id'];
    final at = _time(e['at']);
    if (receipt is! String ||
        receipt.isEmpty ||
        id is! String ||
        id.isEmpty ||
        at == null) {
      return null;
    }
    return (receipt: receipt, id: id, at: at);
  }

  @visibleForTesting
  static QueuedCapture? captureFrom(Map<String, Object?> e) {
    final receipt = e['receipt'];
    final text = e['text'];
    final at = _time(e['at']);
    if (receipt is! String ||
        receipt.isEmpty ||
        text is! String ||
        at == null) {
      return null;
    }
    return (receipt: receipt, text: text, at: at);
  }
}
