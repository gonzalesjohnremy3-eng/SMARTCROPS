import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

/// Branded immersive surface used for the Field Almanac's one memorable
/// moment per screen. The gradient is the approved fallback when generated
/// photography is unavailable (ADR 0011); it keeps text contrast intact.
class OverlayHero extends StatelessWidget {
  const OverlayHero({
    super.key,
    required this.eyebrow,
    required this.title,
    this.body,
    this.badge,
    this.height = 224,
    this.imagePath,
    this.onTap,
  });

  final String eyebrow;
  final String title;
  final String? body;
  final Widget? badge;
  final double height;
  final String? imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      container: true,
      label: title,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: height),
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.hero),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.canopy, AppColors.forestInk],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -64,
                top: -88,
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x2E7AC943),
                    ),
                  ),
                ),
              ),
              if (imagePath != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath!),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          AppColors.overlayScrim,
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x2612372A), AppColors.overlayScrim],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s6),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    if (badge != null) ...[badge!, const SizedBox(height: AppSpacing.s4)],
                    AnimatedSwitcher(
                      duration: reduceMotion ? Duration.zero : AppMotion.standard,
                      switchInCurve: AppMotion.standardCurve,
                      switchOutCurve: AppMotion.exitCurve,
                      child: Text(
                        eyebrow,
                        key: ValueKey<String>(eyebrow),
                        style: const TextStyle(
                          color: AppColors.leaf,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Public Sans',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    AnimatedSwitcher(
                      duration: reduceMotion ? Duration.zero : AppMotion.standard,
                      switchInCurve: AppMotion.standardCurve,
                      switchOutCurve: AppMotion.exitCurve,
                      child: Text(
                        title,
                        key: ValueKey<String>(title),
                        style: const TextStyle(
                          color: AppColors.textInverse,
                          fontFamily: 'Fraunces',
                          fontSize: 26,
                          height: 32 / 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        body!,
                        style: const TextStyle(
                          color: Color(0xD1FFFDF7),
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
