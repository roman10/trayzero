import 'dart:async';

import 'package:cleartray/application/billing_controller.dart';
import 'package:cleartray/core/billing.dart';
import 'package:cleartray/infrastructure/billing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillingIds', () {
    test('maps tip tiers to store ids', () {
      expect(BillingIds.forTip(TipTier.small), 'tip_small');
      expect(BillingIds.forTip(TipTier.large), 'tip_large');
    });

    test('maps supporter plans to store ids', () {
      expect(BillingIds.forPlan(SupporterPlan.monthly), 'supporter_monthly');
      expect(BillingIds.forPlan(SupporterPlan.yearly), 'supporter_yearly');
    });
  });

  group('DisabledBillingGateway', () {
    const gateway = DisabledBillingGateway();

    test('is not configured and reads degrade to none/empty', () async {
      expect(gateway.isConfigured, isFalse);
      await gateway.configure();
      expect(await gateway.loadOfferings(), isNull);
      expect((await gateway.currentStatus()).isSupporter, isFalse);
    });

    test('purchase and restore fail softly without throwing', () async {
      expect(await gateway.purchase(BillingIds.tipSmall), isA<PurchaseFailed>());
      expect(await gateway.restore(), isA<PurchaseFailed>());
    });
  });

  test('a store update wins over an in-flight initial snapshot', () async {
    final gateway = _DelayedStatusGateway();
    final container = ProviderContainer(
      overrides: [billingGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(gateway.updates.close);
    addTearDown(container.dispose);
    final observed = <SupporterStatus>[];
    container.listen(supporterStatusProvider, (_, next) {
      if (next.valueOrNull case final status?) observed.add(status);
    });

    const renewed = SupporterStatus(
      isSupporter: true,
      activePlan: SupporterPlan.yearly,
    );
    gateway.updates.add(renewed);
    expect(await container.read(supporterStatusProvider.future), renewed);

    gateway.initial.complete(const SupporterStatus.none());
    // Let the initial read and any resulting stream event reach Riverpod.
    await Future<void>.delayed(Duration.zero);

    expect(observed, [renewed]);
    expect(container.read(supporterStatusProvider).valueOrNull, renewed);
  });

  group('SupporterStatus', () {
    test('none() is empty', () {
      const s = SupporterStatus.none();
      expect(s.isSupporter, isFalse);
      expect(s.activePlan, isNull);
      expect(s.expiresAt, isNull);
    });
  });
}

class _DelayedStatusGateway extends DisabledBillingGateway {
  final initial = Completer<SupporterStatus>();
  final updates = StreamController<SupporterStatus>();

  @override
  Future<SupporterStatus> currentStatus() => initial.future;

  @override
  Stream<SupporterStatus> statusChanges() => updates.stream;
}
