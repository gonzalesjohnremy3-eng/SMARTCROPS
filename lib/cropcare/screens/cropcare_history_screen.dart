import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/screens/cropcare_shell.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';
import 'package:smart_crops/cropcare/widgets/crop_glass_surface.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class CropCareHistoryScreen extends StatelessWidget {
  const CropCareHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CropCareShell(
      index: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: CropSpacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CropSpacing.s4,
                CropSpacing.s4,
                CropSpacing.s4,
                CropSpacing.s5,
              ),
              child: CropGlassSurface(
                tone: CropGlassTone.raised,
                padding: const EdgeInsets.symmetric(
                  horizontal: CropSpacing.s5,
                  vertical: CropSpacing.s4,
                ),
                borderRadius: BorderRadius.circular(CropRadius.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.cropCareScanHistory,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: CropColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.search, color: CropColors.primary),
                  ],
                ),
              ),
            ),
            _HistoryCard(
              status: l10n.cropCareHealthy,
              crop: 'Pechay',
              detail: '${l10n.cropCareToday} · 94% ${l10n.cropCareConfidence}',
              healthy: true,
            ),
            _HistoryCard(
              status: l10n.cropCareNeedsAttention,
              crop: 'Tomato',
              detail: '${l10n.cropCareDaysAgo(3)} · ${l10n.cropCareLeafSpots}',
              healthy: false,
            ),
            _HistoryCard(
              status: l10n.cropCareHealthy,
              crop: 'Rice',
              detail:
                  '${l10n.cropCareLastWeek} · 91% ${l10n.cropCareConfidence}',
              healthy: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.status,
    required this.crop,
    required this.detail,
    required this.healthy,
  });

  final String status;
  final String crop;
  final String detail;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    final statusColor = healthy ? CropColors.healthy : CropColors.warning;
    final statusSurface = healthy
        ? CropColors.primarySoft
        : CropColors.warningSurface;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        CropSpacing.s6,
        0,
        CropSpacing.s6,
        CropSpacing.s3,
      ),
      padding: const EdgeInsets.all(CropSpacing.s4),
      decoration: BoxDecoration(
        color: CropColors.surface,
        border: Border.all(color: CropColors.border),
        borderRadius: BorderRadius.circular(CropRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CropSpacing.s3,
              vertical: CropSpacing.s2,
            ),
            decoration: BoxDecoration(
              color: statusSurface,
              borderRadius: BorderRadius.circular(CropRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  healthy ? Icons.check : Icons.warning_amber,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: CropSpacing.s2),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CropSpacing.s3),
          Text(crop, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(detail, style: const TextStyle(color: CropColors.textSecondary)),
        ],
      ),
    );
  }
}
