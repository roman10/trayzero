import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/billing.dart';
import '../core/billing_diagnostics.dart';

// RevenueCat *public* SDK keys. Unlike a secret key, these ship inside the app
// binary by design, so baking them in as defaults is safe — and it means every
// build path (flutter run/build, Xcode Archive, Android Studio) configures
// billing without needing a --dart-define flag. A --dart-define still overrides
// the default, e.g. to swap in the sandbox test key.
const _androidKey = String.fromEnvironment(
  'REVENUECAT_ANDROID_KEY',
  defaultValue: 'goog_DJPhZhnyFubCXCinFobHHcswiQw',
);
const _iosKey = String.fromEnvironment(
  'REVENUECAT_IOS_KEY',
  defaultValue: 'appl_SdMLQfgMGfvUFlxFSOrAQzvoKlQ',
);

/// The RevenueCat key for the running platform, or '' when none was supplied.
String revenueCatApiKeyForPlatform() {
  if (Platform.isAndroid) return _androidKey;
  if (Platform.isIOS || Platform.isMacOS) return _iosKey;
  return '';
}

/// RevenueCat-backed [BillingGateway]. Resolves products from the `default`
/// offering and maps the `supporter` entitlement to [SupporterStatus].
///
/// Android note: subscription store-product identifiers can arrive as
/// `productId:basePlanId`, so all lookups match on the bare id OR an
/// `id:` prefix.
class RevenueCatBillingGateway implements BillingGateway {
  RevenueCatBillingGateway({required this.apiKey});

  final String apiKey;

  bool _configured = false;
  Offering? _offering; // cached for package resolution between calls
  final StreamController<SupporterStatus> _status =
      StreamController<SupporterStatus>.broadcast();

  @override
  bool get isConfigured => _configured;

  @override
  Future<void> configure() async {
    if (apiKey.isEmpty || _configured) return;
    await Purchases.setLogLevel(LogLevel.info);
    // Leave `purchasesAreCompletedBy` at the RevenueCat default: the SDK
    // finishes/consumes transactions itself. Tip consumables depend on this —
    // switching to observer mode would leave tips unconsumed and unrepeatable.
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _configured = true;
    Purchases.addCustomerInfoUpdateListener((info) => _emit(_statusFrom(info)));
  }

  @override
  Future<BillingOfferings?> loadOfferings() async {
    await configure();
    final off = await _resolveOffering();
    if (off == null) return null;

    BillingProduct? find(String id) {
      for (final pkg in off.availablePackages) {
        final sp = pkg.storeProduct;
        if (sp.identifier == id || sp.identifier.startsWith('$id:')) {
          return _product(sp);
        }
      }
      return null;
    }

    final tips = <BillingProduct>[];
    for (final id in const [BillingIds.tipSmall, BillingIds.tipLarge]) {
      final p = find(id);
      if (p != null) tips.add(p);
    }

    return BillingOfferings(
      tips: tips,
      monthly: find(BillingIds.supporterMonthly),
      yearly: find(BillingIds.supporterYearly),
    );
  }

  @override
  Future<SupporterStatus> currentStatus() async {
    await configure();
    if (!_configured) return const SupporterStatus.none();
    try {
      return _statusFrom(await Purchases.getCustomerInfo());
    } on PlatformException {
      return const SupporterStatus.none();
    }
  }

  @override
  Stream<SupporterStatus> statusChanges() => _status.stream;

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    final trace = BillingTrace.current;
    trace?.mark('gateway_entered');
    await configure();
    trace?.mark('configuration_ready');
    if (!_configured) return const PurchaseFailed(PurchaseFailure.unavailable);
    final off = _offering ?? await _resolveOffering();
    if (off == null) {
      return const PurchaseFailed(PurchaseFailure.productsUnavailable);
    }
    Package? pkg;
    for (final p in off.availablePackages) {
      final id = p.storeProduct.identifier;
      if (id == productId || id.startsWith('$productId:')) {
        pkg = p;
        break;
      }
    }
    if (pkg == null) {
      return const PurchaseFailed(PurchaseFailure.optionUnavailable);
    }
    trace?.mark('package_ready');
    try {
      trace?.mark('sdk_call_started');
      final result = await Purchases.purchase(PurchaseParams.package(pkg));
      final status = _statusFrom(result.customerInfo);
      _emit(status);
      return PurchaseSucceeded(status);
    } on PlatformException catch (e) {
      return _outcomeFor(e);
    } finally {
      trace?.mark('sdk_returned');
    }
  }

  @override
  Future<PurchaseOutcome> restore() async {
    final trace = BillingTrace.current;
    trace?.mark('gateway_entered');
    await configure();
    trace?.mark('configuration_ready');
    if (!_configured) return const PurchaseFailed(PurchaseFailure.unavailable);
    try {
      trace?.mark('sdk_call_started');
      final status = _statusFrom(await Purchases.restorePurchases());
      _emit(status);
      return PurchaseSucceeded(status);
    } on PlatformException catch (e) {
      return _outcomeFor(e);
    } finally {
      trace?.mark('sdk_returned');
    }
  }

  /// Closes the status stream. Called from the provider's onDispose.
  void dispose() => _status.close();

  // --- internals ---------------------------------------------------------

  // The customer-info listener can fire after dispose(); never add to a
  // closed controller.
  void _emit(SupporterStatus status) {
    if (!_status.isClosed) _status.add(status);
  }

  Future<Offering?> _resolveOffering() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      _offering =
          offerings.all[BillingIds.defaultOffering] ?? offerings.current;
      return _offering;
    } on PlatformException {
      return null;
    }
  }

  BillingProduct _product(StoreProduct p) => BillingProduct(
    id: p.identifier,
    title: p.title,
    priceString: p.priceString,
    rawPrice: p.price,
    currencyCode: p.currencyCode,
  );

  SupporterStatus _statusFrom(CustomerInfo info) {
    final ent = info.entitlements.all[BillingIds.supporterEntitlement];
    if (ent == null || !ent.isActive) return const SupporterStatus.none();

    final productId = ent.productIdentifier;
    SupporterPlan? plan;
    if (productId.startsWith(BillingIds.supporterYearly)) {
      plan = SupporterPlan.yearly;
    } else if (productId.startsWith(BillingIds.supporterMonthly)) {
      plan = SupporterPlan.monthly;
    }

    final exp = ent.expirationDate;
    return SupporterStatus(
      isSupporter: true,
      activePlan: plan,
      expiresAt: exp == null ? null : DateTime.tryParse(exp),
    );
  }

  PurchaseOutcome _outcomeFor(PlatformException e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.purchaseCancelledError) {
      return const PurchaseCancelled();
    }
    return PurchaseFailed(switch (code) {
      PurchasesErrorCode.networkError => PurchaseFailure.network,
      PurchasesErrorCode.purchaseNotAllowedError => PurchaseFailure.notAllowed,
      PurchasesErrorCode.paymentPendingError => PurchaseFailure.pending,
      PurchasesErrorCode.productAlreadyPurchasedError =>
        PurchaseFailure.alreadyOwned,
      PurchasesErrorCode.storeProblemError => PurchaseFailure.storeProblem,
      _ => PurchaseFailure.unknown,
    });
  }
}
