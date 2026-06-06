import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/billing.dart';
import '../infrastructure/billing_providers.dart';

/// Live supporter entitlement. Subscribes to store-reported changes first,
/// then seeds the current snapshot, so a status push that lands during the
/// initial async read is not dropped. Resolves to [SupporterStatus.none]
/// when billing is disabled.
final supporterStatusProvider = StreamProvider<SupporterStatus>((ref) {
  final gateway = ref.watch(billingGatewayProvider);
  final controller = StreamController<SupporterStatus>();
  final sub = gateway.statusChanges().listen(
        controller.add,
        onError: controller.addError,
      );
  gateway.currentStatus().then((s) {
    if (!controller.isClosed) controller.add(s);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Convenience boolean for cosmetic perks. Defaults to false while loading.
final isSupporterProvider = Provider<bool>((ref) {
  return ref.watch(supporterStatusProvider).valueOrNull?.isSupporter ?? false;
});

/// The purchasable products, resolved from the live offering. Null when
/// billing is disabled or the offering can't be loaded.
final billingOfferingsProvider = FutureProvider<BillingOfferings?>((ref) {
  return ref.watch(billingGatewayProvider).loadOfferings();
});

final billingControllerProvider =
    Provider<BillingController>(BillingController.new);

/// Thin action layer over [BillingGateway]. Purchases push their result back
/// through [supporterStatusProvider] via the gateway's status stream, so the
/// UI only needs the returned [PurchaseOutcome] to show a toast.
class BillingController {
  BillingController(this._ref);

  final Ref _ref;

  BillingGateway get _gateway => _ref.read(billingGatewayProvider);

  Future<PurchaseOutcome> tip(TipTier tier) =>
      _gateway.purchase(BillingIds.forTip(tier));

  Future<PurchaseOutcome> becomeSupporter(SupporterPlan plan) =>
      _gateway.purchase(BillingIds.forPlan(plan));

  Future<PurchaseOutcome> restore() => _gateway.restore();
}
