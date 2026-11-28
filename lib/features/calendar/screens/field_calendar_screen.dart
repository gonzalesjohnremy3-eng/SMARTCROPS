import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/features/calendar/widgets/task_form_sheet.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

enum CalendarView { today, week, month }

class FieldCalendarScreen extends StatefulWidget {
  const FieldCalendarScreen({super.key, this.now});

  /// Fixes the clock for tests; the app always uses the real time.
  final DateTime? now;

  @override
  State<FieldCalendarScreen> createState() => _FieldCalendarScreenState();
}

class _FieldCalendarScreenState extends State<FieldCalendarScreen> {
  CalendarView _view = CalendarView.today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = widget.now ?? DateTime.now();

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
          final adjusted =
              service.calendarEvents
                  .map(
                    (task) => adjustForWeather(event: task, forecast: forecast),
                  )
                  .where((item) => _isVisible(item.adjustedDate, now))
                  .toList()
                ..sort((a, b) => a.adjustedDate.compareTo(b.adjustedDate));

          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s4,
                AppSpacing.s5,
                // Room for the add button so it never covers the last task.
                AppSpacing.s12 + AppSpacing.s10,
              ),
              children: [
                Text(
                  l10n.calendarTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                _ViewPills(
                  selected: _view,
                  onSelected: (view) {
                    context.trackEvent(
                      'calendar_view_changed',
                      params: {'view': view.name},
                    );
                    setState(() => _view = view);
                  },
                ),
                const SizedBox(height: AppSpacing.s6),
                if (adjusted.isEmpty)
                  const _EmptyState()
                else
                  ..._days(context, service, adjusted, now),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<SmartCropsService>(
        builder: (context, service, child) => FloatingActionButton.extended(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => ChangeNotifierProvider.value(
              value: service,
              child: const TaskFormSheet(),
            ),
          ),
          backgroundColor: AppColors.actionPrimary,
          foregroundColor: AppColors.textInverse,
          shape: const StadiumBorder(),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.calendarAddTask),
        ),
      ),
    );
  }

  List<Widget> _days(
    BuildContext context,
    SmartCropsService service,
    List<WeatherAdjustment> items,
    DateTime now,
  ) {
    final l10n = AppLocalizations.of(context);
    final days = <DateTime, List<WeatherAdjustment>>{};
    for (final item in items) {
      final d = item.adjustedDate;
      days.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(item);
    }

    return [
      for (final day in days.entries) ...[
        if (_view != CalendarView.today)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s2),
            child: Text(
              _isSameDay(day.key, now)
                  ? l10n.calendarToday
                  : MaterialLocalizations.of(context).formatMediumDate(day.key),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              for (var i = 0; i < day.value.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.s4,
                    endIndent: AppSpacing.s4,
                    color: AppColors.borderSubtle,
                  ),
                _TaskRow(
                  item: day.value[i],
                  isOverdue:
                      !day.value[i].event.isCompleted &&
                      day.value[i].adjustedDate.isBefore(now) &&
                      !_isSameDay(day.value[i].adjustedDate, now),
                  onToggle: (value) {
                    context.trackEvent('task_completed');
                    service.toggleCalendarEventCompletion(
                      day.value[i].event.id,
                      value,
                    );
                  },
                  onTap: () =>
                      context.push('/calendar/events/${day.value[i].event.id}'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
      ],
    ];
  }

  bool _isVisible(DateTime date, DateTime now) {
    switch (_view) {
      case CalendarView.today:
        return _isSameDay(date, now);
      case CalendarView.week:
        return date.isAfter(now.subtract(const Duration(days: 1))) &&
            date.isBefore(now.add(const Duration(days: 7)));
      case CalendarView.month:
        return date.month == now.month && date.year == now.year;
    }
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _ViewPills extends StatelessWidget {
  const _ViewPills({required this.selected, required this.onSelected});

  final CalendarView selected;
  final ValueChanged<CalendarView> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      CalendarView.today: l10n.calendarViewToday,
      CalendarView.week: l10n.calendarViewWeek,
      CalendarView.month: l10n.calendarViewMonth,
    };

    return Wrap(
      spacing: AppSpacing.s2,
      runSpacing: AppSpacing.s2,
      children: [
        for (final view in CalendarView.values)
          Semantics(
            button: true,
            selected: view == selected,
            child: Material(
              key: Key('calendar_view_${view.name}'),
              color: view == selected ? AppColors.canopy : AppColors.mist,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelected(view),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppLayout.touchTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        labels[view]!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: view == selected
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Column(
        children: [
          const ReticleFrame(
            padding: EdgeInsets.all(AppSpacing.s5),
            child: Icon(
              Icons.event_available_outlined,
              color: AppColors.canopy,
              size: AppSpacing.s10,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            AppLocalizations.of(context).calendarEmpty,
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

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.item,
    required this.isOverdue,
    required this.onToggle,
    required this.onTap,
  });

  final WeatherAdjustment item;
  final bool isOverdue;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final event = item.event;
    final done = event.isCompleted;
    final time = loc.formatTimeOfDay(TimeOfDay.fromDateTime(item.adjustedDate));

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
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
                      '${event.eventCategory} · $time',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (isOverdue || event.priority == 'High') ...[
                      const SizedBox(height: AppSpacing.s2),
                      Wrap(
                        spacing: AppSpacing.s2,
                        runSpacing: AppSpacing.s2,
                        children: [
                          if (isOverdue) _Pill(l10n.calendarOverdue),
                          if (event.priority == 'High')
                            _Pill(l10n.calendarHighPriority),
                        ],
                      ),
                    ],
                    if (item.isAdjusted) ...[
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
                              '${loc.formatShortMonthDay(item.originalDate)} → '
                              '${loc.formatShortMonthDay(item.adjustedDate)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.canopy,
                              ),
                            ),
                          ),
                        ],
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

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.statusCriticalSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3 - 2,
          vertical: AppSpacing.s1,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.clay,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
