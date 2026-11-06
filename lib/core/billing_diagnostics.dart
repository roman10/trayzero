import 'dart:async';

import 'package:flutter/foundation.dart';

/// Local timing breadcrumbs only: no customer IDs, receipts, prices, or raw
/// store errors. SDK return time includes the user's interaction with the sheet;
/// it must not be interpreted as the time the sheet took to appear.
class BillingTrace {
  BillingTrace(this.operation) : id = ++_nextId {
    mark('action_started');
  }

  static int _nextId = 0;
  static final Object _zoneKey = Object();
  static BillingTrace? get current => Zone.current[_zoneKey] as BillingTrace?;

  final int id;
  final String operation;
  final Stopwatch _watch = Stopwatch()..start();

  void mark(String stage, {String? result}) {
    debugPrintSynchronously(
      '[billing] attempt=$id operation=$operation stage=$stage '
      'elapsed_ms=${_watch.elapsedMilliseconds}'
      '${result == null ? '' : ' result=$result'}',
    );
  }

  Future<T> run<T>(Future<T> Function() body) =>
      runZoned(body, zoneValues: {_zoneKey: this});
}
