import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class AgriProManageScreen extends StatelessWidget {
  const AgriProManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agriProManageTitle)),
      body: Consumer<AgriProEntitlement>(
        builder: (context, entitlement, child) {
          if (entitlement.isLoading) {
            return const LoadingState();
          }

          final isPro = entitlement.isPro;
          final expiry = entitlement.expiresAt;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.agriProManageCurrentPlan,
                          style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        isPro ? l10n.agriProTitle : l10n.agriProPlanFree,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (isPro) ...[
                        _Row(
                          label: l10n.agriProManageRenewal,
                          value: expiry != null
                              ? '${expiry.day}/${expiry.month}/${expiry.year}'
                              : l10n.agriProRenewalNever,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: l10n.agriProManageBilling,
                          value: l10n.agriProManageBilledBy,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.agriProManageProSummary,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.agriProManageCancelHow,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        Text(
                          l10n.agriProManageUpgradeTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.agriProManageFreeSummary,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => context.push('/pro'),
                            child: Text(l10n.agriProManageUpgradeCta),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isPro) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final l10n = AppLocalizations.of(context);
                    final billing = context.read<BillingRepository>();
                    final outcome = await billing.restore();
                    if (!context.mounted) return;
                    final message = switch (outcome) {
                      BillingSucceeded() => l10n.agriProPurchaseRestored,
                      BillingUnavailable() => l10n.billingNotConfigured,
                      BillingFailed() => l10n.agriProPurchaseFailed,
                    };
                    if (outcome is BillingSucceeded) {
                      await context.read<AgriProEntitlement>().refresh();
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  child: Text(l10n.agriProRestore),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.theme});

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: theme.textTheme.labelMedium),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
