import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/screens/cropcare_shell.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';
import 'package:smart_crops/cropcare/widgets/crop_glass_surface.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class CropCareHomeScreen extends StatelessWidget {
  const CropCareHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return CropCareShell(
      index: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: CropSpacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CropSpacing.s6,
                CropSpacing.s6,
                CropSpacing.s6,
                CropSpacing.s5,
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: CropColors.primary, size: 32),
                  const SizedBox(width: CropSpacing.s2 + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CropCare',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: CropColors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.cropCareTagline,
                          style: const TextStyle(
                            fontSize: 11,
                            color: CropColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.82, end: 1),
                    duration: Duration(milliseconds: reduceMotion ? 0 : 180),
                    curve: Curves.easeOut,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: CropGlassSurface(
                      blur: true,
                      padding: const EdgeInsets.all(12),
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            color: CropColors.primary,
                            size: 24,
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CropColors.accent,
                                borderRadius: BorderRadius.circular(
                                  CropRadius.pill,
                                ),
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: CropColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CropSpacing.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cropCareGoodMorning,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: CropColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.cropCareFarmerExclaim,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: CropColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CropSpacing.s2),
                  Text(
                    l10n.cropCareKeepCropsHealthy,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CropColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CropSpacing.s5),
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: CropSpacing.s6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CropRadius.lg),
                image: const DecorationImage(
                  image: AssetImage('assets/images/overlays/home.webp'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    CropColors.primaryDark,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(CropSpacing.s4),
                  child: Text(
                    l10n.cropCareScanDetectProtect,
                    style: const TextStyle(
                      color: CropColors.inverse,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CropSpacing.s6,
                vertical: CropSpacing.s4,
              ),
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.crop_free),
                label: Text(l10n.cropCareScanYourCrop),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CropSpacing.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cropCareQuickAccess,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CropColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CropSpacing.s3),
                  Row(
                    children: [
                      _Tile(icon: Icons.history, label: l10n.cropCareHistory),
                      _Tile(icon: Icons.eco, label: l10n.cropCareCrops),
                      _Tile(
                        icon: Icons.support_agent,
                        label: l10n.cropCareSupport,
                      ),
                      _Tile(icon: Icons.settings, label: l10n.cropCareSettings),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                CropSpacing.s6,
                CropSpacing.s6,
                CropSpacing.s6,
                CropSpacing.s4,
              ),
              padding: const EdgeInsets.all(CropSpacing.s5),
              decoration: BoxDecoration(
                color: CropColors.primary,
                borderRadius: BorderRadius.circular(CropRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: CropColors.inverse, size: 28),
                  const SizedBox(width: CropSpacing.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cropCareYourCrops,
                          style: const TextStyle(color: CropColors.inverse),
                        ),
                        Text(
                          l10n.cropCareHealthy,
                          style: const TextStyle(
                            color: CropColors.inverse,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.cropCareNoRecentDisease,
                          style: const TextStyle(color: CropColors.inverse),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: CropSpacing.s6),
              padding: const EdgeInsets.all(CropSpacing.s4),
              decoration: BoxDecoration(
                color: CropColors.surface,
                border: Border.all(color: CropColors.border),
                borderRadius: BorderRadius.circular(CropRadius.md),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(CropRadius.sm),
                    child: Image.asset(
                      'assets/images/overlays/crop_detail.webp',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: CropSpacing.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cropCareKeepSoilHealthy,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          l10n.cropCareHealthySoilBody,
                          style: const TextStyle(
                            color: CropColors.textSecondary,
                          ),
                        ),
                      ],
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

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: CropSpacing.s3),
        padding: const EdgeInsets.symmetric(vertical: CropSpacing.s4),
        decoration: BoxDecoration(
          color: CropColors.surface,
          border: Border.all(color: CropColors.border),
          borderRadius: BorderRadius.circular(CropRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: CropColors.primary, size: 20),
            const SizedBox(height: CropSpacing.s2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
