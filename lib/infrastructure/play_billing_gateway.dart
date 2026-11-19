import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/billing.dart';

/// Android billing via the app's native Play Billing client. Only catalog
/// fields, the active product ID, and coarse errors cross the Flutter bridge.
class PlayBillingGateway implements BillingGateway {
  PlayBillingGateway({
    MethodChannel channel = const MethodChannel('app.cleartray/play_billing'),
  }) : _channel = channel;

  final MethodChannel _channel;
  final _changes = StreamController<SupporterStatus>.broadcast();
  SupporterStatus _status = const SupporterStatus.none();
  AppLifecycleListener? _lifecycle;

  @override
  bool get isConfigured => _lifecycle != null;

  @override
  Future<void> configure() async {
    if (isConfigured || _changes.isClosed) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'purchasesChanged') unawaited(_refreshInBackground());
    });
    _lifecycle = AppLifecycleListener(
      onResume: () {
        unawaited(_refreshInBackground());
      },
    );
    // Store setup and reconciliation must never hold up the first frame.
    unawaited(_refreshInBackground());
  }

  @override
  Future<BillingOfferings?> loadOfferings() async {
    try {
      final rows = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'offerings',
      );
      final products = <String, BillingProduct>{};
      for (final row in rows ?? const []) {
        final id = row['id'] as String;
        products[id] = BillingProduct(
          id: id,
          title: row['title'] as String,
          priceString: row['priceString'] as String,
          rawPrice: (row['rawPrice'] as num).toDouble(),
          currencyCode: row['currencyCode'] as String,
        );
      }
      return BillingOfferings(
        tips: [?products[BillingIds.tipSmall], ?products[BillingIds.tipLarge]],
        monthly: products[BillingIds.supporterMonthly],
        yearly: products[BillingIds.supporterYearly],
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<SupporterStatus> currentStatus() async {
    await configure();
    return _status;
  }

  @override
  Stream<SupporterStatus> statusChanges() => _changes.stream;

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    try {
      await configure();
      await _channel.invokeMethod<bool>('purchase', {'id': productId});
      // The native bridge verified the purchase. A refresh failure cannot
      // undo that result, and the server consumes new tips independently.
      await _refreshInBackground();
      return PurchaseSucceeded(_status);
    } on PlatformException catch (error) {
      return _outcome(error);
    } on MissingPluginException {
      return const PurchaseFailed(PurchaseFailure.unavailable);
    }
  }

  @override
  Future<PurchaseOutcome> restore() async {
    try {
      await configure();
      await _refresh();
      return PurchaseSucceeded(_status);
    } on PlatformException catch (error) {
      return _outcome(error);
    } on MissingPluginException {
      return const PurchaseFailed(PurchaseFailure.unavailable);
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      await _refresh();
    } on PlatformException {
      // Keep the last successful ownership snapshot during a store outage.
    } on MissingPluginException {
      // No Play Billing bridge on this build.
    }
  }

  Future<void> _refresh() async {
    final row = await _channel.invokeMapMethod<String, String>('refresh');
    final activePlan = switch (row?['activeProduct']) {
      BillingIds.supporterMonthly => SupporterPlan.monthly,
      BillingIds.supporterYearly => SupporterPlan.yearly,
      _ => null,
    };
    if (activePlan != _status.activePlan) {
      _status = SupporterStatus(
        isSupporter: activePlan != null,
        activePlan: activePlan,
      );
      if (!_changes.isClosed) _changes.add(_status);
    }
    if (row?['failure'] case final failure?) {
      throw PlatformException(code: failure);
    }
  }

  PurchaseOutcome _outcome(PlatformException error) => switch (error.code) {
    'cancelled' => const PurchaseCancelled(),
    'pending' => const PurchaseFailed(PurchaseFailure.pending),
    'alreadyOwned' => const PurchaseFailed(PurchaseFailure.alreadyOwned),
    'network' => const PurchaseFailed(PurchaseFailure.network),
    'optionUnavailable' => const PurchaseFailed(
      PurchaseFailure.optionUnavailable,
    ),
    'notAllowed' => const PurchaseFailed(PurchaseFailure.notAllowed),
    'unavailable' => const PurchaseFailed(PurchaseFailure.unavailable),
    _ => const PurchaseFailed(PurchaseFailure.storeProblem),
  };

  void dispose() {
    _lifecycle?.dispose();
    _lifecycle = null;
    _channel.setMethodCallHandler(null);
    unawaited(_changes.close());
  }
}
