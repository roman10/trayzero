import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/billing.dart';
import '../core/billing_diagnostics.dart';
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

final billingControllerProvider = Provider<BillingController>(
  BillingController.new,
);

/// Shared across Support screen navigation. Null means no purchase/restore is
/// running. A store operation keeps this lock until it actually returns.
final billingOperationProvider = StateProvider<BillingOperation?>(
  (ref) => null,
);

class BillingOperation {
  BillingOperation({required this.productId, required this.trace});

  final String? productId;
  final BillingTrace trace;
  bool get isRestoring => productId == null;
}

/// Owns the operation lock as well as the timing span, so even two taps before
/// the next frame (or callers outside the screen) cannot launch two sheets.
class BillingController {
  BillingController(this._ref) {
    _ref.onDispose(() => _disposed = true);
  }

  final Ref _ref;
  bool _disposed = false;

  BillingGateway get _gateway => _ref.read(billingGatewayProvider);

  Future<PurchaseOutcome> tip(TipTier tier) => _run(BillingIds.forTip(tier));

  Future<PurchaseOutcome> becomeSupporter(SupporterPlan plan) =>
      _run(BillingIds.forPlan(plan));

  Future<PurchaseOutcome> restore() => _run(null);

  Future<PurchaseOutcome> _run(String? productId) async {
    final active = _ref.read(billingOperationProvider);
    if (active != null) {
      active.trace.mark('overlapping_action_ignored');
      return const PurchaseCancelled();
    }
    final trace = BillingTrace(productId ?? 'restore');
    final operation = BillingOperation(productId: productId, trace: trace);
    _ref.read(billingOperationProvider.notifier).state = operation;
    return trace.run(() async {
      try {
        final outcome = await (productId == null
            ? _gateway.restore()
            : _gateway.purchase(productId));
        trace.mark(
          'action_finished',
          result: switch (outcome) {
            PurchaseSucceeded() => 'success',
            PurchaseCancelled() => 'cancelled',
            PurchaseFailed(:final reason) => 'failure_${reason.name}',
          },
        );
        return outcome;
      } catch (error) {
        // Configuration/bridge failures can throw before the gateway reaches
        // its normal store-error mapping. Recover the UI without logging PII.
        trace.mark('action_finished', result: 'exception_${error.runtimeType}');
        return const PurchaseFailed(PurchaseFailure.unknown);
      } finally {
        if (!_disposed) {
          _ref.read(billingOperationProvider.notifier).state = null;
        }
      }
    });
  }
}
