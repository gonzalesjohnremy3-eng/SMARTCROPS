import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/scrimmed_image.dart';
import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;

class AgriProPaywallScreen extends StatefulWidget {
  const AgriProPaywallScreen({super.key, this.fromQuota = false});

  final bool fromQuota;

  @override
  State<AgriProPaywallScreen> createState() => _AgriProPaywallScreenState();
}

class _AgriProPaywallScreenState extends State<AgriProPaywallScreen> {
  AgriProPlanId _selected = AgriProPlanId.seasonal;
  bool _isBusy = false;

  List<AgriProPlan> get _plans => agriProPlans;

  Future<void> _startPurchase() async {
    context.trackEvent('purchase_started', params: {'plan': _selected.name});
    setState(() => _isBusy = true);
    final l10n = AppLocalizations.of(context);
    final billing = context.read<BillingRepository>();
    final outcome = await billing.purchase(_selected);
    if (!mounted) return;

    switch (outcome) {
      case BillingSucceeded():
        context.trackEvent(
          'purchase_completed',
          params: {'plan': _selected.name},
        );
        await context.read<AgriProEntitlement>().refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.agriProUnlocked)));
        Navigator.of(context).maybePop();
      case BillingUnavailable():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.billingNotConfigured)));
      case BillingFailed():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.agriProPurchaseFailed)));
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

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: Align(
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
                    onPressed: _isBusy ? null : () => context.pop(),
                    style: IconButton.styleFrom(
                      fixedSize: const Size.square(AppLayout.touchTarget),
                      backgroundColor: AppColors.surfaceSunken,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.hero),
                  child: ScrimmedImage(
                    imagePath: 'assets/images/overlays/pro.webp',
                    scrim: AppColors.forestInk.withValues(alpha: 0.62),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: AppColors.textInverse,
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Text(
                            l10n.agriProHeadline,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Fraunces',
                              color: AppColors.textInverse,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.fromQuota) ...[
                  const SizedBox(height: AppSpacing.s4),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.statusCriticalSurface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.hourglass_bottom_rounded,
                            color: AppColors.clay,
                          ),
                          const SizedBox(width: AppSpacing.s3),
                          Expanded(
                            child: Text(
                              l10n.agriProQuotaContext(used, 5),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s6),
                _Features(),
                const SizedBox(height: AppSpacing.s6),
                _Comparison(),
                const SizedBox(height: AppSpacing.s6),
                for (final plan in _plans) ...[
                  _PlanCard(
                    key: Key('pro-plan-${plan.id.name}'),
                    plan: plan,
                    selected: plan.id == _selected,
                    onTap: () {
                      context.trackEvent(
                        'paywall_plan_selected',
                        params: {'plan': plan.id.name},
                      );
                      setState(() => _selected = plan.id);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s3),
                ],
                const SizedBox(height: AppSpacing.s1),
                Text(
                  _selected == AgriProPlanId.seasonal
                      ? l10n.agriProPlanRenewsSeasonal
                      : l10n.agriProPlanRenewsMonthly,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  l10n.agriProCancelAnytime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s5),
                PillButton(
                  label: l10n.startAgriPro,
                  isLoading: _isBusy,
                  onPressed: _startPurchase,
                ),
                const SizedBox(height: AppSpacing.s2),
                TextButton(
                  onPressed: _isBusy
                      ? null
                      : () {
                          context.trackEvent('paywall_dismissed');
                          Navigator.of(context).maybePop();
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size.fromHeight(AppLayout.touchTarget),
                  ),
                  child: Text(l10n.notNow),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n.agriProPaymentNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DecoratedBox _raised({required Widget child}) => DecoratedBox(
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
  child: child,
);

class _Features extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      (Icons.all_inclusive, l10n.agriProFeatureUnlimited),
      (Icons.bolt_outlined, l10n.agriProFeaturePriority),
      (Icons.show_chart, l10n.agriProFeatureTrends),
      (Icons.water_drop_outlined, l10n.agriProFeatureWeather),
      (Icons.cloud_download_outlined, l10n.agriProFeatureOffline),
    ];

    return _raised(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (icon, label) in features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
                child: Row(
                  children: [
                    Icon(icon, size: AppSpacing.s5, color: AppColors.canopy),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Free vs each Pro plan as stacked rows, so it never needs to scroll sideways.
class _Comparison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      (
        l10n.agriProPlanFree,
        l10n.agriProPriceFree,
        l10n.agriProFreePlanSummary,
      ),
      (
        l10n.agriProPlanMonthly,
        l10n.agriProPriceMonthly,
        l10n.agriProFeatureUnlimited,
      ),
      (
        l10n.agriProPlanSeasonal,
        l10n.agriProPriceSeasonal,
        l10n.agriProFeatureUnlimited,
      ),
    ];
    final theme = Theme.of(context);

    return _raised(
      child: Column(
        key: const Key('pro-comparison-table'),
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.s4,
                endIndent: AppSpacing.s4,
                color: AppColors.borderSubtle,
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.s3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        rows[i].$1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        rows[i].$2,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.canopy,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    rows[i].$3,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final AgriProPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isSeasonal = plan.id == AgriProPlanId.seasonal;

    return Semantics(
      button: true,
      selected: selected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.canopy : AppColors.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.s2,
                          runSpacing: AppSpacing.s1,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              isSeasonal
                                  ? l10n.agriProPlanSeasonal
                                  : l10n.agriProPlanMonthly,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (isSeasonal)
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.statusHealthySurface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s3 - 2,
                                    vertical: AppSpacing.s1,
                                  ),
                                  child: Text(
                                    l10n.agriProSavePercent,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.statusHealthy,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          isSeasonal
                              ? l10n.agriProPlanSeasonTagline
                              : l10n.agriProPlanMonthlyTagline,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          isSeasonal
                              ? l10n.agriProPriceSeasonal
                              : l10n.agriProPriceMonthly,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Fraunces',
                            color: AppColors.canopy,
                          ),
                        ),
                        if (!isSeasonal)
                          Text(
                            l10n.agriProPerDay,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? AppColors.canopy
                        : AppColors.textSecondary,
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
