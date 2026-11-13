import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.briefingFacts});

  final BriefingFacts? briefingFacts;

  BriefingFacts _factsFrom(BuildContext context) {
    final service = context.read<SmartCropsService>();
    final weather = context.read<WeatherService>();
    final now = DateTime.now();
    final condition = weather.currentWeather?.condition ?? '';

    return BriefingFacts(
      hasCriticalWeather: _isCriticalWeather(condition),
      overdueTaskCount: service.calendarEvents
          .where((event) => !event.isCompleted && event.scheduledDate.isBefore(now))
          .length,
      hasRecentAtRiskDiagnosis: service.scanHistory.any(
        (scan) => diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.atRisk,
      ),
      routineCareCount: service.calendarEvents
          .where((event) => !event.isCompleted && !event.scheduledDate.isBefore(now))
          .length,
      hasCrops: service.userSelectedCrops.isNotEmpty,
    );
  }

  bool _isCriticalWeather(String condition) {
    final text = condition.toLowerCase();
    return text.contains('storm') ||
        text.contains('thunder') ||
        text.contains('hurricane') ||
        text.contains('typhoon') ||
        text.contains('gale');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final facts = briefingFacts ?? _factsFrom(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/advisories'),
            tooltip: l10n.advisoriesTitle,
          ),
        ],
      ),
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
          return RefreshIndicator(
            onRefresh: service.initializeUserData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
          SliverToBoxAdapter(
            child: _FieldBriefingCard(l10n: l10n, theme: theme),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                l10n.homePriorityAction,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PriorityActionCard(facts: facts, l10n: l10n, theme: theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.homeCarePlan,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/care-plan'),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CarePlanPreview(l10n: l10n, theme: theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                l10n.homeRecentScans,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RecentScansPreview(l10n: l10n, theme: theme),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_scan'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ScanCaptureScreen()),
        ),
        icon: const Icon(Icons.camera_alt),
        label: Text(l10n.homeScanCTA),
      ),
    );
  }
}

class _FieldBriefingCard extends StatelessWidget {
  const _FieldBriefingCard({
    required this.l10n,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherService>();
    final weather = weatherService.currentWeather;
    final lastUpdated = weatherService.lastUpdated;
    final notices = context.watch<SmartCropsService>().notifications;
    final latestUnread = notices.where((n) => !n.isRead).isEmpty
        ? null
        : notices.firstWhere((n) => !n.isRead);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.homeFieldBriefing,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _WeatherSummary(
                    weather: weather,
                    lastUpdated: lastUpdated,
                    l10n: l10n,
                    theme: theme,
                  ),
                ),
                if (latestUnread != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CriticalAdvisoryBanner(
                      title: latestUnread.title,
                      l10n: l10n,
                      theme: theme,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherSummary extends StatelessWidget {
  const _WeatherSummary({
    required this.weather,
    required this.lastUpdated,
    required this.l10n,
    required this.theme,
  });

  final WeatherCondition? weather;
  final DateTime? lastUpdated;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final location = weather?.locationName ?? '—';
    final temperature = weather == null ? '—' : '${weather!.temperature.round()}°';
    final condition = weather?.condition ?? '—';
    final humidity = weather == null ? '—' : 'Humidity ${weather!.humidity}%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                temperature,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Fraunces',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(condition, style: theme.textTheme.bodyMedium),
                    Text(
                      humidity,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 6),
            Text(
              '${l10n.homeWeatherUpdated} ${lastUpdated!.hour.toString().padLeft(2, '0')}:${lastUpdated!.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _CriticalAdvisoryBanner extends StatelessWidget {
  const _CriticalAdvisoryBanner({
    required this.title,
    required this.l10n,
    required this.theme,
  });

  final String title;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityActionCard extends StatelessWidget {
  const _PriorityActionCard({
    required this.facts,
    required this.l10n,
    required this.theme,
  });

  final BriefingFacts facts;
  final AppLocalizations l10n;
  final ThemeData theme;

  (IconData, String, String, String, String) _content(BriefingAction action) {
    return switch (action.kind) {
      BriefingActionKind.criticalWeather => (
          Icons.storm_outlined,
          l10n.homeCriticalWeatherTitle,
          l10n.homeCriticalWeatherBody,
          '/advisories',
          l10n.advisoriesTitle,
        ),
      BriefingActionKind.overdueTask => (
          Icons.assignment_late_outlined,
          l10n.homeOverdueTaskTitle,
          l10n.homeOverdueTaskBody,
          '/calendar',
          l10n.fieldCalendar,
        ),
      BriefingActionKind.atRiskDiagnosis => (
          Icons.healing_outlined,
          l10n.homeAtRiskDiagnosisTitle,
          l10n.homeAtRiskDiagnosisBody,
          '/health-log',
          l10n.healthLogTitle,
        ),
      BriefingActionKind.routineCare => (
          Icons.water_drop_outlined,
          l10n.homeRoutineCareTitle,
          l10n.homeRoutineCareBody,
          '/care-plan',
          l10n.carePlanTitle,
        ),
      BriefingActionKind.emptyFarm => (
          Icons.camera_alt_outlined,
          l10n.homeEmptyFarmTitle,
          l10n.homeEmptyFarm,
          '/scan',
          l10n.homeScanCTA,
        ),
      BriefingActionKind.monitor => (
          Icons.verified_outlined,
          l10n.homeMonitorTitle,
          l10n.homeMonitoring,
          '/scan',
          l10n.homeScanCTA,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final action = selectPriorityAction(facts);
    final (icon, title, body, route, cta) = _content(action);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.go(route),
              icon: const Icon(Icons.arrow_forward),
              label: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarePlanPreview extends StatelessWidget {
  const _CarePlanPreview({
    required this.l10n,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = context
        .watch<SmartCropsService>()
        .calendarEvents
        .where((event) => !event.isCompleted)
        .take(2)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? Text(l10n.carePlanEmpty, style: theme.textTheme.bodyMedium)
            : Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: 24),
                    _CarePlanItem(event: items[i], l10n: l10n, theme: theme),
                  ],
                ],
              ),
      ),
    );
  }
}

class _CarePlanItem extends StatelessWidget {
  const _CarePlanItem({
    required this.event,
    required this.l10n,
    required this.theme,
  });

  final CropCalendarEvent event;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.eventTitle,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(event.eventCategory, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => context
              .read<SmartCropsService>()
              .toggleCalendarEventCompletion(event.id, true),
          child: Text(l10n.calendarCompleteTask),
        ),
      ],
    );
  }
}

class _RecentScansPreview extends StatelessWidget {
  const _RecentScansPreview({
    required this.l10n,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scans =
        context.watch<SmartCropsService>().scanHistory.take(2).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: scans.isEmpty
            ? Text(l10n.healthLogEmpty, style: theme.textTheme.bodyMedium)
            : Column(
                children: [
                  for (var i = 0; i < scans.length; i++) ...[
                    if (i > 0) const Divider(height: 24),
                    _RecentScanItem(scan: scans[i], theme: theme),
                  ],
                ],
              ),
      ),
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  const _RecentScanItem({
    required this.scan,
    required this.theme,
  });

  final ScanHistoryItem scan;
  final ThemeData theme;

  Color _severityColor(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.healthy:
        return theme.colorScheme.primary;
      case DiagnosisSeverity.watch:
        return theme.colorScheme.tertiary;
      case DiagnosisSeverity.atRisk:
        return theme.colorScheme.error;
    }
  }

  String _severityLabel(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.healthy:
        return 'HEALTHY';
      case DiagnosisSeverity.watch:
        return 'WATCH';
      case DiagnosisSeverity.atRisk:
        return 'AT RISK';
    }
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final severity = diagnosisSeverity(scan.diseaseDetected);
    final color = _severityColor(severity);

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.grass,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.commonCrop, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${scan.diseaseDetected} · ${scan.confidenceScore.round()}% · ${_relativeDate(scan.scannedAt)}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _severityLabel(severity),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
