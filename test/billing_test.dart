import 'package:cleartray/core/billing.dart';
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

  group('SupporterStatus', () {
    test('none() is empty', () {
      const s = SupporterStatus.none();
      expect(s.isSupporter, isFalse);
      expect(s.activePlan, isNull);
      expect(s.expiresAt, isNull);
    });
  });
}
