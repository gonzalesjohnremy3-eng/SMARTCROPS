import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/crops/screens/crop_detail_screen.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _maxConditionChips = 3;

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  String? _selectedCropId;

  @override
  Widget build(BuildContext context) {
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

          final crops = service.userSelectedCrops;
          final scansByCrop = _scansByCrop(service.scanHistory);

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  crops.isNotEmpty &&
                  constraints.maxWidth >= AppLayout.breakpoints['expanded']!;
              CropItem? selected;
              if (wide) {
                selected = crops.firstWhere(
                  (crop) => crop.id == _selectedCropId,
                  orElse: () => crops.first,
                );
              }
              final list = _buildList(
                context: context,
                crops: crops,
                scansByCrop: scansByCrop,
                selectedCropId: selected?.id,
                wide: wide,
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
                  Expanded(flex: 6, child: CropDetailContent(crop: selected!)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildList({
    required BuildContext context,
    required List<CropItem> crops,
    required Map<String, ScanHistoryItem> scansByCrop,
    required String? selectedCropId,
    required bool wide,
  }) {
    final needAttention = crops
        .where(
          (crop) =>
              _severityOf(scansByCrop[crop.cropName]) ==
              DiagnosisSeverity.atRisk,
        )
        .length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s4,
          AppSpacing.s5,
          AppSpacing.s10,
        ),
        children: [
          _Header(count: crops.length, needAttention: needAttention),
          const SizedBox(height: AppSpacing.s6),
          if (crops.isEmpty)
            const _EmptyState()
          else
            for (final crop in crops) ...[
              _CropCard(
                crop: crop,
                lastScan: scansByCrop[crop.cropName],
                selected: crop.id == selectedCropId,
                onOpen: () {
                  context.trackEvent('crop_opened');
                  if (wide) {
                    setState(() => _selectedCropId = crop.id);
                  } else {
                    context.push('/crops/${crop.id}');
                  }
                },
                onScan: () => context.push('/scan'),
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
        ],
      ),
    );
  }

  Map<String, ScanHistoryItem> _scansByCrop(List<ScanHistoryItem> history) {
    final map = <String, ScanHistoryItem>{};
    for (final scan in history) {
      map.putIfAbsent(scan.commonCrop, () => scan);
    }
    return map;
  }
}

DiagnosisSeverity? _severityOf(ScanHistoryItem? scan) =>
    scan == null ? null : diagnosisSeverity(scan.diseaseDetected);

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.needAttention});

  final int count;
  final int needAttention;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cropsTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.s1),
        Text(
          l10n.cropsSelectedCount(count),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (needAttention > 0) ...[
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.clay,
                size: AppSpacing.s5,
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  l10n.cropsNeedAttention(needAttention),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.clay,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Column(
        children: [
          const ReticleFrame(
            padding: EdgeInsets.all(AppSpacing.s5),
            child: Icon(
              Icons.eco_outlined,
              color: AppColors.canopy,
              size: AppSpacing.s10,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            l10n.cropsEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.crop,
    required this.lastScan,
    required this.onOpen,
    required this.onScan,
    this.selected = false,
  });

  final CropItem crop;
  final ScanHistoryItem? lastScan;
  final VoidCallback onOpen;
  final VoidCallback onScan;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (statusLabel, color, surface) = switch (_severityOf(lastScan)) {
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
      null => (l10n.cropsNoScans, AppColors.textSecondary, AppColors.mist),
    };
    final conditions = crop.optimalConditions.entries
        .take(_maxConditionChips)
        .toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: selected ? AppColors.canopy : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestInk.withValues(alpha: 0.06),
            blurRadius: AppSpacing.s4,
            offset: const Offset(0, AppSpacing.s1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: AppLayout.touchTarget + AppSpacing.s2,
                      height: AppLayout.touchTarget + AppSpacing.s2,
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
                            crop.cropName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'Fraunces',
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s3 - 2,
                              vertical: AppSpacing.s1,
                            ),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              statusLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (lastScan != null) ...[
                            const SizedBox(height: AppSpacing.s1),
                            Text(
                              '${l10n.cropsLastScan}: '
                              '${MaterialLocalizations.of(context).formatShortMonthDay(lastScan!.scannedAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    IconButton.filled(
                      tooltip: l10n.cropsScanThisCrop,
                      onPressed: onScan,
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(AppLayout.touchTarget),
                        backgroundColor: AppColors.actionPrimary,
                        foregroundColor: AppColors.textInverse,
                      ),
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
                  ],
                ),
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      for (final entry in conditions)
                        _ConditionChip(
                          '${_humanize(entry.key)}: ${entry.value}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1 + 2,
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// `temperature_range` -> `Temperature range`: catalogue keys are snake_case.
String _humanize(String key) {
  final spaced = key.replaceAll('_', ' ');
  return spaced.isEmpty
      ? spaced
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}
