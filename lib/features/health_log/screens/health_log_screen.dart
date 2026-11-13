import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';

class HealthLogScreen extends StatelessWidget {
  const HealthLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthLogTitle)),
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

          if (scans.isEmpty) {
            return _EmptyState(l10n: l10n, theme: theme);
          }

          final healthyCount = scans
              .where((scan) => diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.healthy)
              .length;
          final atRiskCount = scans
              .where((scan) => diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.atRisk)
              .length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _SeasonSummary(
                  scans: scans.length,
                  healthy: healthyCount,
                  atRisk: atRiskCount,
                  l10n: l10n,
                  theme: theme,
                ),
              ),
              SliverList.separated(
                itemCount: scans.length,
                separatorBuilder: (_, _) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  return _ScanRow(
                    scan: scans[index],
                    l10n: l10n,
                    theme: theme,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.healing_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.healthLogEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/scan'),
              icon: const Icon(Icons.camera_alt),
              label: Text(l10n.homeScanCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonSummary extends StatelessWidget {
  const _SeasonSummary({
    required this.scans,
    required this.healthy,
    required this.atRisk,
    required this.l10n,
    required this.theme,
  });

  final int scans;
  final int healthy;
  final int atRisk;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(label: l10n.healthLogScans, value: '$scans', theme: theme),
            _Stat(
              label: l10n.healthLogHealthy,
              value: '$healthy',
              theme: theme,
              color: theme.colorScheme.primary,
            ),
            _Stat(
              label: l10n.healthLogAtRisk,
              value: '$atRisk',
              theme: theme,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.theme,
    this.color,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({
    required this.scan,
    required this.l10n,
    required this.theme,
  });

  final ScanHistoryItem scan;
  final AppLocalizations l10n;
  final ThemeData theme;

  Color _severityColor() {
    switch (diagnosisSeverity(scan.diseaseDetected)) {
      case DiagnosisSeverity.healthy:
        return theme.colorScheme.primary;
      case DiagnosisSeverity.watch:
        return theme.colorScheme.tertiary;
      case DiagnosisSeverity.atRisk:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        backgroundColor: _severityColor().withValues(alpha: 0.15),
        child: Icon(Icons.grass, color: _severityColor()),
      ),
      title: Text(scan.diseaseDetected),
      subtitle: Text(
        '${scan.commonCrop} · ${scan.confidenceScore.toStringAsFixed(0)}% · ${scan.scannedAt.month}/${scan.scannedAt.day} ${scan.scannedAt.year}',
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}