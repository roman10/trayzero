// Copied over lib/infrastructure/billing_providers.dart for the FOSS build.
import 'package:cleartray/core/billing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final billingGatewayProvider = Provider<BillingGateway>(
  (_) => const DisabledBillingGateway(),
);
