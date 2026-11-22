import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/screens/cropcare_shell.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';
import 'package:smart_crops/cropcare/widgets/crop_glass_surface.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class CropCareResultScreen extends StatelessWidget {
  const CropCareResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CropCareShell(
      index: 2,
      child: Column(
        children: [
          AppBar(title: Text(l10n.cropCareScanResult)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: CropSpacing.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CropSpacing.s6,
                    ),
                    child: CropGlassSurface(
                      tone: CropGlassTone.raised,
                      padding: const EdgeInsets.all(CropSpacing.s5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: CropSpacing.s3,
                              vertical: CropSpacing.s2,
                            ),
                            decoration: BoxDecoration(
                              color: CropColors.primarySoft,
                              borderRadius: BorderRadius.circular(
                                CropRadius.pill,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: CropColors.healthy,
                                ),
                                const SizedBox(width: CropSpacing.s2),
                                Text(
                                  l10n.cropCareHealthy,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CropColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: CropSpacing.s3),
                          Text(
                            l10n.cropCareNoDiseaseDetected,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: CropColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Pechay · ${l10n.cropCareScannedToday}',
                            style: const TextStyle(
                              color: CropColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: CropSpacing.s4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '94%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: CropColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: CropSpacing.s2),
                              Text(
                                l10n.cropCareConfidence,
                                style: const TextStyle(
                                  color: CropColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(CropSpacing.s6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cropCareWhatNext,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: CropColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: CropSpacing.s3),
                        _Step(
                          title: l10n.cropCareKeepWateringMorning,
                          body: l10n.cropCareCheckSoilBeforeIrrigation,
                        ),
                        _Step(
                          title: l10n.cropCareWatchNewSpots,
                          body: l10n.cropCareScanAgainWeek,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CropSpacing.s6,
                    ),
                    child: FilledButton(
                      onPressed: () {},
                      child: Text(l10n.cropCareSaveToHealthLog),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(l10n.cropCareScanAgain),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: CropSpacing.s3),
      padding: const EdgeInsets.all(CropSpacing.s4),
      decoration: BoxDecoration(
        color: CropColors.surface,
        border: Border.all(color: CropColors.border),
        borderRadius: BorderRadius.circular(CropRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(body, style: const TextStyle(color: CropColors.textSecondary)),
        ],
      ),
    );
  }
}
