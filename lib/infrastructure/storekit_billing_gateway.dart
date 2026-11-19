import 'dart:async';

import 'package:flutter/services.dart';

import '../core/billing.dart';
import '../core/billing_diagnostics.dart';

/// App Store purchases and entitlements, with StoreKit verification on device.
class StoreKitBillingGateway implements BillingGateway {
  static const _channel = MethodChannel('app.cleartray/storekit');
  final _status = StreamController<SupporterStatus>.broadcast();
  Future<void>? _configuration;

  @override
  bool get isConfigured => _configured;
  bool _configured = false;

  @override
  Future<void> configure() => _configuration ??= _configure();

  Future<void> _configure() async {
    try {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'statusChanged' && !_status.isClosed) {
          _status.add(_readStatus(call.arguments as Map<Object?, Object?>?));
        }
      });
      await _channel.invokeMethod<void>('configure', {
        'tips': [BillingIds.tipSmall, BillingIds.tipLarge],
        'subscriptions': [
          BillingIds.supporterMonthly,
          BillingIds.supporterYearly,
        ],
      });
      _configured = true;
    } on PlatformException {
      // Try again on the next billing action.
    } on MissingPluginException {
      // Billing is unavailable in builds that omit the platform plugin.
    } finally {
      if (!isConfigured) _configuration = null;
    }
  }

  @override
  Future<BillingOfferings?> loadOfferings() async {
    await configure();
    if (!isConfigured) return null;
    try {
      final catalog = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'products',
      );
      final products = {
        for (final product in catalog ?? const <Map<Object?, Object?>>[])
          product['id'] as String: BillingProduct(
            id: product['id'] as String,
            title: product['title'] as String,
            priceString: product['priceString'] as String,
            rawPrice: product['rawPrice'] as double,
            currencyCode: product['currencyCode'] as String,
          ),
      };
      return BillingOfferings(
        tips: [
          for (final id in [BillingIds.tipSmall, BillingIds.tipLarge])
            ?products[id],
        ],
        monthly: products[BillingIds.supporterMonthly],
        yearly: products[BillingIds.supporterYearly],
      );
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<SupporterStatus> currentStatus() async {
    await configure();
    if (!isConfigured) return const SupporterStatus.none();
    try {
      return _readStatus(await _channel.invokeMapMethod('currentStatus'));
    } on PlatformException {
      return const SupporterStatus.none();
    }
  }

  @override
  Stream<SupporterStatus> statusChanges() => _status.stream;

  @override
  Future<PurchaseOutcome> purchase(String productId) =>
      _perform('purchase', productId);

  @override
  Future<PurchaseOutcome> restore() => _perform('restore');

  Future<PurchaseOutcome> _perform(String method, [String? productId]) async {
    final trace = BillingTrace.current;
    trace?.mark('gateway_entered');
    await configure();
    trace?.mark('configuration_ready');
    if (!isConfigured) return const PurchaseFailed(PurchaseFailure.unavailable);
    try {
      trace?.mark('sdk_call_started');
      final status = _readStatus(
        await _channel.invokeMapMethod(method, productId),
      );
      if (!_status.isClosed) _status.add(status);
      return PurchaseSucceeded(status);
    } on PlatformException catch (error) {
      if (error.code == 'cancelled') return const PurchaseCancelled();
      return PurchaseFailed(switch (error.code) {
        'optionUnavailable' => PurchaseFailure.optionUnavailable,
        'network' => PurchaseFailure.network,
        'notAllowed' => PurchaseFailure.notAllowed,
        'pending' => PurchaseFailure.pending,
        'storeProblem' => PurchaseFailure.storeProblem,
        _ => PurchaseFailure.unknown,
      });
    } finally {
      trace?.mark('sdk_returned');
    }
  }

  SupporterStatus _readStatus(Map<Object?, Object?>? values) {
    final plan = switch (values?['productId']) {
      BillingIds.supporterMonthly => SupporterPlan.monthly,
      BillingIds.supporterYearly => SupporterPlan.yearly,
      _ => null,
    };
    if (plan == null) return const SupporterStatus.none();
    final expiresAtMs = values?['expiresAtMs'] as int?;
    return SupporterStatus(
      isSupporter: true,
      activePlan: plan,
      expiresAt: expiresAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresAtMs, isUtc: true),
    );
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
    unawaited(_status.close());
  }
}
