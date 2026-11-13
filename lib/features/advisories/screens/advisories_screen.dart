import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class AdvisoriesScreen extends StatelessWidget {
  const AdvisoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advisoriesTitle),
        actions: [
          Consumer<SmartCropsService>(
            builder: (context, service, child) {
              final unread = service.unreadNotificationCount;
              if (unread == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  for (final notification in service.notifications) {
                    if (!notification.isRead) {
                      await service.markNotificationAsRead(notification.id);
                    }
                  }
                },
                child: Text(l10n.advisoriesMarkAllRead),
              );
            },
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

          final notifications = service.notifications;

          if (notifications.isEmpty) {
            return _EmptyState(l10n: l10n, theme: theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _AdvisoryCard(
                notification: notifications[index],
                l10n: l10n,
                theme: theme,
                onMarkRead: () =>
                    service.markNotificationAsRead(notifications[index].id),
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
            Icon(Icons.notifications_none,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.advisoriesEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({
    required this.notification,
    required this.l10n,
    required this.theme,
    required this.onMarkRead,
  });

  final AppNotification notification;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Card(
      child: InkWell(
        onTap: unread ? onMarkRead : null,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unread
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: unread
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (unread)
                          _MetaChip(
                            text: l10n.advisoriesUnread,
                            theme: theme,
                            emphasized: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(notification.message, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${notification.createdAt.month}/${notification.createdAt.day}/${notification.createdAt.year}  ${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.labelSmall,
                    ),
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
          color: emphasized
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: emphasized ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}