import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';

enum CalendarView { today, week, month }

class FieldCalendarScreen extends StatefulWidget {
  const FieldCalendarScreen({super.key});

  @override
  State<FieldCalendarScreen> createState() => _FieldCalendarScreenState();
}

class _FieldCalendarScreenState extends State<FieldCalendarScreen> {
  CalendarView _view = CalendarView.today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        actions: [
          SegmentedButton<CalendarView>(
            segments: [
              ButtonSegment(value: CalendarView.today, label: Text(l10n.calendarViewToday)),
              ButtonSegment(value: CalendarView.week, label: Text(l10n.calendarViewWeek)),
              ButtonSegment(value: CalendarView.month, label: Text(l10n.calendarViewMonth)),
            ],
            selected: {_view},
            onSelectionChanged: (selection) =>
                setState(() => _view = selection.first),
          ),
        ],
      ),
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

          final tasks = service.calendarEvents;
          final rainMm = weather.currentWeather?.precipitationMm ?? 0;
          final forecast = WeatherForecast(precipitationMmNext24h: rainMm);

          final adjusted = tasks
              .map((task) => adjustForWeather(event: task, forecast: forecast))
              .toList()
            ..sort((a, b) => a.adjustedDate.compareTo(b.adjustedDate));

          final visible = adjusted.where((item) {
            final now = DateTime.now();
            switch (_view) {
              case CalendarView.today:
                return _isSameDay(item.adjustedDate, now);
              case CalendarView.week:
                final weekFromNow = now.add(const Duration(days: 7));
                return item.adjustedDate.isAfter(now.subtract(const Duration(days: 1))) &&
                    item.adjustedDate.isBefore(weekFromNow);
              case CalendarView.month:
                return item.adjustedDate.month == now.month &&
                    item.adjustedDate.year == now.year;
            }
          }).toList();

          if (visible.isEmpty) {
            return _EmptyState(l10n: l10n, theme: theme);
          }

          final now = DateTime.now();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visible.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = visible[index];
              return _TaskCard(
                item: item,
                isOverdue: !item.event.isCompleted &&
                    item.adjustedDate.isBefore(now) &&
                    !_isSameDay(item.adjustedDate, now),
                l10n: l10n,
                theme: theme,
                onToggle: (value) =>
                    service.toggleCalendarEventCompletion(item.event.id, value),
              );
            },
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
            Icon(Icons.calendar_today_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.calendarEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.item,
    required this.isOverdue,
    required this.l10n,
    required this.theme,
    required this.onToggle,
  });

  final WeatherAdjustment item;
  final bool isOverdue;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final event = item.event;

    return Card(
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
                  Text(
                    event.eventTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration: event.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetaChip(text: event.eventCategory, theme: theme),
                      if (event.priority == 'High')
                        _MetaChip(text: '!', theme: theme, emphasized: true),
                      if (isOverdue)
                        _MetaChip(
                          text: l10n.calendarOverdue,
                          theme: theme,
                          emphasized: true,
                        ),
                      if (!item.isAdjusted)
                        _MetaChip(text: _formatDate(event.scheduledDate), theme: theme),
                    ],
                  ),
                  if (item.isAdjusted) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.water_drop_outlined,
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l10n.calendarWeatherAdjusted}: ${_formatDate(item.originalDate)} → ${_formatDate(item.adjustedDate)}',
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
    );
  }

  String _formatDate(DateTime date) =>
      '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.text,
    required this.theme,
    this.emphasized = false,
  });

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