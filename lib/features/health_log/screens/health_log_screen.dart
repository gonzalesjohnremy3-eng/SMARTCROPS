import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_back_button.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/health_log/domain/health_log_statistics.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;

class HealthLogScreen extends StatefulWidget {
  const HealthLogScreen({super.key});

  @override
  State<HealthLogScreen> createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends State<HealthLogScreen> {
  String? _selectedScanId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const LoadingState();
          }
          if (service.errorMessage != null) {
            return ErrorState(
              message: service.errorMessage!,
              onRetry: service.initializeUserData,
            );
          }

          final scans = service.scanHistory;
          final statistics = healthLogStatistics(scans);

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  scans.isNotEmpty &&
                  constraints.maxWidth >= AppLayout.breakpoints['expanded']!;
              final selected = scans.isEmpty
                  ? null
                  : scans.firstWhere(
                      (scan) => scan.id == _selectedScanId,
                      orElse: () => scans.first,
                    );

              final list = SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    _gutter,
                    AppSpacing.s4,
                    _gutter,
                    AppSpacing.s10,
                  ),
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      l10n.healthLogTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s5),
                    if (scans.isEmpty)
                      const _EmptyState()
                    else ...[
                      _SeasonSummary(
                        scans: statistics.scans,
                        healthy: statistics.healthy,
                        atRisk: statistics.atRisk,
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      ..._months(context, scans, selected!, wide, l10n, theme),
                    ],
                  ],
                ),
              );

              if (!wide) {
                return list;
              }

              return Row(
                children: [
                  Expanded(flex: 4, child: list),
                  const VerticalDivider(
                    width: 1,
                    color: AppColors.borderSubtle,
                  ),
                  Expanded(
                    flex: 6,
                    child: SafeArea(
                      bottom: false,
                      child: ScanDetailContent(
                        key: const Key('health-log-detail'),
                        scan: selected!,
                        l10n: l10n,
                        theme: theme,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _months(
    BuildContext context,
    List<ScanHistoryItem> scans,
    ScanHistoryItem selected,
    bool wide,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final loc = MaterialLocalizations.of(context);
    final months = <DateTime, List<ScanHistoryItem>>{};
    for (final scan in scans) {
      final d = scan.scannedAt;
      months.putIfAbsent(DateTime(d.year, d.month), () => []).add(scan);
    }

    return [
      for (final month in months.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s2),
          child: Text(
            loc.formatMonthYear(month.key),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Fraunces',
              color: AppColors.textPrimary,
            ),
          ),
        ),
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
              for (var i = 0; i < month.value.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.s4,
                    endIndent: AppSpacing.s4,
                    color: AppColors.borderSubtle,
                  ),
                _ScanRow(
                  key: ValueKey('health-log-scan-${month.value[i].id}'),
                  scan: month.value[i],
                  selected: wide && month.value[i].id == selected.id,
                  onTap: () {
                    setState(() => _selectedScanId = month.value[i].id);
                    if (!wide) {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.paper,
                        builder: (_) => SafeArea(
                          child: ScanDetailContent(
                            scan: month.value[i],
                            l10n: l10n,
                            theme: theme,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
      ],
    ];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Column(
        children: [
          const ReticleFrame(
            padding: EdgeInsets.all(AppSpacing.s5),
            child: Icon(
              Icons.healing_outlined,
              color: AppColors.canopy,
              size: AppSpacing.s10,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            l10n.healthLogEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s6),
          PillButton(
            label: l10n.homeScanCta,
            onPressed: () => context.go('/scan'),
          ),
        ],
      ),
    );
  }
}

class _SeasonSummary extends StatelessWidget {
  const _SeasonSummary({
    required this.scans,
    required this.healthy,
    required this.atRisk,
  });

  final int scans;
  final int healthy;
  final int atRisk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s5,
          horizontal: AppSpacing.s2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Stat(
                label: l10n.healthLogScans,
                value: '$scans',
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: l10n.healthLogHealthy,
                value: '$healthy',
                color: AppColors.statusHealthy,
              ),
            ),
            Expanded(
              child: _Stat(
                label: l10n.healthLogAtRisk,
                value: '$atRisk',
                color: AppColors.clay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontFamily: 'Fraunces',
            color: color,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

(String, Color, Color) _severityStyle(
  AppLocalizations l10n,
  DiagnosisSeverity severity,
) => switch (severity) {
  DiagnosisSeverity.healthy => (
    l10n.severityHealthy,
    AppColors.statusHealthy,
    AppColors.statusHealthySurface,
  ),
  DiagnosisSeverity.watch => (
    l10n.severityWatch,
    AppColors.palay,
    AppColors.statusWarningSurface,
  ),
  DiagnosisSeverity.atRisk => (
    l10n.severityAtRisk,
    AppColors.clay,
    AppColors.statusCriticalSurface,
  ),
};

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({
    required this.label,
    required this.color,
    required this.surface,
  });

  final String label;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3 - 2,
          vertical: AppSpacing.s1,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({
    super.key,
    required this.scan,
    required this.selected,
    required this.onTap,
  });

  final ScanHistoryItem scan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (label, color, surface) = _severityStyle(
      l10n,
      diagnosisSeverity(scan.diseaseDetected),
    );

    return Material(
      color: selected ? AppColors.mist : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppLayout.touchTarget,
                height: AppLayout.touchTarget,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppRadius.card - 4),
                ),
                child: Icon(Icons.eco_outlined, color: color),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.commonCrop,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      scan.diseaseDetected,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${scan.confidenceScore.round()}% · '
                      '${MaterialLocalizations.of(context).formatShortMonthDay(scan.scannedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: [
                        _SeverityPill(
                          label: label,
                          color: color,
                          surface: surface,
                        ),
                        if (scan.source == demoScanSource)
                          _SeverityPill(
                            label: l10n.scanDemoBannerTitle,
                            color: AppColors.textSecondary,
                            surface: AppColors.mist,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanDetailContent extends StatelessWidget {
  const ScanDetailContent({
    super.key,
    required this.scan,
    required this.l10n,
    required this.theme,
  });

  final ScanHistoryItem scan;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (label, color, surface) = _severityStyle(
      l10n,
      diagnosisSeverity(scan.diseaseDetected),
    );
    final loc = MaterialLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scanResultDiagnosis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    scan.diseaseDetected,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Fraunces',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    '${scan.commonCrop} · ${loc.formatMediumDate(scan.scannedAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SeverityPill(
                        label: label,
                        color: color,
                        surface: AppColors.surfaceRaised,
                      ),
                      Text(
                        '${l10n.healthLogConfidence}: ${scan.confidenceScore.round()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (scan.source == demoScanSource)
                        _SeverityPill(
                          label: l10n.scanDemoBannerTitle,
                          color: AppColors.textSecondary,
                          surface: AppColors.surfaceRaised,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            l10n.scanResultTreatmentSteps,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Fraunces',
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          for (var i = 0; i < scan.recommendedActions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.s6,
                    height: AppSpacing.s6,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.mist,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.canopy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Text(
                      '${scan.recommendedActions[i]}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
