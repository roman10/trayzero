import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/billing_controller.dart';
import '../../core/billing.dart';
import '../../l10n/gen/app_localizations.dart';
import 'legal_links.dart';
import 'settings_tiles.dart';

/// Support: optional tips + supporter purchases. Nothing here gates a
/// feature - tips are consumable thank-yous and the supporter entitlement
/// only unlocks cosmetic perks. The screen degrades to an "unavailable"
/// note when billing is off or the offering can't load.
///
/// The Privacy policy / Terms of use links must stay on this screen: App
/// Store guideline 3.1.2c requires them inside the subscription purchase flow.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final offeringsAsync = ref.watch(billingOfferingsProvider);
    final status = ref.watch(supporterStatusProvider).valueOrNull;
    final isSupporter = status?.isSupporter ?? false;
    final operation = ref.watch(billingOperationProvider);
    ref.listen(billingOperationProvider, (_, next) {
      if (next == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && ref.read(billingOperationProvider) == next) {
          next.trace.mark('feedback_frame');
        }
      });
    });

    final children = <Widget>[
      Text(l10n.supportIntro),
      const SizedBox(height: 16),
      if (operation != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            liveRegion: true,
            child: Text(
              operation.isRestoring
                  ? l10n.supportRestoring
                  : l10n.supportOpeningStore(
                      Theme.of(context).platform == TargetPlatform.iOS ||
                              Theme.of(context).platform == TargetPlatform.macOS
                          ? 'App Store'
                          : 'Google Play',
                    ),
            ),
          ),
        ),
    ];

    if (isSupporter && status != null) {
      children.add(_supporterBadge(context, l10n, status));
      children.add(const SizedBox(height: 16));
    }

    children.addAll(
      offeringsAsync.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
        error: (error, _) {
          debugPrint('[billing] offerings load failed: $error');
          return [_unavailableNote(l10n)];
        },
        data: (offerings) {
          if (offerings == null || offerings.isEmpty) {
            return [_unavailableNote(l10n)];
          }
          return _purchaseTiles(
            context,
            ref,
            l10n,
            offerings,
            isSupporter,
            operation,
          );
        },
      ),
    );

    children.add(const SizedBox(height: 8));
    children.add(
      Align(
        child: TextButton.icon(
          icon: operation?.isRestoring == true
              ? const _PurchaseSpinner()
              : const Icon(Icons.restore),
          label: Text(l10n.supportRestore),
          onPressed: operation == null
              ? () => _restorePurchases(context, ref, l10n)
              : null,
        ),
      ),
    );
    children.add(
      Text(
        l10n.supportRestoreSubtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );

    // Functional links to the privacy policy and Terms of Use (EULA), required
    // inside the purchase flow for auto-renewable subscriptions (App Store).
    children.add(const SizedBox(height: 8));
    children.add(const LegalLinksRow());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: children,
      ),
    );
  }
}

Widget _unavailableNote(AppLocalizations l10n) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Text(l10n.supportUnavailable),
);

Widget _supporterBadge(
  BuildContext context,
  AppLocalizations l10n,
  SupporterStatus status,
) {
  final theme = Theme.of(context);
  final label = switch (status.activePlan) {
    SupporterPlan.yearly => l10n.supportBadgeYearly,
    SupporterPlan.monthly => l10n.supportBadgeMonthly,
    null => l10n.supportBadgeGeneric,
  };
  return SettingsGroup(
    children: [
      ListTile(
        minTileHeight: 56,
        leading: Icon(Icons.favorite, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.titleSmall),
        subtitle: Text(l10n.supportBadgeSubtitle),
      ),
    ],
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.highlighted = false,
    this.busy = false,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final bool highlighted;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        enabled: onTap != null,
        child: Material(
          color: highlighted
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: highlighted
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 72),
              child: Row(
                children: [
                  if (busy)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(child: _PurchaseSpinner()),
                    )
                  else
                    const SettingsIconBadge(
                      icon: Icons.workspace_premium_outlined,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseSpinner extends StatelessWidget {
  const _PurchaseSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}

List<Widget> _purchaseTiles(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  BillingOfferings offerings,
  bool isSupporter,
  BillingOperation? operation,
) {
  final tiles = <Widget>[];
  final yearly = offerings.yearly;
  final monthly = offerings.monthly;

  // Recurring plans are hidden once already a supporter, to avoid an
  // accidental second subscription. Tips stay available to everyone.
  if (!isSupporter) {
    if (yearly != null) {
      tiles.add(
        _PlanCard(
          title: l10n.supportSupporterYearly,
          subtitle: l10n.supportSupporterYearlySubtitle(yearly.priceString),
          badge: l10n.supportBestValue,
          highlighted: true,
          busy: operation?.productId == BillingIds.supporterYearly,
          onTap: operation == null
              ? () => _purchasePlan(context, ref, l10n, SupporterPlan.yearly)
              : null,
        ),
      );
    }
    if (monthly != null) {
      tiles.add(
        _PlanCard(
          title: l10n.supportSupporterMonthly,
          subtitle: l10n.supportSupporterMonthlySubtitle(monthly.priceString),
          busy: operation?.productId == BillingIds.supporterMonthly,
          onTap: operation == null
              ? () => _purchasePlan(context, ref, l10n, SupporterPlan.monthly)
              : null,
        ),
      );
    }
    if (yearly != null || monthly != null) {
      tiles.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.supportAutoRenewNote,
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
  }

  if (offerings.tips.isNotEmpty) {
    tiles.add(
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          l10n.supportTipHeader,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
    tiles.add(
      Row(
        children: [
          for (final (i, tip) in offerings.tips.indexed) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: _tipButton(context, ref, l10n, tip, operation)),
          ],
        ],
      ),
    );
  }

  return tiles;
}

Widget _tipButton(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  BillingProduct tip,
  BillingOperation? operation,
) {
  final (label, tier) = switch (tip.id) {
    BillingIds.tipSmall => (l10n.supportTipSmall, TipTier.small),
    BillingIds.tipLarge => (l10n.supportTipLarge, TipTier.large),
    _ => (tip.title, TipTier.small),
  };
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 72),
      padding: const EdgeInsets.all(12),
    ),
    onPressed: operation == null
        ? () => _purchaseTip(context, ref, l10n, tier)
        : null,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 24,
          child: Center(
            child: operation?.productId == BillingIds.forTip(tier)
                ? const _PurchaseSpinner()
                : const Icon(Icons.local_cafe_outlined),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center),
        Text(
          tip.priceString,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

Future<void> _purchaseTip(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  TipTier tier,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref.read(billingControllerProvider).tip(tier);
  _showOutcome(messenger, l10n, outcome, l10n.supportThanksTip);
}

Future<void> _purchasePlan(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  SupporterPlan plan,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref
      .read(billingControllerProvider)
      .becomeSupporter(plan);
  _showOutcome(messenger, l10n, outcome, l10n.supportThanksSupporter);
}

Future<void> _restorePurchases(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref.read(billingControllerProvider).restore();
  if (!messenger.mounted) return;
  switch (outcome) {
    case PurchaseSucceeded(:final status):
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status.isSupporter ? l10n.supportRestored : l10n.supportRestoreNone,
          ),
        ),
      );
    case PurchaseFailed(:final reason):
      messenger.showSnackBar(
        SnackBar(content: Text(_failureMessage(l10n, reason))),
      );
    case PurchaseCancelled():
      break;
  }
}

String _failureMessage(AppLocalizations l10n, PurchaseFailure reason) =>
    switch (reason) {
      PurchaseFailure.unavailable => l10n.purchaseErrUnavailable,
      PurchaseFailure.productsUnavailable => l10n.purchaseErrProducts,
      PurchaseFailure.optionUnavailable => l10n.purchaseErrOption,
      PurchaseFailure.network => l10n.purchaseErrNetwork,
      PurchaseFailure.notAllowed => l10n.purchaseErrNotAllowed,
      PurchaseFailure.pending => l10n.purchaseErrPending,
      PurchaseFailure.alreadyOwned => l10n.purchaseErrAlreadyOwned,
      PurchaseFailure.storeProblem => l10n.purchaseErrStore,
      PurchaseFailure.unknown => l10n.purchaseErrUnknown,
    };

void _showOutcome(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  PurchaseOutcome outcome,
  String successMessage,
) {
  if (!messenger.mounted) return;
  switch (outcome) {
    case PurchaseSucceeded():
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    case PurchaseFailed(:final reason):
      messenger.showSnackBar(
        SnackBar(content: Text(_failureMessage(l10n, reason))),
      );
    case PurchaseCancelled():
      break;
  }
}
