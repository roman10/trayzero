// FOSS build stub — DO NOT EDIT FOR STORE BUILDS.
//
// `tool/build_foss_apk.sh` copies this file over
// `lib/infrastructure/revenuecat_billing_gateway.dart` (and drops the
// `purchases_flutter` dependency from pubspec.yaml) to produce a build that
// contains ZERO RevenueCat / proprietary billing code, for FOSS channels such
// as IzzyOnDroid. The default Play / App Store builds use the real gateway and
// are never affected — the script restores the originals via an EXIT trap.
//
// It mirrors the real gateway's *public* surface so `billing_providers.dart`
// compiles unchanged: `revenueCatApiKeyForPlatform()` returns '' (so the
// provider always selects [DisabledBillingGateway]), and the class below is an
// inert no-op kept only to satisfy the reference. No `purchases_flutter` import.

import '../core/billing.dart';

/// FOSS build: no billing keys ship, so this always returns ''. The
/// `billingGatewayProvider` then resolves to [DisabledBillingGateway].
String revenueCatApiKeyForPlatform() => '';

/// Inert stand-in for the RevenueCat gateway in FOSS builds. Never constructed
/// at runtime (the empty key short-circuits to [DisabledBillingGateway]); it
/// exists only so the static reference in `billing_providers.dart` compiles
/// without pulling in the proprietary SDK.
class RevenueCatBillingGateway extends DisabledBillingGateway {
  RevenueCatBillingGateway({required this.apiKey});

  final String apiKey;

  void dispose() {}
}
