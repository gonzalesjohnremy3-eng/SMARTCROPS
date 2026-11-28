import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

typedef BriefingContent = ({
  IconData icon,
  String title,
  String body,
  String route,
  String cta,
});

BriefingContent briefingContent(
  BriefingActionKind kind,
  AppLocalizations l10n,
) {
  return switch (kind) {
    BriefingActionKind.criticalWeather => (
      icon: Icons.storm_outlined,
      title: l10n.homeCriticalWeatherTitle,
      body: l10n.homeCriticalWeatherBody,
      route: '/advisories',
      cta: l10n.advisoriesTitle,
    ),
    BriefingActionKind.overdueTask => (
      icon: Icons.assignment_late_outlined,
      title: l10n.homeOverdueTaskTitle,
      body: l10n.homeOverdueTaskBody,
      route: '/calendar',
      cta: l10n.fieldCalendar,
    ),
    BriefingActionKind.atRiskDiagnosis => (
      icon: Icons.healing_outlined,
      title: l10n.homeAtRiskDiagnosisTitle,
      body: l10n.homeAtRiskDiagnosisBody,
      route: '/health-log',
      cta: l10n.healthLogTitle,
    ),
    BriefingActionKind.routineCare => (
      icon: Icons.water_drop_outlined,
      title: l10n.homeRoutineCareTitle,
      body: l10n.homeRoutineCareBody,
      route: '/care-plan',
      cta: l10n.carePlanTitle,
    ),
    BriefingActionKind.emptyFarm => (
      icon: Icons.camera_alt_outlined,
      title: l10n.homeEmptyFarmTitle,
      body: l10n.homeEmptyFarm,
      route: '/scan',
      cta: l10n.homeScanCTA,
    ),
    BriefingActionKind.monitor => (
      icon: Icons.verified_outlined,
      title: l10n.homeMonitorTitle,
      body: l10n.homeMonitoring,
      route: '/scan',
      cta: l10n.homeScanCTA,
    ),
  };
}

const _gutter = AppSpacing.s5;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.briefingFacts, this.now});

  final BriefingFacts? briefingFacts;

  /// Fixes the clock for the greeting and relative dates in goldens.
  final DateTime? now;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // The Field Briefing's weather is only ever fetched from here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final location = context
          .read<SmartCropsService>()
          .currentUserProfile
          ?.location;
      context.read<WeatherService>().fetchWeatherForLocation(
        location == null || location.isEmpty ? 'Philippines' : location,
      );
    });
  }

  BriefingFacts _factsFrom(BuildContext context) {
    final service = context.read<SmartCropsService>();
    // Watched so the priority action reacts when the weather arrives.
    final weather = context.watch<WeatherService>();
    final now = DateTime.now();

    return BriefingFacts(
      hasCriticalWeather: isCriticalWeather(weather.currentWeather),
      overdueTaskCount: service.calendarEvents
          .where(
            (event) => !event.isCompleted && event.scheduledDate.isBefore(now),
          )
          .length,
      hasRecentAtRiskDiagnosis: service.scanHistory.any(
        (scan) =>
            diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.atRisk,
      ),
      routineCareCount: service.calendarEvents
          .where(
            (event) => !event.isCompleted && !event.scheduledDate.isBefore(now),
          )
          .length,
      hasCrops: service.userSelectedCrops.isNotEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final facts = widget.briefingFacts ?? _factsFrom(context);

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

          final briefing = [
            _Greeting(service: service, now: widget.now ?? DateTime.now()),
            const SizedBox(height: AppSpacing.s6),
            _FieldBriefingCard(facts: facts),
            _AdvisoryStrip(notifications: service.notifications),
            const SizedBox(height: AppSpacing.s4),
            const _ScanPrompt(),
          ];
          final lists = [
            _SectionHeader(
              title: AppLocalizations.of(context).homeCarePlan,
              actionLabel: AppLocalizations.of(context).viewAll,
              onAction: () {
                context.trackEvent('care_plan_opened_from_home');
                context.push('/care-plan');
              },
            ),
            _CareList(events: service.calendarEvents),
            const SizedBox(height: AppSpacing.s8),
            _SectionHeader(
              title: AppLocalizations.of(context).homeRecentScans,
              actionLabel: AppLocalizations.of(context).viewAll,
              onAction: () => context.push('/health-log'),
            ),
            _ScanList(
              scans: service.scanHistory,
              now: widget.now ?? DateTime.now(),
            ),
          ];

          return RefreshIndicator(
            color: AppColors.canopy,
            onRefresh: service.initializeUserData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >=
                    AppLayout.breakpoints['expanded']!) {
                  return Row(
                    key: const Key('home-wide-split'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 6, child: _Column(children: briefing)),
                      Expanded(
                        key: const Key('home-wide-actions'),
                        flex: 5,
                        child: _Column(
                          children: [
                            const SizedBox(height: AppSpacing.s12),
                            ...lists,
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return _Column(
                  children: [
                    ...briefing,
                    const SizedBox(height: AppSpacing.s8),
                    ...lists,
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverSafeArea(
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              _gutter,
              AppSpacing.s4,
              _gutter,
              AppSpacing.s10,
            ),
            sliver: SliverList.list(children: children),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.service, required this.now});

  final SmartCropsService service;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final greeting = now.hour < 12
        ? l10n.homeGreetingMorning
        : now.hour < 18
        ? l10n.homeGreetingAfternoon
        : l10n.homeGreetingEvening;
    final fullName = service.currentUserProfile?.fullName.trim() ?? '';
    final firstName = fullName.isEmpty ? null : fullName.split(' ').first;
    final hasUnread = service.notifications.any((n) => !n.isRead);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MaterialLocalizations.of(context).formatMediumDate(now),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                firstName == null ? greeting : '$greeting,',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              if (firstName != null)
                Text(
                  firstName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.canopy,
                    height: 1.1,
                  ),
                ),
            ],
          ),
        ),
        Badge(
          isLabelVisible: hasUnread,
          backgroundColor: AppColors.clay,
          smallSize: AppSpacing.s2 + 2,
          offset: const Offset(-6, 6),
          child: IconButton(
            tooltip: l10n.advisoriesTitle,
            onPressed: () => context.push('/advisories'),
            style: IconButton.styleFrom(
              fixedSize: const Size.square(AppLayout.touchTarget),
              backgroundColor: AppColors.surfaceSunken,
              foregroundColor: AppColors.textPrimary,
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }
}

/// Weather on the farm plus the one priority action, over the paddies photo.
class _FieldBriefingCard extends StatelessWidget {
  const _FieldBriefingCard({required this.facts});

  final BriefingFacts facts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final weatherService = context.watch<WeatherService>();
    final weather = weatherService.currentWeather;
    final lastUpdated = weatherService.lastUpdated;
    final action = briefingContent(selectPriorityAction(facts).kind, l10n);
    final inverse = AppColors.textInverse;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestInk.withValues(alpha: 0.12),
            blurRadius: AppSpacing.s6,
            offset: const Offset(0, AppSpacing.s2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/overlays/home.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.forestInk.withValues(alpha: 0.45),
                  AppColors.forestInk.withValues(alpha: 0.88),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeFieldBriefing,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: inverse.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        weather == null
                            ? '—'
                            : '${weather.temperature.round()}°',
                        // Already display-sized; unclamped it leaves no room
                        // for the place name at large text.
                        textScaler: MediaQuery.textScalerOf(
                          context,
                        ).clamp(maxScaleFactor: 1.2),
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: inverse,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather?.locationName ?? '—',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: inverse,
                              ),
                            ),
                            Text(
                              weather == null
                                  ? '—'
                                  : '${weather.condition} · '
                                        '${l10n.homeHumidity(weather.humidity)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: inverse.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (lastUpdated != null) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      '${l10n.homeWeatherUpdated} '
                      '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(lastUpdated))}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: inverse.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s6),
                  Divider(height: 1, color: inverse.withValues(alpha: 0.18)),
                  const SizedBox(height: AppSpacing.s5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSpacing.s10,
                        height: AppSpacing.s10,
                        decoration: BoxDecoration(
                          color: AppColors.leaf.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          action.icon,
                          color: AppColors.leaf,
                          size: AppSpacing.s5,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontFamily: 'Fraunces',
                                color: inverse,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            Text(
                              action.body,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: inverse.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s5),
                  FilledButton(
                    onPressed: () {
                      context.trackEvent('priority_action_opened');
                      context.go(action.route);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.paper,
                      foregroundColor: AppColors.forestInk,
                      minimumSize: const Size.fromHeight(AppLayout.touchTarget),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            action.cta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: AppSpacing.s4 + 2,
                        ),
                      ],
                    ),
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

class _AdvisoryStrip extends StatelessWidget {
  const _AdvisoryStrip({required this.notifications});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => !n.isRead);
    if (unread.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s3),
      child: Material(
        color: AppColors.statusCriticalSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => context.push('/advisories'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Row(
              children: [
                const Icon(Icons.campaign_outlined, color: AppColors.clay),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Text(
                    unread.first.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
      ),
    );
  }
}

class _ScanPrompt extends StatelessWidget {
  const _ScanPrompt();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.go('/scan'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Row(
            children: [
              const ReticleFrame(
                arm: AppSpacing.s2 + 2,
                padding: EdgeInsets.all(AppSpacing.s3 - 2),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.canopy,
                  size: AppSpacing.s6,
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeScanCTA,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.homeScanPromptBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.canopy),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      // Wrap lets "View all" drop under long translations at large text.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Fraunces',
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.canopy),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

/// Rows grouped on one raised surface, separated by hairlines.
class _Surface extends StatelessWidget {
  const _Surface({required this.children});

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

class _CareList extends StatelessWidget {
  const _CareList({required this.events});

  final List<CropCalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final open = events.where((event) => !event.isCompleted).take(3).toList();

    if (open.isEmpty) {
      return _Surface(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Text(
              l10n.carePlanEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return _Surface(
      children: [
        for (final event in open)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s2,
              AppSpacing.s2,
              AppSpacing.s4,
              AppSpacing.s2,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.calendarCompleteTask,
                  onPressed: () => context
                      .read<SmartCropsService>()
                      .toggleCalendarEventCompletion(event.id, true),
                  icon: const Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: AppColors.borderStrong,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
          ),
      ],
    );
  }
}

class _ScanList extends StatelessWidget {
  const _ScanList({required this.scans, required this.now});

  final List<ScanHistoryItem> scans;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final recent = scans.take(3).toList();

    if (recent.isEmpty) {
      return _Surface(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Text(
              l10n.healthLogEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return _Surface(
      children: [for (final scan in recent) _ScanRow(scan: scan, now: now)],
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.scan, required this.now});

  final ScanHistoryItem scan;
  final DateTime now;

  String _relativeDate(BuildContext context, AppLocalizations l10n) {
    final today = DateTime(now.year, now.month, now.day);
    final date = scan.scannedAt;
    final days = today.difference(DateTime(date.year, date.month, date.day));
    if (days.inDays <= 0) return l10n.calendarToday;
    if (days.inDays == 1) return l10n.homeYesterday;
    return MaterialLocalizations.of(context).formatShortMonthDay(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final severity = diagnosisSeverity(scan.diseaseDetected);
    final (label, color, surface) = switch (severity) {
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

    return InkWell(
      onTap: () => context.push('/health-log'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
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
                    '${scan.diseaseDetected} · '
                    '${scan.confidenceScore.round()}% · '
                    '${_relativeDate(context, l10n)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s3 - 2,
                vertical: AppSpacing.s1,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                label,
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
