import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_knowledge_base.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

typedef _SeverityStyle = ({Color accent, Color surface, Color onAccent});

_SeverityStyle _styleFor(DiagnosisSeverity severity) => switch (severity) {
  DiagnosisSeverity.healthy => (
    accent: AppColors.canopy,
    surface: AppColors.statusHealthySurface,
    onAccent: AppColors.textInverse,
  ),
  DiagnosisSeverity.watch => (
    accent: AppColors.palay,
    surface: AppColors.statusWarningSurface,
    onAccent: AppColors.forestInk,
  ),
  DiagnosisSeverity.atRisk => (
    accent: AppColors.clay,
    surface: AppColors.statusCriticalSurface,
    onAccent: AppColors.textInverse,
  ),
};

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.input});

  final DiagnosisInput input;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = presentDiagnosis(input);
    final details = knowledgeFor(
      diseaseDetected: view.diagnosis,
      cropName: view.crop,
    );

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _VerdictHeader(view: view)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s5,
                    AppSpacing.s6,
                    AppSpacing.s5,
                    AppSpacing.s8,
                  ),
                  sliver: SliverList.list(
                    children: [
                      if (view.isDemo) ...[
                        _Notice(
                          icon: Icons.science_outlined,
                          title: l10n.scanDemoBannerTitle,
                          body: l10n.scanDemoBannerBody,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                      ],
                      if (view.showRetakePrimary) ...[
                        _Notice(
                          icon: Icons.center_focus_weak_rounded,
                          title: l10n.scanResultLowConfidenceTitle,
                          body: l10n.scanResultLowConfidenceBody,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                      ],
                      _SectionTitle(l10n.scanResultTreatmentSteps),
                      _Steps(steps: view.treatmentSteps),
                      const SizedBox(height: AppSpacing.s8),
                      _SectionTitle(l10n.scanResultLearnMore),
                      _LearnMore(details: details),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ActionBar(view: view),
        ],
      ),
    );
  }
}

class _VerdictHeader extends StatelessWidget {
  const _VerdictHeader({required this.view});

  final DiagnosisView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final style = _styleFor(view.severity);
    final severityLabel = switch (view.severity) {
      DiagnosisSeverity.healthy => l10n.severityHealthy,
      DiagnosisSeverity.watch => l10n.severityWatch,
      DiagnosisSeverity.atRisk => l10n.severityAtRisk,
    };
    final bandLabel = switch (view.confidenceBand) {
      ConfidenceBand.low => l10n.confidenceLow,
      ConfidenceBand.medium => l10n.confidenceMedium,
      ConfidenceBand.high => l10n.confidenceHigh,
    };
    final percent = view.confidencePercent.clamp(0, 100).round();

    return ColoredBox(
      color: style.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s3,
            AppSpacing.s2,
            AppSpacing.s3,
            AppSpacing.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go('/scan'),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.scanResultShare,
                    onPressed: () {
                      context.trackEvent('diagnosis_shared');
                      Share.share(
                        '${view.crop}: ${view.diagnosis} ($percent%)\n'
                        '${view.treatmentSteps.map((step) => '• $step').join('\n')}',
                      );
                    },
                    icon: const Icon(Icons.ios_share_rounded),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.crop,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      view.diagnosis,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.05,
                        fontSize: theme.textTheme.headlineMedium?.fontSize
                            ?.clamp(0, 40)
                            .toDouble(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s5),
                    Wrap(
                      spacing: AppSpacing.s4,
                      runSpacing: AppSpacing.s3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: style.accent,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s3,
                              vertical: AppSpacing.s1 + 2,
                            ),
                            child: Text(
                              severityLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: style.onAccent,
                              ),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${l10n.scanResultConfidence} · '
                                '$bandLabel · $percent%',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s1 + 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: LinearProgressIndicator(
                                  value: percent / 100,
                                  minHeight: AppSpacing.s1 + 2,
                                  color: style.accent,
                                  backgroundColor: AppColors.textPrimary
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.statusWarningSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.palay),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'Fraunces',
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSpacing.s8,
                  height: AppSpacing.s8,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.canopy,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s1 + 2),
                    child: Text(
                      steps[i],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LearnMore extends StatelessWidget {
  const _LearnMore({required this.details});

  final DiagnosisDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );

    Widget bullets(List<String> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s2),
            child: Text('•  $item', style: body),
          ),
      ],
    );

    final sections = [
      (
        Icons.science_outlined,
        l10n.scanDetailCause,
        Text(details.cause, style: body),
      ),
      (
        Icons.visibility_outlined,
        l10n.scanDetailSymptoms,
        bullets(details.symptoms),
      ),
      (
        Icons.shield_outlined,
        l10n.scanDetailPrevention,
        bullets(details.prevention),
      ),
      (
        Icons.support_agent_outlined,
        l10n.scanDetailExpertNote,
        Text(details.expertNote, style: body),
      ),
    ];

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
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.s4,
                endIndent: AppSpacing.s4,
                color: AppColors.borderSubtle,
              ),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Icon(sections[i].$1, color: AppColors.canopy),
                title: Text(
                  sections[i].$2,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                iconColor: AppColors.canopy,
                collapsedIconColor: AppColors.textSecondary,
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  0,
                  AppSpacing.s4,
                  AppSpacing.s4,
                ),
                expandedAlignment: Alignment.centerLeft,
                children: [sections[i].$3],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.view});

  final DiagnosisView view;

  Future<void> _addToCalendar(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
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
        title: l10n.scanFollowUpTitle(view.crop, view.diagnosis),
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
              onPressed: () => context.go('/calendar'),
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper,
        boxShadow: [
          BoxShadow(
            color: AppColors.forestInk.withValues(alpha: 0.08),
            blurRadius: AppSpacing.s4,
            offset: const Offset(0, -AppSpacing.s1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s5,
            AppSpacing.s3,
            AppSpacing.s5,
            AppSpacing.s3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (view.showRetakePrimary)
                PillButton(
                  key: const Key('retake_primary'),
                  label: l10n.scanResultLowConfidenceRetake,
                  onPressed: () {
                    context.trackEvent('low_confidence_retake');
                    context.go('/scan');
                  },
                )
              else
                PillButton(
                  label: l10n.scanResultAddToCalendar,
                  onPressed: () => _addToCalendar(context),
                ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/scan'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.canopy,
                      minimumSize: const Size(0, AppLayout.touchTarget),
                    ),
                    child: Text(l10n.scanResultScanAnother),
                  ),
                  if (view.allowPartnerOffers)
                    TextButton(
                      key: const Key('see_products_for_diagnosis'),
                      onPressed: () {
                        context.trackEvent('partner_offer_viewed');
                        context.push(
                          '/shop?q=${Uri.encodeComponent(view.diagnosis)}',
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.canopy,
                        minimumSize: const Size(0, AppLayout.touchTarget),
                      ),
                      child: Text(l10n.shopSeeProductsFor),
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
