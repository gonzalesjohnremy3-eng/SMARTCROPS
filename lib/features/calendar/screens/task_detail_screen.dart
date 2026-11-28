import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/calendar/domain/care_plan.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/features/calendar/widgets/task_form_sheet.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

const _gutter = AppSpacing.s5;

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.event});

  final CropCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);

    return Consumer2<SmartCropsService, WeatherService>(
      builder: (context, service, weather, child) {
        // Find latest event matching id in case service updated
        CropCalendarEvent? updatedEvent;
        for (final e in service.calendarEvents) {
          if (e.id == event.id) {
            updatedEvent = e;
            break;
          }
        }
        final currentEvent = updatedEvent ?? event;

        final forecast = WeatherForecast(
          precipitationMmNext24h: weather.currentWeather?.precipitationMm ?? 0,
          isSample: weather.currentWeather?.isSample ?? true,
        );
        final adjustment = adjustForWeather(
          event: currentEvent,
          forecast: forecast,
        );
        final reason = resolveEventReason(
          event: currentEvent,
          scans: service.scanHistory,
          now: DateTime.now(),
          forecast: forecast,
        );

        CropItem? crop;
        for (final c in service.userSelectedCrops) {
          if (c.id == currentEvent.cropId) {
            crop = c;
            break;
          }
        }

        ScanHistoryItem? relatedScan;
        for (final s in service.scanHistory) {
          final matchesCrop =
              crop != null &&
              s.commonCrop.toLowerCase() == crop.cropName.toLowerCase();
          final matchesTitle = currentEvent.eventTitle.toLowerCase().contains(
            s.commonCrop.toLowerCase(),
          );
          if (matchesCrop || matchesTitle) {
            relatedScan = s;
            break;
          }
        }

        final done = currentEvent.isCompleted;
        final when = adjustment.adjustedDate;

        return Scaffold(
          backgroundColor: AppColors.paper,
          body: SafeArea(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: l10n.back,
                          onPressed: () => context.pop(),
                        ),
                        _RoundButton(
                          icon: Icons.edit_outlined,
                          tooltip: l10n.taskDetailEdit,
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => ChangeNotifierProvider.value(
                              value: service,
                              child: TaskFormSheet(event: currentEvent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s5),
                    Text(
                      currentEvent.eventTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: [
                        _Pill(currentEvent.eventCategory),
                        if (crop != null) _Pill(crop.cropName),
                        if (currentEvent.priority == 'High')
                          _Pill(l10n.calendarHighPriority, urgent: true),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    _Raised(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.s4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.taskScheduledFor,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${loc.formatMediumDate(when)} · '
                                '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(when))}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (adjustment.isAdjusted) ...[
                                const SizedBox(height: AppSpacing.s2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.water_drop_outlined,
                                      size: AppSpacing.s4,
                                      color: AppColors.canopy,
                                    ),
                                    const SizedBox(width: AppSpacing.s2),
                                    Expanded(
                                      child: Text(
                                        '${l10n.calendarWeatherAdjusted}: '
                                        '${loc.formatShortMonthDay(adjustment.originalDate)} → '
                                        '${loc.formatShortMonthDay(adjustment.adjustedDate)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: AppColors.canopy),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.s4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.taskWhyThisDate,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _reasonText(reason, l10n),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    if (done)
                      OutlinedButton.icon(
                        onPressed: () => service.toggleCalendarEventCompletion(
                          currentEvent.id,
                          false,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            AppLayout.touchTarget + AppSpacing.s2,
                          ),
                          foregroundColor: AppColors.canopy,
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(l10n.calendarTaskCompleted),
                      )
                    else
                      PillButton(
                        label: l10n.calendarCompleteTask,
                        onPressed: () {
                          context.trackEvent('task_completed');
                          service.toggleCalendarEventCompletion(
                            currentEvent.id,
                            true,
                          );
                        },
                      ),
                    if (relatedScan != null) ...[
                      const SizedBox(height: AppSpacing.s8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                        child: Text(
                          l10n.taskRelatedScan,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Fraunces',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _Raised(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            onTap: () => context.push('/health-log'),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.s4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          relatedScan.diseaseDetected,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        Text(
                                          '${relatedScan.commonCrop} · '
                                          '${l10n.healthLogConfidence}: '
                                          '${relatedScan.confidenceScore.round()}%',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
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
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _confirmDelete(
                          context,
                          service,
                          currentEvent.id,
                          l10n,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.clay,
                          minimumSize: const Size(0, AppLayout.touchTarget),
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text(l10n.taskDetailDelete),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SmartCropsService service,
    String eventId,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.taskDeleteConfirmTitle),
        content: Text(l10n.taskDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.taskDeleteCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.clay),
            child: Text(l10n.taskDeleteAction),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await service.deleteCalendarEvent(eventId);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.taskDeleted)));
      }
    }
  }

  String _reasonText(CarePlanReason reason, AppLocalizations l10n) {
    switch (reason) {
      case CarePlanReason.weather:
        return l10n.taskReasonWeather;
      case CarePlanReason.overdue:
        return l10n.taskReasonOverdue;
      case CarePlanReason.scanAtRisk:
        return l10n.taskReasonScan;
      case CarePlanReason.routine:
        return l10n.taskReasonRoutine;
    }
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppLayout.touchTarget),
        backgroundColor: AppColors.surfaceSunken,
        foregroundColor: AppColors.textPrimary,
      ),
      icon: Icon(icon),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.urgent = false});

  final String text;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: urgent ? AppColors.statusCriticalSurface : AppColors.mist,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1 + 2,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: urgent ? AppColors.clay : AppColors.textSecondary,
            fontWeight: urgent ? FontWeight.w600 : null,
          ),
        ),
      ),
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
