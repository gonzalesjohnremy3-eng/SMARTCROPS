import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/scrimmed_image.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({super.key, required this.crop});

  final CropItem crop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: CropDetailContent(crop: crop, showBack: true),
      ),
    );
  }
}

class CropDetailContent extends StatelessWidget {
  const CropDetailContent({
    super.key,
    required this.crop,
    this.showBack = false,
  });

  final CropItem crop;

  /// A pushed page needs its own Back; the embedded wide pane does not.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<SmartCropsService>();

    final scans = service.scanHistory
        .where((scan) => scan.commonCrop == crop.cropName)
        .take(2)
        .toList();

    final now = DateTime.now();
    final tasks = service.calendarEvents
        .where(
          (event) =>
              !event.isCompleted &&
              !event.scheduledDate.isBefore(now) &&
              (event.cropId == null || event.cropId == crop.id),
        )
        .take(2)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _gutter,
        AppSpacing.s4,
        _gutter,
        AppSpacing.s10,
      ),
      children: [
        _Hero(
          crop: crop,
          lastScan: scans.isEmpty ? null : scans.first,
          showBack: showBack,
        ),
        const SizedBox(height: AppSpacing.s6),
        PillButton(
          label: l10n.cropsScanThisCrop,
          onPressed: () => context.push('/scan'),
        ),
        const SizedBox(height: AppSpacing.s8),
        _SectionTitle(l10n.cropDetailGrowingConditions),
        _GrowingConditions(crop: crop),
        const SizedBox(height: AppSpacing.s8),
        _SectionTitle(l10n.cropDetailYourScans),
        if (scans.isEmpty)
          _Quiet(l10n.cropsNoScans)
        else
          _Raised(children: [for (final scan in scans) _ScanRow(scan: scan)]),
        const SizedBox(height: AppSpacing.s8),
        // Wrap lets "Open calendar" drop under long translations.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _SectionTitle(l10n.cropDetailUpcomingTasks, padded: false),
            TextButton(
              onPressed: () => context.push('/calendar'),
              style: TextButton.styleFrom(foregroundColor: AppColors.canopy),
              child: Text(l10n.cropDetailOpenCalendar),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        if (tasks.isEmpty)
          _Quiet(l10n.cropDetailNotAvailable)
        else
          _Raised(children: [for (final task in tasks) _TaskRow(event: task)]),
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

class _Hero extends StatelessWidget {
  const _Hero({
    required this.crop,
    required this.lastScan,
    required this.showBack,
  });

  final CropItem crop;
  final ScanHistoryItem? lastScan;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final inverse = AppColors.textInverse;
    final style = lastScan == null
        ? null
        : _severityStyle(l10n, diagnosisSeverity(lastScan!.diseaseDetected));

    return ClipRRect(
      key: const Key('crop-detail-hero'),
      borderRadius: BorderRadius.circular(AppRadius.hero),
      child: ScrimmedImage(
        imagePath: 'assets/images/overlays/crop_detail.webp',
        scrim: AppColors.forestInk.withValues(alpha: 0.62),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBack)
                IconButton(
                  tooltip: l10n.back,
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(AppLayout.touchTarget),
                    backgroundColor: inverse.withValues(alpha: 0.16),
                    foregroundColor: inverse,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              SizedBox(height: showBack ? AppSpacing.s10 : AppSpacing.s12),
              Text(
                crop.cropName,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFamily: 'Fraunces',
                  color: inverse,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              Wrap(
                spacing: AppSpacing.s3,
                runSpacing: AppSpacing.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (style != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.$3,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s3,
                          vertical: AppSpacing.s1,
                        ),
                        child: Text(
                          style.$1,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: style.$2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    lastScan == null
                        ? l10n.cropsNoScans
                        : '${l10n.cropsLastScan}: '
                              '${MaterialLocalizations.of(context).formatShortMonthDay(lastScan!.scannedAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: inverse.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.padded = true});

  final String title;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padded ? AppSpacing.s3 : 0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'Fraunces',
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
    );
  }
}

/// Rows grouped on one raised surface, separated by hairlines.
class _Raised extends StatelessWidget {
  const _Raised({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.s4,
                endIndent: AppSpacing.s4,
                color: AppColors.borderSubtle,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _GrowingConditions extends StatelessWidget {
  const _GrowingConditions({required this.crop});

  final CropItem crop;

  /// Catalogue keys are snake_case: `temperature_range` -> `Temperature range`.
  String _label(String key) {
    if (key.isEmpty) return key;
    final words = key.replaceAll('_', ' ');
    return words[0].toUpperCase() + words.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final conditions = crop.optimalConditions;
    if (conditions.isEmpty) {
      return _Quiet(AppLocalizations.of(context).cropDetailNotAvailable);
    }
    final theme = Theme.of(context);

    return _Raised(
      children: [
        for (final entry in conditions.entries)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(entry.key),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${entry.value}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.scan});

  final ScanHistoryItem scan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (label, color, surface) = _severityStyle(
      l10n,
      diagnosisSeverity(scan.diseaseDetected),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.diseaseDetected,
                  style: theme.textTheme.titleMedium?.copyWith(
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
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          DecoratedBox(
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
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.event});

  final CropCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, color: AppColors.canopy),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${event.eventCategory} · '
                  '${MaterialLocalizations.of(context).formatShortMonthDay(event.scheduledDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
