import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

const _gutter = AppSpacing.s5;

class AgriProManageScreen extends StatelessWidget {
  const AgriProManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: Consumer<AgriProEntitlement>(
          builder: (context, entitlement, child) {
            final isPro = entitlement.isPro;
            final expiry = entitlement.expiresAt;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppLayout.maxWidths['reading']!,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    _gutter,
                    AppSpacing.s4,
                    _gutter,
                    AppSpacing.s10,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: l10n.back,
                        onPressed: () => context.pop(),
                        style: IconButton.styleFrom(
                          fixedSize: const Size.square(AppLayout.touchTarget),
                          backgroundColor: AppColors.surfaceSunken,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s5),
                    Text(
                      l10n.agriProManageTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s5),
                    if (entitlement.isLoading)
                      const SizedBox(height: 240, child: LoadingState())
                    else if (isPro)
                      _ProPlan(expiry: expiry)
                    else
                      const _FreePlan(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProPlan extends StatelessWidget {
  const _ProPlan({required this.expiry});

  final DateTime? expiry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.canopy,
            borderRadius: BorderRadius.circular(AppRadius.hero),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: AppColors.textInverse,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n.agriProManageCurrentPlan,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  l10n.agriProPlanActive,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Fraunces',
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  l10n.agriProManageProSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: AppColors.forestInk.withValues(alpha: 0.06),
                blurRadius: AppSpacing.s4,
                offset: const Offset(0, AppSpacing.s1),
              ),
            ],
          ),
          child: Column(
            children: [
              _DetailRow(
                label: l10n.agriProManageRenewal,
                value: expiry != null
                    ? loc.formatMediumDate(expiry!)
                    : l10n.agriProRenewalNever,
              ),
              const Divider(
                height: 1,
                indent: AppSpacing.s4,
                endIndent: AppSpacing.s4,
                color: AppColors.borderSubtle,
              ),
              _DetailRow(
                label: l10n.agriProManageBilling,
                value: l10n.agriProManageBilledBy,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: AppSpacing.s5,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: Text(
                l10n.agriProManageCancelHow,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s6),
        OutlinedButton(
          onPressed: () => _restore(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(
              AppLayout.touchTarget + AppSpacing.s2,
            ),
            foregroundColor: AppColors.canopy,
            shape: const StadiumBorder(),
          ),
          child: Text(l10n.agriProRestore),
        ),
      ],
    );
  }

  Future<void> _restore(BuildContext context) async {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FreePlan extends StatelessWidget {
  const _FreePlan();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.hero),
            boxShadow: [
              BoxShadow(
                color: AppColors.forestInk.withValues(alpha: 0.06),
                blurRadius: AppSpacing.s4,
                offset: const Offset(0, AppSpacing.s1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.agriProManageCurrentPlan,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  l10n.agriProManageUpgradeTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Fraunces',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  l10n.agriProManageFreeSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        PillButton(
          label: l10n.agriProManageUpgradeCta,
          onPressed: () => context.push('/pro'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
