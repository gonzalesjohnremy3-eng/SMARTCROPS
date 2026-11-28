import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_back_button.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/calendar/domain/care_plan.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

const _gutter = AppSpacing.s5;

class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Consumer2<SmartCropsService, WeatherService>(
        builder: (context, service, weather, child) {
          if (service.isLoading) {
            return const LoadingState();
          }
          if (service.errorMessage != null) {
            return ErrorState(
              message: service.errorMessage!,
              onRetry: service.initializeUserData,
            );
          }

          final forecast = WeatherForecast(
            precipitationMmNext24h:
                weather.currentWeather?.precipitationMm ?? 0,
            isSample: weather.currentWeather?.isSample ?? true,
          );
          final plan = buildCarePlan(
            events: service.calendarEvents,
            scans: service.scanHistory,
            now: DateTime.now(),
            forecast: forecast,
          );

          Widget items(String title, List<CarePlanItem> list) => _Section(
            title: title,
            children: [
              for (final item in list)
                _CarePlanRow(
                  item: item,
                  onToggle: (value) {
                    context.trackEvent('care_plan_item_completed');
                    service.toggleCalendarEventCompletion(item.event.id, value);
                  },
                  onOpen: () =>
                      context.push('/calendar/events/${item.event.id}'),
                ),
            ],
          );

          return SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppLayout.maxWidths['reading']!,
                ),
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
                      l10n.carePlanTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.textPrimary, height: 1.1),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    if (plan.isEmpty)
                      const _EmptyState()
                    else ...[
                      if (plan.today.isNotEmpty)
                        items(l10n.carePlanToday, plan.today),
                      if (plan.thisWeek.isNotEmpty)
                        items(l10n.carePlanThisWeek, plan.thisWeek),
                      if (plan.preventive.isNotEmpty)
                        items(l10n.carePlanPreventive, plan.preventive),
                      if (plan.suggestions.isNotEmpty)
                        _Section(
                          title: l10n.carePlanSuggested,
                          children: [
                            for (final suggestion in plan.suggestions)
                              _SuggestionRow(
                                suggestion: suggestion,
                                onAdd: () => _addSuggestion(
                                  context,
                                  service,
                                  suggestion,
                                  l10n,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addSuggestion(
    BuildContext context,
    SmartCropsService service,
    CarePlanSuggestion suggestion,
    AppLocalizations l10n,
  ) async {
    CropItem? crop;
    for (final c in service.availableCrops) {
      if (c.cropName.toLowerCase() == suggestion.cropName.toLowerCase()) {
        crop = c;
        break;
      }
    }

    final draft = TaskDraft.followUpForScan(
      scan: suggestion.scan,
      title: l10n.carePlanSuggestionTitle(
        suggestion.cropName,
        suggestion.scan.diseaseDetected,
      ),
      cropId: crop?.id,
      now: DateTime.now(),
    );

    try {
      await service.addCalendarEvent(draft);
      if (context.mounted) {
        context.trackEvent('care_plan_item_scheduled');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.carePlanAdded),
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
  }
}

/// A titled group of rows on one raised surface, separated by hairlines.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s2),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Column(
        children: [
          const ReticleFrame(
            padding: EdgeInsets.all(AppSpacing.s5),
            child: Icon(
              Icons.task_alt_outlined,
              color: AppColors.canopy,
              size: AppSpacing.s10,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            AppLocalizations.of(context).carePlanNoItems,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CarePlanRow extends StatelessWidget {
  const _CarePlanRow({
    required this.item,
    required this.onToggle,
    required this.onOpen,
  });

  final CarePlanItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final event = item.event;
    final done = event.isCompleted;
    final (reasonLabel, reasonIcon) = switch (item.reason) {
      CarePlanReason.weather => (
        l10n.carePlanReasonWeather,
        Icons.water_drop_outlined,
      ),
      CarePlanReason.overdue => (
        l10n.carePlanReasonOverdue,
        Icons.schedule_rounded,
      ),
      CarePlanReason.scanAtRisk => (
        l10n.carePlanReasonScan,
        Icons.healing_outlined,
      ),
      CarePlanReason.routine => (
        l10n.carePlanReasonRoutine,
        Icons.event_repeat_outlined,
      ),
    };
    final urgent = item.reason == CarePlanReason.overdue;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s2,
          AppSpacing.s2,
          AppSpacing.s4,
          AppSpacing.s2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: done
                  ? l10n.calendarTaskCompleted
                  : l10n.calendarCompleteTask,
              onPressed: () => onToggle(!done),
              icon: Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.canopy : AppColors.borderStrong,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      '${event.eventCategory} · '
                      '${loc.formatShortMonthDay(item.effectiveDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: urgent
                            ? AppColors.statusCriticalSurface
                            : AppColors.mist,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s3 - 2,
                          vertical: AppSpacing.s1,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              reasonIcon,
                              size: AppSpacing.s4,
                              color: urgent ? AppColors.clay : AppColors.canopy,
                            ),
                            const SizedBox(width: AppSpacing.s1 + 2),
                            Flexible(
                              child: Text(
                                reasonLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: urgent
                                      ? AppColors.clay
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.isWeatherAdjusted &&
                        item.originalDate != null) ...[
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        '${l10n.calendarWeatherAdjusted}: '
                        '${loc.formatShortMonthDay(item.originalDate!)} › '
                        '${loc.formatShortMonthDay(item.effectiveDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.canopy,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestion, required this.onAdd});

  final CarePlanSuggestion suggestion;
  final Future<void> Function() onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.carePlanSuggestionTitle(
              suggestion.cropName,
              suggestion.scan.diseaseDetected,
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            l10n.carePlanReasonScan,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          FilledButton.icon(
            key: const Key('care_plan_add_suggestion'),
            onPressed: () => onAdd(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.actionPrimary,
              foregroundColor: AppColors.textInverse,
              minimumSize: const Size(0, AppLayout.touchTarget),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.carePlanAddToCalendar),
          ),
        ],
      ),
    );
  }
}
