import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({super.key, required this.crop});

  final CropItem crop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();

    final scans = service.scanHistory
        .where((scan) => scan.commonCrop == crop.cropName)
        .take(2)
        .toList();

    final now = DateTime.now();
    final tasks = service.calendarEvents
        .where((event) =>
            !event.isCompleted &&
            !event.scheduledDate.isBefore(now) &&
            (event.cropId == null || event.cropId == crop.id))
        .take(2)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(crop.cropName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            crop: crop,
            lastScan: scans.isEmpty ? null : scans.first,
            l10n: l10n,
            theme: theme,
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.cropDetailGrowingConditions),
          const SizedBox(height: 8),
          _GrowingConditions(crop: crop, l10n: l10n, theme: theme),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.cropDetailGrowthTimeline),
          const SizedBox(height: 8),
          _NotAvailable(l10n: l10n, theme: theme),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.cropDetailCareGuide),
          const SizedBox(height: 8),
          _NotAvailable(l10n: l10n, theme: theme),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.cropDetailYourScans),
          const SizedBox(height: 8),
          if (scans.isEmpty)
            Text(l10n.cropsNoScans, style: theme.textTheme.bodyMedium)
          else
            Column(
              children: [
                for (var i = 0; i < scans.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _ScanRow(scan: scans[i], theme: theme),
                ],
              ],
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SectionTitle(title: l10n.cropDetailUpcomingTasks),
              ),
              TextButton(
                onPressed: () => context.push('/calendar'),
                child: Text(l10n.cropDetailOpenCalendar),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Text(l10n.cropDetailNotAvailable, style: theme.textTheme.bodyMedium)
          else
            Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _TaskRow(event: tasks[i], theme: theme),
                ],
              ],
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScanCaptureScreen()),
            ),
            child: Text(l10n.cropsScanThisCrop),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.crop,
    required this.lastScan,
    required this.l10n,
    required this.theme,
  });

  final CropItem crop;
  final ScanHistoryItem? lastScan;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final severity = lastScan == null
        ? null
        : diagnosisSeverity(lastScan!.diseaseDetected);

    return Row(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.eco_outlined,
              size: 44, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(crop.cropName, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                lastScan == null
                    ? l10n.cropsNoScans
                    : '${l10n.cropsLastScan}: ${lastScan!.scannedAt.month}/${lastScan!.scannedAt.day}',
                style: theme.textTheme.bodySmall,
              ),
              if (severity != null) ...[
                const SizedBox(height: 8),
                _SeverityChip(severity: severity, l10n: l10n, theme: theme),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.severity,
    required this.l10n,
    required this.theme,
  });

  final DiagnosisSeverity severity;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      DiagnosisSeverity.healthy => (l10n.severityHealthy, theme.colorScheme.primary),
      DiagnosisSeverity.watch => (l10n.severityWatch, theme.colorScheme.tertiary),
      DiagnosisSeverity.atRisk => (l10n.severityAtRisk, theme.colorScheme.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GrowingConditions extends StatelessWidget {
  const _GrowingConditions({
    required this.crop,
    required this.l10n,
    required this.theme,
  });

  final CropItem crop;
  final AppLocalizations l10n;
  final ThemeData theme;

  String _label(String key) {
    if (key.isEmpty) return key;
    final words = key.replaceAll('_', ' ');
    return words[0].toUpperCase() + words.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final conditions = crop.optimalConditions;
    if (conditions.isEmpty) {
      return Text(l10n.cropDetailNotAvailable, style: theme.textTheme.bodyMedium);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in conditions.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${_label(entry.key)}: ${entry.value}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(l10n.cropDetailNotAvailable, style: theme.textTheme.bodyMedium);
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.scan, required this.theme});

  final ScanHistoryItem scan;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(scan.diseaseDetected, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${scan.confidenceScore.round()}% · ${scan.scannedAt.month}/${scan.scannedAt.day}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.event, required this.theme});

  final CropCalendarEvent event;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.eventTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${event.eventCategory} · ${event.scheduledDate.month}/${event.scheduledDate.day}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
