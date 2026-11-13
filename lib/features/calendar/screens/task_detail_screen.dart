import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/features/calendar/domain/care_plan.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/features/calendar/widgets/task_form_sheet.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.event});

  final CropCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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

        final rainMm = weather.currentWeather?.precipitationMm ?? 0;
        final adjustment = adjustForWeather(
          event: currentEvent,
          forecast: WeatherForecast(precipitationMmNext24h: rainMm),
        );

        final reason = resolveEventReason(
          event: currentEvent,
          scans: service.scanHistory,
          now: DateTime.now(),
          forecast: WeatherForecast(precipitationMmNext24h: rainMm),
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
          final matchesCropId = currentEvent.cropId != null &&
              s.commonCrop.toLowerCase() == currentEvent.cropId;
          final matchesTitle = currentEvent.eventTitle
              .toLowerCase()
              .contains(s.commonCrop.toLowerCase());
          if (matchesCropId || matchesTitle) {
            relatedScan = s;
            break;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.taskDetailTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.taskDetailEdit,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: service,
                      child: TaskFormSheet(event: currentEvent),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.taskDetailDelete,
                onPressed: () async {
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
                          child: Text(l10n.taskDeleteAction),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await service.deleteCalendarEvent(currentEvent.id);
                    if (context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.taskDeleted)),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: currentEvent.isCompleted,
                      onChanged: (val) => service.toggleCalendarEventCompletion(
                        currentEvent.id,
                        val ?? false,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentEvent.eventTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          decoration: currentEvent.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(text: currentEvent.eventCategory, theme: theme),
                    _MetaChip(text: currentEvent.priority, theme: theme, emphasized: currentEvent.priority == 'High'),
                    if (crop != null) _MetaChip(text: crop.cropName, theme: theme),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.taskScheduledFor, style: theme.textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${adjustment.adjustedDate.month}/${adjustment.adjustedDate.day}/${adjustment.adjustedDate.year} at ${adjustment.adjustedDate.hour.toString().padLeft(2, '0')}:${adjustment.adjustedDate.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (adjustment.isAdjusted) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.water_drop_outlined, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.taskReasonWeather,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(l10n.taskWhyThisDate, style: theme.textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(
                          _reasonText(reason, l10n),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                if (relatedScan != null) ...[
                  const SizedBox(height: 24),
                  Text(l10n.taskRelatedScan, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: Text(relatedScan.diseaseDetected),
                      subtitle: Text('${relatedScan.commonCrop} - ${relatedScan.confidenceScore.toStringAsFixed(0)}% confidence'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/health-log'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text, required this.theme, this.emphasized = false});

  final String text;
  final ThemeData theme;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized ? theme.colorScheme.errorContainer : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: emphasized ? FontWeight.w600 : null,
          color: emphasized ? theme.colorScheme.onErrorContainer : null,
        ),
      ),
    );
  }
}
