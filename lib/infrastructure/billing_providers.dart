import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/billing.dart';
import 'play_billing_gateway.dart';
import 'storekit_billing_gateway.dart';

/// App-wide billing gateway. Override in tests to inject a fake.
final billingGatewayProvider = Provider<BillingGateway>((ref) {
  if (Platform.isAndroid) {
    final gateway = PlayBillingGateway();
    ref.onDispose(gateway.dispose);
    return gateway;
  }
  if (Platform.isIOS) {
    final gateway = StoreKitBillingGateway();
    ref.onDispose(gateway.dispose);
    return gateway;
  }
  return const DisabledBillingGateway();
});
