import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/features/calendar/domain/care_plan.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.carePlanTitle)),
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

          final rainMm = weather.currentWeather?.precipitationMm ?? 0;
          final forecast = WeatherForecast(precipitationMmNext24h: rainMm);
          final now = DateTime.now();
          final plan = buildCarePlan(
            events: service.calendarEvents,
            scans: service.scanHistory,
            now: now,
            forecast: forecast,
          );

          if (plan.isEmpty) {
            return _EmptyState(l10n: l10n, theme: theme);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (plan.today.isNotEmpty) ...[
                _SectionHeader(title: l10n.carePlanToday, theme: theme),
                const SizedBox(height: 8),
                ...plan.today.map((item) => _CarePlanItemCard(
                      item: item,
                      l10n: l10n,
                      theme: theme,
                      onToggle: (value) => service
                          .toggleCalendarEventCompletion(item.event.id, value),
                      onOpen: () =>
                          context.push('/calendar/events/${item.event.id}'),
                    )),
                const SizedBox(height: 8),
              ],
              if (plan.thisWeek.isNotEmpty) ...[
                _SectionHeader(title: l10n.carePlanThisWeek, theme: theme),
                const SizedBox(height: 8),
                ...plan.thisWeek.map((item) => _CarePlanItemCard(
                      item: item,
                      l10n: l10n,
                      theme: theme,
                      onToggle: (value) => service
                          .toggleCalendarEventCompletion(item.event.id, value),
                      onOpen: () =>
                          context.push('/calendar/events/${item.event.id}'),
                    )),
                const SizedBox(height: 8),
              ],
              if (plan.preventive.isNotEmpty) ...[
                _SectionHeader(title: l10n.carePlanPreventive, theme: theme),
                const SizedBox(height: 8),
                ...plan.preventive.map((item) => _CarePlanItemCard(
                      item: item,
                      l10n: l10n,
                      theme: theme,
                      onToggle: (value) => service
                          .toggleCalendarEventCompletion(item.event.id, value),
                      onOpen: () =>
                          context.push('/calendar/events/${item.event.id}'),
                    )),
                const SizedBox(height: 8),
              ],
              if (plan.suggestions.isNotEmpty) ...[
                _SectionHeader(title: l10n.carePlanSuggested, theme: theme),
                const SizedBox(height: 8),
                ...plan.suggestions.map((suggestion) => _SuggestionCard(
                      suggestion: suggestion,
                      l10n: l10n,
                      theme: theme,
                      onAdd: () => _addSuggestion(
                        context,
                        service,
                        suggestion,
                        l10n,
                      ),
                    )),
              ],
            ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.carePlanNoItems,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarePlanItemCard extends StatelessWidget {
  const _CarePlanItemCard({
    required this.item,
    required this.l10n,
    required this.theme,
    required this.onToggle,
    required this.onOpen,
  });

  final CarePlanItem item;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  String _reasonLabel() {
    switch (item.reason) {
      case CarePlanReason.weather:
        return l10n.carePlanReasonWeather;
      case CarePlanReason.overdue:
        return l10n.carePlanReasonOverdue;
      case CarePlanReason.scanAtRisk:
        return l10n.carePlanReasonScan;
      case CarePlanReason.routine:
        return l10n.carePlanReasonRoutine;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = item.event;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: event.isCompleted,
                onChanged: (value) => onToggle(value ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.eventTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(event.eventCategory, style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          text: l10n.carePlanItemReason,
                          theme: theme,
                        ),
                        _MetaChip(
                          text: _reasonLabel(),
                          theme: theme,
                          emphasized: item.reason == CarePlanReason.overdue,
                        ),
                        _MetaChip(
                          text:
                              '${item.effectiveDate.month}/${item.effectiveDate.day}',
                          theme: theme,
                        ),
                      ],
                    ),
                    if (item.isWeatherAdjusted && item.originalDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.water_drop_outlined,
                              size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${l10n.calendarWeatherAdjusted}: '
                              '${item.originalDate!.month}/${item.originalDate!.day} → '
                              '${item.effectiveDate.month}/${item.effectiveDate.day}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.l10n,
    required this.theme,
    required this.onAdd,
  });

  final CarePlanSuggestion suggestion;
  final AppLocalizations l10n;
  final ThemeData theme;
  final Future<void> Function() onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.carePlanSuggestionTitle(
                      suggestion.cropName,
                      suggestion.scan.diseaseDetected,
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.scan.diseaseDetected,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  _MetaChip(text: l10n.carePlanReasonScan, theme: theme),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              key: const Key('care_plan_add_suggestion'),
              onPressed: () => onAdd(),
              icon: const Icon(Icons.add),
              label: Text(l10n.carePlanAddToCalendar),
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emphasized
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest,
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
