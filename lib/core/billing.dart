/// Billing domain: the small, store-agnostic surface the rest of the app
/// talks to. The concrete implementation (RevenueCat) lives in
/// `infrastructure/revenuecat_billing_gateway.dart`, mirroring the
/// gateway/implementation split used for calendar and notifications.
///
/// Monetisation rule: NOTHING here gates a feature. Tips are consumable
/// thank-yous; the `supporter` entitlement only unlocks cosmetic perks.
library;

/// One-time "tip jar" products (consumables — can be bought repeatedly).
enum TipTier { small, large }

/// Recurring ways to become a supporter. Both grant the same `supporter`
/// entitlement; only the billing period differs.
enum SupporterPlan { monthly, yearly }

/// Store product identifiers, configured 1:1 in App Store Connect / Play
/// Console and imported into RevenueCat. Centralised so UI, gateway and
/// store config can never drift. snake_case keeps both stores happy.
class BillingIds {
  BillingIds._();

  static const tipSmall = 'tip_small';
  static const tipLarge = 'tip_large';

  static const supporterMonthly = 'supporter_monthly';
  static const supporterYearly = 'supporter_yearly';

  /// RevenueCat entitlement granted by any supporter purchase.
  static const supporterEntitlement = 'supporter';

  /// RevenueCat offering that bundles every purchasable package.
  static const defaultOffering = 'default';

  static String forTip(TipTier t) => switch (t) {
        TipTier.small => tipSmall,
        TipTier.large => tipLarge,
      };

  static String forPlan(SupporterPlan p) => switch (p) {
        SupporterPlan.monthly => supporterMonthly,
        SupporterPlan.yearly => supporterYearly,
      };
}

/// A purchasable product carrying the store-localised price string. The
/// localised string already reflects the user's storefront currency and any
/// regional (PPP) pricing, so the UI must render [priceString] verbatim and
/// never format [rawPrice] itself.
class BillingProduct {
  const BillingProduct({
    required this.id,
    required this.title,
    required this.priceString,
    required this.rawPrice,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String priceString;
  final double rawPrice;
  final String currencyCode;
}

/// Everything the user can buy, resolved from the live offering. Any field
/// can be null if that product is missing/unapproved in a given storefront.
class BillingOfferings {
  const BillingOfferings({
    this.tips = const [],
    this.monthly,
    this.yearly,
  });

  /// Tip products, ordered small to large.
  final List<BillingProduct> tips;
  final BillingProduct? monthly;
  final BillingProduct? yearly;

  bool get isEmpty => tips.isEmpty && monthly == null && yearly == null;
}

/// Snapshot of what the user has unlocked. Tips grant nothing here.
class SupporterStatus {
  const SupporterStatus({
    required this.isSupporter,
    this.activePlan,
    this.expiresAt,
  });

  const SupporterStatus.none()
      : isSupporter = false,
        activePlan = null,
        expiresAt = null;

  final bool isSupporter;

  /// Which supporter plan is active, when derivable; carries the
  /// renewal/expiry date.
  final SupporterPlan? activePlan;
  final DateTime? expiresAt;
}

/// Result of a purchase or restore attempt. Kept coarse on purpose — the UI
/// only needs to distinguish "thank you", "user backed out", and "show this
/// error".
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

class PurchaseSucceeded extends PurchaseOutcome {
  const PurchaseSucceeded(this.status);

  /// Entitlement state after the purchase (unchanged for tips).
  final SupporterStatus status;
}

/// User cancelled the native sheet — not an error, show nothing.
class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

class PurchaseFailed extends PurchaseOutcome {
  const PurchaseFailed(this.message);
  final String message;
}

/// Store-agnostic billing port. Implementations must degrade gracefully when
/// not configured (no API key): [isConfigured] is false and reads return
/// empty/none rather than throwing, so the app runs identically with billing
/// switched off.
abstract class BillingGateway {
  /// True once a valid RevenueCat key was supplied and [configure] ran.
  bool get isConfigured;

  /// Initialise the SDK. Safe to call once at startup; a no-op when no key.
  Future<void> configure();

  /// Live offering, or null when unavailable/unconfigured.
  Future<BillingOfferings?> loadOfferings();

  /// Current entitlement snapshot ([SupporterStatus.none] when unconfigured).
  Future<SupporterStatus> currentStatus();

  /// Pushes a new snapshot whenever the store reports a change.
  Stream<SupporterStatus> statusChanges();

  /// Buy a product by its [BillingIds] identifier.
  Future<PurchaseOutcome> purchase(String productId);

  /// Restore prior subscription purchases.
  Future<PurchaseOutcome> restore();
}

/// Inert gateway used when billing is disabled (no key). Lets the whole app —
/// including tests — run without touching the stores.
class DisabledBillingGateway implements BillingGateway {
  const DisabledBillingGateway();

  @override
  bool get isConfigured => false;

  @override
  Future<void> configure() async {}

  @override
  Future<BillingOfferings?> loadOfferings() async => null;

  @override
  Future<SupporterStatus> currentStatus() async => const SupporterStatus.none();

  @override
  Stream<SupporterStatus> statusChanges() => const Stream.empty();

  @override
  Future<PurchaseOutcome> purchase(String productId) async =>
      const PurchaseFailed('Purchases are not available right now.');

  @override
  Future<PurchaseOutcome> restore() async =>
      const PurchaseFailed('Purchases are not available right now.');
}
