import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/billing.dart';
import 'revenuecat_billing_gateway.dart';

/// App-wide billing gateway. Backed by RevenueCat when a platform key is
/// supplied via --dart-define, otherwise a no-op [DisabledBillingGateway] so
/// the app runs identically with billing switched off. Override in tests to
/// inject a fake.
final billingGatewayProvider = Provider<BillingGateway>((ref) {
  final key = revenueCatApiKeyForPlatform();
  if (key.isEmpty) return const DisabledBillingGateway();
  final gateway = RevenueCatBillingGateway(apiKey: key);
  ref.onDispose(gateway.dispose);
  return gateway;
});
