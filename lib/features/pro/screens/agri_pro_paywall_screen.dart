import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class AgriProPaywallScreen extends StatefulWidget {
  const AgriProPaywallScreen({super.key, this.fromQuota = false});

  final bool fromQuota;

  @override
  State<AgriProPaywallScreen> createState() => _AgriProPaywallScreenState();
}

class _AgriProPaywallScreenState extends State<AgriProPaywallScreen> {
  AgriProPlanId _selected = AgriProPlanId.seasonal;
  bool _isBusy = false;

  AgriProPlan get _selectedPlan =>
      _plans.firstWhere((plan) => plan.id == _selected);

  List<AgriProPlan> get _plans => agriProPlans;

  Future<void> _startPurchase() async {
    setState(() => _isBusy = true);
    final l10n = AppLocalizations.of(context);
    final billing = context.read<BillingRepository>();
    final outcome = await billing.purchase(_selected);
    if (!mounted) return;

    switch (outcome) {
      case BillingSucceeded():
        await context.read<AgriProEntitlement>().refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.agriProUnlocked)),
        );
        Navigator.of(context).maybePop();
      case BillingUnavailable():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.billingNotConfigured)),
        );
      case BillingFailed():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.agriProPurchaseFailed)),
        );
    }

    if (mounted) {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final used = scansThisWeek(service.scanHistory, DateTime.now());
    final selected = _selectedPlan;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agriProTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.agriProHeadline, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (widget.fromQuota) ...[
            Text(
              l10n.agriProQuotaContext(used, 5),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            l10n.agriProFreePlanSummary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureRow(
                    icon: Icons.all_inclusive,
                    label: l10n.agriProFeatureUnlimited,
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.bolt_outlined,
                    label: l10n.agriProFeaturePriority,
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.show_chart,
                    label: l10n.agriProFeatureTrends,
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.water_drop_outlined,
                    label: l10n.agriProFeatureWeather,
                    theme: theme,
                  ),
                  _FeatureRow(
                    icon: Icons.cloud_download_outlined,
                    label: l10n.agriProFeatureOffline,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._plans.map((plan) => _PlanCard(
                plan: plan,
                selected: plan.id == _selected,
                l10n: l10n,
                theme: theme,
                onTap: () => setState(() => _selected = plan.id),
              )),
          const SizedBox(height: 8),
          Text(
            selected.id == AgriProPlanId.seasonal
                ? l10n.agriProPlanRenewsSeasonal
                : l10n.agriProPlanRenewsMonthly,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            l10n.agriProCancelAnytime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isBusy ? null : _startPurchase,
              child: _isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.startAgriPro),
            ),
          ),
          TextButton(
            onPressed: _isBusy ? null : () => Navigator.of(context).maybePop(),
            child: Text(l10n.notNow),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.agriProPaymentNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label, required this.theme});

  final IconData icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.l10n,
    required this.theme,
    required this.onTap,
  });

  final AgriProPlan plan;
  final bool selected;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSeasonal = plan.id == AgriProPlanId.seasonal;

    return Card(
      color: selected ? theme.colorScheme.surfaceContainerHighest : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isSeasonal ? l10n.agriProPlanSeasonal : l10n.agriProPlanMonthly,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (isSeasonal) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              l10n.agriProSavePercent,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSeasonal
                          ? l10n.agriProPlanSeasonTagline
                          : l10n.agriProPlanMonthlyTagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSeasonal ? l10n.agriProPriceSeasonal : l10n.agriProPriceMonthly,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (!isSeasonal)
                      Text(
                        l10n.agriProPerDay,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
