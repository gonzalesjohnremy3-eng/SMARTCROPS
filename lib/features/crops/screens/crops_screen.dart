import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cropsTitle)),
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

          final crops = service.userSelectedCrops;
          final scansByCrop = _scansByCrop(service.scanHistory);

          if (crops.isEmpty) {
            return _EmptyState(l10n: l10n, theme: theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: crops.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final crop = crops[index];
              return _CropCard(
                crop: crop,
                lastScan: scansByCrop[crop.cropName],
                l10n: l10n,
                theme: theme,
                onOpen: () => context.push('/crops/${crop.id}'),
                onScan: () => context.push('/scan'),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, ScanHistoryItem> _scansByCrop(List<ScanHistoryItem> history) {
    final map = <String, ScanHistoryItem>{};
    for (final scan in history) {
      map.putIfAbsent(scan.commonCrop, () => scan);
    }
    return map;
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
            Icon(Icons.grass_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.cropsEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.crop,
    required this.lastScan,
    required this.l10n,
    required this.theme,
    required this.onOpen,
    required this.onScan,
  });

  final CropItem crop;
  final ScanHistoryItem? lastScan;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onOpen;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final conditions = crop.optimalConditions;

    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    child: Icon(Icons.eco_outlined, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(crop.cropName, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          lastScan == null
                              ? l10n.cropsNoScans
                              : '${l10n.cropsLastScan}: ${lastScan!.scannedAt.month}/${lastScan!.scannedAt.day}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(l10n.cropsScanThisCrop),
                  ),
                ],
              ),
              if (conditions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.cropsGrowingConditions,
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  conditions.entries
                      .map((entry) => '${entry.key}: ${entry.value}')
                      .join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}