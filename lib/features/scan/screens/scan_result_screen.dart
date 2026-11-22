import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_knowledge_base.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.input});

  final DiagnosisInput input;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final view = presentDiagnosis(input);
    final details = knowledgeFor(
      diseaseDetected: view.diagnosis,
      cropName: view.crop,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanResultTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.scanResultShare,
            onPressed: () {
              context.trackEvent('diagnosis_shared');
              Share.share(
                '${view.crop}: ${view.diagnosis} (${view.confidencePercent}%)\n${view.treatmentSteps.map((step) => '• $step').join('\n')}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (view.isDemo) ...[
              _DemoNotice(l10n: l10n, theme: theme),
              const SizedBox(height: 20),
            ],
            _CropSummary(view: view, l10n: l10n, theme: theme),
            const SizedBox(height: 24),
            _DiagnosisCard(view: view, l10n: l10n, theme: theme),
            const SizedBox(height: 24),
            _DetailSection(
              title: l10n.scanDetailCause,
              icon: Icons.science_outlined,
              theme: theme,
              child: Text(details.cause, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: l10n.scanDetailSymptoms,
              icon: Icons.visibility_outlined,
              theme: theme,
              child: _BulletList(items: details.symptoms, theme: theme),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.scanResultTreatmentSteps,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...view.treatmentSteps.asMap().entries.map(
              (entry) => _TreatmentStep(
                index: entry.key + 1,
                step: entry.value,
                theme: theme,
              ),
            ),
            const SizedBox(height: 24),
            _DetailSection(
              title: l10n.scanDetailPrevention,
              icon: Icons.shield_outlined,
              theme: theme,
              child: _BulletList(items: details.prevention, theme: theme),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: l10n.scanDetailExpertNote,
              icon: Icons.support_agent_outlined,
              theme: theme,
              child: Text(
                details.expertNote,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            _Actions(view: view, l10n: l10n, theme: theme),
            const SizedBox(height: 12),
            Text(
              l10n.scanQueuedOffline,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropSummary extends StatelessWidget {
  const _CropSummary({
    required this.view,
    required this.l10n,
    required this.theme,
  });

  final DiagnosisView view;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Icon(
            Icons.grass,
            size: 44,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(view.crop, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(l10n.scanResultTitle, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({
    required this.view,
    required this.l10n,
    required this.theme,
  });

  final DiagnosisView view;
  final AppLocalizations l10n;
  final ThemeData theme;

  Color _severityColor() {
    switch (view.severity) {
      case DiagnosisSeverity.healthy:
        return theme.colorScheme.primary;
      case DiagnosisSeverity.watch:
        return theme.colorScheme.tertiary;
      case DiagnosisSeverity.atRisk:
        return theme.colorScheme.error;
    }
  }

  String _severityLabel() {
    switch (view.severity) {
      case DiagnosisSeverity.healthy:
        return l10n.severityHealthy;
      case DiagnosisSeverity.watch:
        return l10n.severityWatch;
      case DiagnosisSeverity.atRisk:
        return l10n.severityAtRisk;
    }
  }

  String _confidenceLabel() {
    switch (view.confidenceBand) {
      case ConfidenceBand.low:
        return l10n.confidenceLow;
      case ConfidenceBand.medium:
        return l10n.confidenceMedium;
      case ConfidenceBand.high:
        return l10n.confidenceHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scanResultDiagnosis, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(view.diagnosis, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Chip(
                  label: l10n.scanResultSeverity,
                  value: _severityLabel(),
                  color: severityColor,
                  theme: theme,
                ),
                _Chip(
                  label: l10n.scanResultConfidence,
                  value:
                      '${_confidenceLabel()} · ${view.confidencePercent.toStringAsFixed(0)}%',
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.scanResultConfidence}: ${view.confidencePercent.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: theme.textTheme.labelMedium),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentStep extends StatelessWidget {
  const _TreatmentStep({
    required this.index,
    required this.step,
    required this.theme,
  });

  final int index;
  final String step;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: Text(
              '$index',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(step, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.view, required this.l10n, required this.theme});

  final DiagnosisView view;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (view.showRetakePrimary)
          FilledButton.icon(
            key: const Key('retake_primary'),
            onPressed: () => context.trackEvent('low_confidence_retake'),
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(l10n.scanResultLowConfidenceRetake),
          )
        else
          FilledButton.icon(
            onPressed: () async {
              try {
                final service = context.read<SmartCropsService>();
                final scan = ScanHistoryItem(
                  id: DateTime.now().toIso8601String(),
                  userId: '',
                  imageUrl: '',
                  diseaseDetected: view.diagnosis,
                  confidenceScore: view.confidencePercent,
                  commonCrop: view.crop,
                  recommendedActions: view.treatmentSteps,
                  scannedAt: DateTime.now(),
                );
                final draft = TaskDraft.followUpForScan(
                  scan: scan,
                  title: 'Recheck ${view.crop} — ${view.diagnosis}',
                  now: DateTime.now(),
                );
                await service.addCalendarEvent(draft);
                if (context.mounted) {
                  context.trackEvent('diagnosis_added_to_calendar');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.scanResultAddedToCalendar),
                      action: SnackBarAction(
                        label: l10n.viewCalendar,
                        onPressed: () => context.push('/calendar'),
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
                }
              }
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(l10n.scanResultAddToCalendar),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
          label: Text(l10n.scanResultSetReminder),
        ),
        if (view.allowPartnerOffers) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            key: const Key('see_products_for_diagnosis'),
            onPressed: () {
              context.trackEvent('partner_offer_viewed');
              context.push('/shop?q=${Uri.encodeComponent(view.diagnosis)}');
            },
            icon: const Icon(Icons.storefront_outlined),
            label: Text(l10n.shopSeeProductsFor),
          ),
        ],
      ],
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.science_outlined,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scanDemoBannerTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.scanDemoBannerBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.theme,
    required this.child,
  });

  final String title;
  final IconData icon;
  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items, required this.theme});

  final List<String> items;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
