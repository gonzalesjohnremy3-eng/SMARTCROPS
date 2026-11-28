import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;

class AdvisoriesScreen extends StatelessWidget {
  const AdvisoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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

          final notifications = service.notifications;
          final critical = notifications
              .where((notification) => notification.severity == 'critical')
              .toList();
          final reduceMotion =
              MediaQuery.maybeOf(context)?.disableAnimations ?? false;

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
                    // Wrap lets the action drop under long translations.
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.advisoriesTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        if (service.unreadNotificationCount > 0)
                          TextButton(
                            onPressed: () async {
                              context.trackEvent('advisory_marked_read');
                              for (final n in service.notifications) {
                                if (!n.isRead) {
                                  await service.markNotificationAsRead(n.id);
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.canopy,
                              minimumSize: const Size(0, AppLayout.touchTarget),
                            ),
                            child: Text(l10n.advisoriesMarkAllRead),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    if (notifications.isEmpty)
                      const _EmptyState()
                    else ...[
                      AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : AppMotion.standard,
                        switchInCurve: AppMotion.standardCurve,
                        switchOutCurve: AppMotion.exitCurve,
                        child: critical.isEmpty
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.s4,
                                ),
                                child: _CriticalBanner(
                                  key: const Key('critical-advisory-banner'),
                                  notification: critical.first,
                                ),
                              ),
                      ),
                      for (final notification in notifications) ...[
                        _AdvisoryCard(
                          notification: notification,
                          onMarkRead: () {
                            context.trackEvent('advisory_opened');
                            service.markNotificationAsRead(notification.id);
                          },
                        ),
                        const SizedBox(height: AppSpacing.s3),
                      ],
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
}

class _CriticalBanner extends StatelessWidget {
  const _CriticalBanner({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.statusCriticalSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.clay),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.advisoriesCriticalLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.clay,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    notification.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Fraunces',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              Icons.notifications_none_rounded,
              color: AppColors.canopy,
              size: AppSpacing.s10,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            AppLocalizations.of(context).advisoriesEmpty,
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

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({required this.notification, required this.onMarkRead});

  final AppNotification notification;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final unread = !notification.isRead;
    final created = notification.createdAt;

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
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: unread ? onMarkRead : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppLayout.touchTarget,
                  height: AppLayout.touchTarget,
                  decoration: BoxDecoration(
                    color: unread
                        ? AppColors.statusCriticalSurface
                        : AppColors.mist,
                    borderRadius: BorderRadius.circular(AppRadius.card - 4),
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
                    color: unread ? AppColors.clay : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: unread
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: unread
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Wrap(
                        spacing: AppSpacing.s2,
                        runSpacing: AppSpacing.s2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (unread)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.statusCriticalSurface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s3 - 2,
                                  vertical: AppSpacing.s1,
                                ),
                                child: Text(
                                  l10n.advisoriesUnread,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.clay,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            '${loc.formatMediumDate(created)} · '
                            '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(created))}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
