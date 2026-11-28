import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

/// The five-destination bottom bar: a raised island that floats above the
/// phone's gesture area. Scan, the app's main job, is a round button that
/// rises out of the middle of the island; the current destination is marked
/// with a soft capsule.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  /// Position of Scan in the bar.
  static const scanIndex = 2;

  // How far the Scan button rises above the island's top edge.
  static const _scanLift = AppSpacing.s6 + AppSpacing.s1;

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
      // The lift sits inside the widget's own height so the raised part of
      // Scan is tappable; a Stack ignores touches outside its bounds.
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _scanLift),
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
                padding: const EdgeInsets.all(AppSpacing.s1),
                // The Scan label aligns to the bottom, which would otherwise
                // fill any height the bar is offered.
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: i == scanIndex
                              ? _ScanLabel(
                                  label: items[i].$3,
                                  onTap: () => onSelected(i),
                                )
                              : _NavItem(
                                  itemKey: Key('nav_item_$i'),
                                  indicatorKey: Key('nav_indicator_$i'),
                                  icon: i == currentIndex
                                      ? items[i].$2
                                      : items[i].$1,
                                  label: items[i].$3,
                                  tooltip: items[i].$4,
                                  selected: i == currentIndex,
                                  onTap: () => onSelected(i),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _ScanButton(
                key: const Key('nav_scan'),
                icon: items[scanIndex].$2,
                label: items[scanIndex].$3,
                tooltip: items[scanIndex].$4,
                selected: currentIndex == scanIndex,
                onTap: () => onSelected(scanIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.itemKey,
    required this.indicatorKey,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final Key itemKey;
  final Key indicatorKey;
  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final theme = Theme.of(context);
    final indicator = selected ? AppColors.mist : Colors.transparent;
    final iconColor = selected ? AppColors.canopy : AppColors.textSecondary;

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
                  width: AppSpacing.s12 + AppSpacing.s2,
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

/// The label under the raised Scan button, keeping the five labels on one
/// baseline. The button itself carries the semantics.
class _ScanLabel extends StatelessWidget {
  const _ScanLabel({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.canopy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The round Scan button. A paper-coloured ring around it reads as a notch
/// cut into the island, and it presses in like a physical button.
class _ScanButton extends StatefulWidget {
  const _ScanButton({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : AppMotion.fast;

    return Semantics(
      key: const Key('nav_item_2'),
      container: true,
      button: true,
      selected: widget.selected,
      label: widget.label,
      excludeSemantics: true,
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: duration,
          curve: AppMotion.standardCurve,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.paper,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s1),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkResponse(
                  customBorder: const CircleBorder(),
                  onTap: widget.onTap,
                  onHighlightChanged: (down) => setState(() => _pressed = down),
                  child: Container(
                    key: const Key('nav_indicator_2'),
                    width: AppSpacing.s16,
                    height: AppSpacing.s16,
                    decoration: BoxDecoration(
                      color: AppColors.actionPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.actionPrimary.withValues(
                            alpha: 0.30,
                          ),
                          blurRadius: AppSpacing.s5,
                          offset: const Offset(0, AppSpacing.s2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: AppSpacing.s8,
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
