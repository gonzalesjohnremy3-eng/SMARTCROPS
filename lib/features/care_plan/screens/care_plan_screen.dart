import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.carePlanTitle)),
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

          final items = service.calendarEvents
              .where((event) => !event.isCompleted)
              .toList()
            ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

          if (items.isEmpty) {
            return _EmptyState(l10n: l10n, theme: theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _CarePlanItemCard(
                event: items[index],
                l10n: l10n,
                theme: theme,
                onComplete: (value) =>
                    service.toggleCalendarEventCompletion(items[index].id, value),
              );
            },
          );
        },
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
    required this.event,
    required this.l10n,
    required this.theme,
    required this.onComplete,
  });

  final CropCalendarEvent event;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ValueChanged<bool> onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: false, onChanged: (value) => onComplete(value ?? false)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.eventTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(event.eventCategory, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  _MetaChip(text: '${event.scheduledDate.month}/${event.scheduledDate.day}', theme: theme),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              tooltip: l10n.carePlanOpenTask,
              onPressed: () => context.go('/calendar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }
}