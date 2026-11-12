import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
      body: CustomScrollView(
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
              child: _PriorityActionCard(l10n: l10n, theme: theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeCarePlan, style: theme.textTheme.titleLarge),
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
                Text(l10n.homeFieldBriefing, style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _WeatherSummary(
                    location: 'Manila, PH',
                    temperature: 28,
                    condition: 'Partly Cloudy',
                    l10n: l10n,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CriticalAdvisoryBanner(l10n: l10n, theme: theme),
                ),
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
    required this.location,
    required this.temperature,
    required this.condition,
    required this.l10n,
    required this.theme,
  });

  final String location;
  final int temperature;
  final String condition;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
                '$temperature°',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Fraunces',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(condition, style: theme.textTheme.bodyMedium),
                  Text(
                    'Humidity 68%',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriticalAdvisoryBanner extends StatelessWidget {
  const _CriticalAdvisoryBanner({
    required this.l10n,
    required this.theme,
  });

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
              'High wind alert for tomorrow. Secure loose structures.',
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
    required this.l10n,
    required this.theme,
  });

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deep Watering & Irrigation',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Due today. Forecast shows no rain for 48 hours.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/calendar/events/task-1'),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.calendarTaskCompleted),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/calendar/events/task-1'),
                  icon: const Icon(Icons.schedule),
                  label: Text(l10n.calendarSetReminder),
                ),
              ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _CarePlanItem(
              title: 'Apply organic compost',
              crop: 'Pechay',
              reason: 'Soil nutrients low',
              theme: theme,
            ),
            const Divider(height: 24),
            _CarePlanItem(
              title: 'Check for aphids',
              crop: 'Tomato',
              reason: 'Preventive inspection',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarePlanItem extends StatelessWidget {
  const _CarePlanItem({
    required this.title,
    required this.crop,
    required this.reason,
    required this.theme,
  });

  final String title;
  final String crop;
  final String reason;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('$crop · $reason', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        FilledButton(
          onPressed: () {},
          child: const Text('Done'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RecentScanItem(
              crop: 'Pechay',
              diagnosis: 'Healthy',
              confidence: 96,
              date: 'Today',
              severity: 'healthy',
              theme: theme,
            ),
            const Divider(height: 24),
            _RecentScanItem(
              crop: 'Tomato',
              diagnosis: 'Early Blight',
              confidence: 87,
              date: 'Yesterday',
              severity: 'atRisk',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  const _RecentScanItem({
    required this.crop,
    required this.diagnosis,
    required this.confidence,
    required this.date,
    required this.severity,
    required this.theme,
  });

  final String crop;
  final String diagnosis;
  final int confidence;
  final String date;
  final String severity;
  final ThemeData theme;

  Color _severityColor(String severity) {
    switch (severity) {
      case 'healthy':
        return theme.colorScheme.primary;
      case 'watch':
        return theme.colorScheme.tertiary;
      case 'atRisk':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(crop, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '$diagnosis · $confidence% confidence',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _severityColor(severity).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                severity.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _severityColor(severity),
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