import 'package:cleartray/core/billing.dart';
import 'package:cleartray/infrastructure/play_billing_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.cleartray/play_billing_test');
  const codec = StandardMethodCodec();
  final messenger = binding.defaultBinaryMessenger;
  late PlayBillingGateway gateway;
  String? activeProduct;
  String? refreshError;
  String? purchaseError;
  late List<MethodCall> calls;

  setUp(() {
    gateway = PlayBillingGateway(channel: channel);
    activeProduct = null;
    refreshError = null;
    purchaseError = null;
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'refresh':
          if (refreshError case final code?) {
            throw PlatformException(code: code);
          }
          return {'activeProduct': activeProduct};
        case 'purchase':
          if (purchaseError case final code?) {
            throw PlatformException(code: code);
          }
          return true;
        case 'offerings':
          return [
            {
              'id': BillingIds.supporterYearly,
              'title': 'Supporter',
              'priceString': 'SGD\u00a014,98',
              'rawPrice': 14.98,
              'currencyCode': 'SGD',
            },
          ];
      }
      throw MissingPluginException();
    });
  });

  tearDown(() {
    gateway.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  Future<void> storeUpdate() => messenger.handlePlatformMessage(
    channel.name,
    codec.encodeMethodCall(const MethodCall('purchasesChanged')),
    (_) {},
  );

  test('startup finds a pre-existing subscription without Restore', () async {
    activeProduct = BillingIds.supporterMonthly;
    final change = gateway.statusChanges().first;
    await gateway.configure();
    expect((await change).activePlan, SupporterPlan.monthly);
    expect((await gateway.currentStatus()).isSupporter, isTrue);
    expect(calls.map((call) => call.method), ['refresh']);
  });

  test('store updates and restore use the same ownership snapshot', () async {
    await gateway.configure();
    expect((await gateway.currentStatus()).isSupporter, isFalse);
    activeProduct = BillingIds.supporterYearly;
    final change = gateway.statusChanges().first;
    await storeUpdate();
    expect((await change).activePlan, SupporterPlan.yearly);
    refreshError = 'network';
    expect(
      await gateway.restore(),
      isA<PurchaseFailed>().having(
        (e) => e.reason,
        'reason',
        PurchaseFailure.network,
      ),
    );
    expect((await gateway.currentStatus()).isSupporter, isTrue);
    refreshError = null;
    activeProduct = null;
    final expired = await gateway.restore() as PurchaseSucceeded;
    expect(expired.status.isSupporter, isFalse);
  });

  test('foreground refresh recovers a completed pending purchase', () async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    purchaseError = 'pending';
    expect(
      await gateway.purchase(BillingIds.supporterMonthly),
      isA<PurchaseFailed>().having(
        (e) => e.reason,
        'reason',
        PurchaseFailure.pending,
      ),
    );
    expect((await gateway.currentStatus()).isSupporter, isFalse);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    activeProduct = BillingIds.supporterMonthly;
    final change = gateway.statusChanges().first;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect((await change).isSupporter, isTrue);
  });

  test('cancel maps silently and repeat tips never change the badge', () async {
    purchaseError = 'cancelled';
    expect(
      await gateway.purchase(BillingIds.tipSmall),
      isA<PurchaseCancelled>(),
    );
    purchaseError = null;
    for (var i = 0; i < 2; i++) {
      final tip =
          await gateway.purchase(BillingIds.tipSmall) as PurchaseSucceeded;
      expect(tip.status.isSupporter, isFalse);
    }
    final purchases = calls.where((call) => call.method == 'purchase');
    expect(
      purchases.map((call) => call.arguments),
      List.filled(3, {'id': BillingIds.tipSmall}),
    );
  });

  test('offerings preserve the exact store-formatted price', () async {
    final offerings = (await gateway.loadOfferings())!;
    expect(offerings.yearly?.priceString, 'SGD\u00a014,98');
    expect(offerings.monthly, isNull);
    expect(offerings.tips, isEmpty);
  });
}
