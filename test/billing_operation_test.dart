import 'dart:async';

import 'package:cleartray/application/billing_controller.dart';
import 'package:cleartray/core/billing.dart';
import 'package:cleartray/core/billing_diagnostics.dart';
import 'package:cleartray/features/settings/support_screen.dart';
import 'package:cleartray/infrastructure/billing_providers.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Gateway extends DisabledBillingGateway {
  final calls = <String>[];
  Completer<PurchaseOutcome> pending = Completer<PurchaseOutcome>();

  @override
  Future<PurchaseOutcome> purchase(String productId) {
    calls.add(productId);
    BillingTrace.current?.mark('sdk_call_started');
    return pending.future;
  }

  @override
  Future<PurchaseOutcome> restore() {
    calls.add('restore');
    return pending.future;
  }

  @override
  Future<BillingOfferings?> loadOfferings() async => BillingOfferings(
    tips: [_product(BillingIds.tipSmall), _product(BillingIds.tipLarge)],
    yearly: _product(BillingIds.supporterYearly),
    monthly: _product(BillingIds.supporterMonthly),
  );
}

BillingProduct _product(String id) => BillingProduct(
  id: id,
  title: id,
  priceString: '\$1.00',
  rawPrice: 1,
  currencyCode: 'USD',
);

ProviderContainer _container(_Gateway gateway) {
  final container = ProviderContainer(
    overrides: [billingGatewayProvider.overrideWithValue(gateway)],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(ProviderContainer container, {bool showSupport = true}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: showSupport ? const SupportScreen() : const Scaffold(),
      ),
    );

void main() {
  test('one lock covers same-frame tips, subscriptions, and restore', () async {
    final gateway = _Gateway();
    final container = _container(gateway);
    final controller = container.read(billingControllerProvider);
    final first = controller.tip(TipTier.small);
    expect(
      container.read(billingOperationProvider)?.productId,
      BillingIds.tipSmall,
    );
    expect(await controller.tip(TipTier.large), isA<PurchaseCancelled>());
    expect(
      await controller.becomeSupporter(SupporterPlan.yearly),
      isA<PurchaseCancelled>(),
    );
    expect(await controller.restore(), isA<PurchaseCancelled>());
    expect(gateway.calls, [BillingIds.tipSmall]);
    gateway.pending.complete(const PurchaseCancelled());
    await first;
    expect(container.read(billingOperationProvider), isNull);
    gateway.pending = Completer<PurchaseOutcome>();
    final restore = controller.restore();
    expect(container.read(billingOperationProvider)!.isRestoring, isTrue);
    expect(await controller.tip(TipTier.small), isA<PurchaseCancelled>());
    gateway.pending.complete(const PurchaseSucceeded(SupporterStatus.none()));
    await restore;
    expect(gateway.calls, [BillingIds.tipSmall, 'restore']);
    expect(container.read(billingOperationProvider), isNull);
  });

  test(
    'failure, exception, and success all release the lock for retry',
    () async {
      final gateway = _Gateway();
      final container = _container(gateway);
      final controller = container.read(billingControllerProvider);
      for (final result in [
        const PurchaseFailed(PurchaseFailure.network),
        StateError('sensitive raw store error'),
        const PurchaseSucceeded(SupporterStatus.none()),
      ]) {
        gateway.pending = Completer<PurchaseOutcome>();
        final purchase = controller.tip(TipTier.small);
        if (result is PurchaseOutcome) {
          gateway.pending.complete(result);
        } else {
          gateway.pending.completeError(result);
        }
        final outcome = await purchase;
        expect(
          outcome,
          result is PurchaseOutcome ? same(result) : isA<PurchaseFailed>(),
        );
        expect(container.read(billingOperationProvider), isNull);
      }
      expect(gateway.calls, hasLength(3));
    },
  );

  test(
    'disposing the app during an operation does not throw on return',
    () async {
      final gateway = _Gateway();
      final container = ProviderContainer(
        overrides: [billingGatewayProvider.overrideWithValue(gateway)],
      );
      final pending = container
          .read(billingControllerProvider)
          .tip(TipTier.small);
      container.dispose();
      gateway.pending.complete(const PurchaseCancelled());
      expect(await pending, isA<PurchaseCancelled>());
    },
  );

  test('timing span reaches gateway and logs no raw store error', () async {
    final lines = <String>[];
    await runZoned(
      () async {
        final gateway = _Gateway();
        final container = _container(gateway);
        final purchase = container
            .read(billingControllerProvider)
            .tip(TipTier.small);
        gateway.pending.completeError(
          StateError('private receipt/customer data'),
        );
        await purchase;
      },
      zoneSpecification: ZoneSpecification(
        print: (_, _, _, line) => lines.add(line),
      ),
    );
    final output = lines.join('\n');
    expect(output, contains('stage=action_started elapsed_ms='));
    expect(output, contains('stage=sdk_call_started'));
    expect(output, contains('result=exception_StateError'));
    expect(output, isNot(contains('private receipt/customer data')));
  });

  for (final label in [
    'Small tip',
    'Large tip',
    'Supporter — yearly',
    'Supporter — monthly',
  ]) {
    testWidgets('$label gives feedback on next frame and locks all actions', (
      tester,
    ) async {
      final gateway = _Gateway();
      final container = _container(gateway);
      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
      expect(find.text('Opening App Store…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      for (final button in tester.widgetList<OutlinedButton>(
        find.byType(OutlinedButton),
      )) {
        expect(button.onPressed, isNull);
      }
      final restore = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Restore purchases'),
          matching: find.byType(TextButton),
        ),
      );
      expect(restore.onPressed, isNull);
      for (final plan in ['Supporter — yearly', 'Supporter — monthly']) {
        expect(
          tester
              .widget<InkWell>(
                find
                    .ancestor(
                      of: find.text(plan),
                      matching: find.byType(InkWell),
                    )
                    .first,
              )
              .onTap,
          isNull,
        );
      }
      // The app-wide lock survives leaving and returning to Support.
      await tester.pumpWidget(_app(container, showSupport: false));
      await tester.pumpWidget(_app(container));
      await tester.pump();
      expect(find.text('Opening App Store…'), findsOneWidget);
      expect(gateway.calls, hasLength(1));
      // Waiting does not unlock an in-flight native transaction.
      await tester.pump(const Duration(minutes: 1));
      expect(container.read(billingOperationProvider), isNotNull);
      gateway.pending.complete(const PurchaseCancelled());
      await tester.pumpAndSettle();
      expect(find.text('Opening App Store…'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('restore shows progress and failure recovers with an error', (
    tester,
  ) async {
    final gateway = _Gateway();
    final container = _container(gateway);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Restore purchases'));
    await tester.tap(find.text('Restore purchases'));
    await tester.pump();
    expect(find.text('Restoring purchases…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gateway.pending.complete(const PurchaseFailed(PurchaseFailure.network));
    await tester.pumpAndSettle();
    expect(find.text('Restoring purchases…'), findsNothing);
    expect(
      find.text('Network error. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
