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
    try {
      await HomeWidget.saveWidgetData<String>(todaySnapshotKey, json);
      _lastTodayJson = json;
      await _refreshToday();
    } on Object catch (_) {
      // Widget not installed — no-op.
    }
  }

  Future<void> _refreshToday() => HomeWidget.updateWidget(
    qualifiedAndroidName: _androidTodayProvider,
    iOSName: _iOSTodayWidget,
  );

  @override
  Future<ExternalQueue> takeQueue() async {
    await init();
    if (!Platform.isAndroid && !Platform.isIOS) return const ExternalQueue();
    final completions = await _take(todayCompletionsKey);
    final captures = await _take(inboxCapturesKey);
    if (completions.isNotEmpty) {
      // Re-render: a skipped entry (Item deleted since the tap) leaves the
      // snapshot unchanged, so publishing alone would keep its check.
      try {
        await _refreshToday();
      } on Object catch (_) {}
    }
    return ExternalQueue(
      completions: [for (final e in completions) ?_completion(e)],
      captures: [for (final e in captures) ?_capture(e)],
    );
  }

  /// Reads queue [key] and removes exactly the entries read. The key is
  /// read again just before writing so an entry appended meanwhile (the
  /// widget or an intent runs in another thread or process) is kept.
  Future<List<Map<String, Object?>>> _take(String key) async {
    final taken = decodeQueue(await HomeWidget.getWidgetData<String>(key));
    if (taken.isEmpty) return taken;
    final latest = decodeQueue(await HomeWidget.getWidgetData<String>(key));
    final remaining = removeTaken(latest, taken);
    await HomeWidget.saveWidgetData<String>(
      key,
      remaining.isEmpty ? null : jsonEncode(remaining),
    );
    return taken;
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

  /// [latest] minus one occurrence of each entry in [taken].
  @visibleForTesting
  static List<Map<String, Object?>> removeTaken(
    List<Map<String, Object?>> latest,
    List<Map<String, Object?>> taken,
  ) {
    final pending = [for (final t in taken) jsonEncode(t)];
    final remaining = <Map<String, Object?>>[];
    for (final e in latest) {
      if (!pending.remove(jsonEncode(e))) remaining.add(e);
    }
    return remaining;
  }

  static DateTime? _time(Object? ms) =>
      ms is num ? DateTime.fromMillisecondsSinceEpoch(ms.toInt()) : null;

  @visibleForTesting
  static QueuedCompletion? completionFrom(Map<String, Object?> e) =>
      _completion(e);

  @visibleForTesting
  static QueuedCapture? captureFrom(Map<String, Object?> e) => _capture(e);

  static QueuedCompletion? _completion(Map<String, Object?> e) {
    final id = e['id'];
    final at = _time(e['at']);
    if (id is! String || id.isEmpty || at == null) return null;
    return (id: id, at: at);
  }

  static QueuedCapture? _capture(Map<String, Object?> e) {
    final text = e['text'];
    final at = _time(e['at']);
    if (text is! String || at == null) return null;
    return (text: text, at: at);
  }
}
