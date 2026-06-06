import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../core/home_widget_bridge.dart';

/// Default impl backed by the `home_widget` plugin. Body lifted from the
/// previous `HomeWidgetService` singleton; behaviour unchanged.
class HomeWidgetBridgeImpl implements HomeWidgetBridge {
  HomeWidgetBridgeImpl();

  static const _appGroupId = 'group.app.cleartray';
  static const _androidWidgetProvider = 'CleartrayInboxWidgetProvider';
  static const _iOSWidgetName = 'CleartrayInboxWidget';

  bool _initialized = false;
  final _widgetTapController = StreamController<Uri>.broadcast();

  @override
  Stream<Uri> get widgetTaps => _widgetTapController.stream;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      _initialized = true;

      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        _widgetTapController.add(initialUri);
      }

      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) _widgetTapController.add(uri);
      });
    } on Object catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('HomeWidget init skipped: $e');
      }
    }
  }

  @override
  Future<void> publishInboxCount(int count) async {
    await init();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await HomeWidget.saveWidgetData<int>('inbox_count', count);
      await HomeWidget.updateWidget(
        name: _androidWidgetProvider,
        iOSName: _iOSWidgetName,
      );
    } on Object catch (_) {
      // Widget not installed — no-op.
    }
  }
}
