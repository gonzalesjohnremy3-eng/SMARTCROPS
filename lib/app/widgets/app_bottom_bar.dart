import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

/// The five-destination bottom bar: a raised island that floats above the
/// phone's gesture area. Scan, the app's main job, is always the filled,
/// primary destination; the current one is marked with a soft capsule.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  /// Position of Scan in the bar.
  static const scanIndex = 2;

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome, l10n.navHome),
      (
        Icons.grass_outlined,
        Icons.grass_rounded,
        l10n.navCrops,
        l10n.cropsTitle,
      ),
      (
        Icons.photo_camera_outlined,
        Icons.photo_camera_rounded,
        l10n.navScan,
        l10n.homeScanCTA,
      ),
      (
        Icons.calendar_today_outlined,
        Icons.calendar_today_rounded,
        l10n.navCalendar,
        l10n.calendarTitle,
      ),
      (
        Icons.person_outline_rounded,
        Icons.person_rounded,
        l10n.navProfile,
        l10n.navProfile,
      ),
    ];
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s2,
        AppSpacing.s4,
        bottomInset + AppSpacing.s3,
      ),
      child: DecoratedBox(
        key: const Key('bottom_nav_bar'),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadius.hero),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestInk.withValues(alpha: 0.10),
              blurRadius: AppSpacing.s6,
              offset: const Offset(0, AppSpacing.s2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s1,
            vertical: AppSpacing.s1,
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    key: i == scanIndex ? const Key('nav_scan') : null,
                    itemKey: Key('nav_item_$i'),
                    indicatorKey: Key('nav_indicator_$i'),
                    icon: i == currentIndex ? items[i].$2 : items[i].$1,
                    label: items[i].$3,
                    tooltip: items[i].$4,
                    selected: i == currentIndex,
                    primary: i == scanIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.itemKey,
    required this.indicatorKey,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  final Key itemKey;
  final Key indicatorKey;
  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final theme = Theme.of(context);
    final indicator = primary
        ? AppColors.actionPrimary
        : selected
        ? AppColors.mist
        : Colors.transparent;
    final iconColor = primary
        ? AppColors.textInverse
        : selected
        ? AppColors.canopy
        : AppColors.textSecondary;

    return Semantics(
      key: itemKey,
      container: true,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  key: indicatorKey,
                  duration: reduceMotion ? Duration.zero : AppMotion.standard,
                  curve: AppMotion.standardCurve,
                  width: primary
                      ? AppSpacing.s16
                      : AppSpacing.s12 + AppSpacing.s2,
                  height: AppSpacing.s8,
                  decoration: BoxDecoration(
                    color: indicator,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Icon(icon, size: AppSpacing.s6, color: iconColor),
                ),
                const SizedBox(height: AppSpacing.s1),
                // Large text scales the labels down to fit instead of
                // overflowing a bar that has only five slots.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected
                          ? AppColors.canopy
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
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
