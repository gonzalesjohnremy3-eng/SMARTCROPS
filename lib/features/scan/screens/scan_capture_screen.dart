import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/analytics/analytics_view.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/domain/scan_quota.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/features/scan/screens/scan_review_screen.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class ScanCaptureScreen extends StatefulWidget {
  const ScanCaptureScreen({super.key});

  @override
  State<ScanCaptureScreen> createState() => _ScanCaptureScreenState();
}

class _ScanCaptureScreenState extends State<ScanCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedCropName;

  Future<void> _capture(String cropName, ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (!mounted) return;
        context.trackEvent('camera_permission_denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorPermission)),
        );
        return;
      }
    }

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;
    context.trackEvent(
      source == ImageSource.camera ? 'scan_photo_taken' : 'scan_gallery_opened',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyticsView(
          event: 'scan_review_viewed',
          child: ScanReviewScreen(imageFile: picked, cropName: cropName),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final cropNames = [
      for (final crop
          in service.userSelectedCrops.isNotEmpty
              ? service.userSelectedCrops
              : service.availableCrops)
        crop.cropName,
    ];
    final cropName = cropNames.contains(_selectedCropName)
        ? _selectedCropName
        : cropNames.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.forestInk,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              // The guide photo takes the space the controls leave.
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s5,
                    AppSpacing.s4,
                    AppSpacing.s5,
                    AppSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.scanCaptureTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: _QuotaChip(),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      const Expanded(child: _ViewfinderGuide()),
                      const SizedBox(height: AppSpacing.s5),
                      _CropPicker(
                        cropNames: cropNames,
                        selected: cropName,
                        onSelected: (name) {
                          context.trackEvent('scan_crop_changed');
                          setState(() => _selectedCropName = name);
                        },
                      ),
                      const SizedBox(height: AppSpacing.s5),
                      _Controls(
                        onShutter: cropName == null
                            ? null
                            : () => _capture(cropName, ImageSource.camera),
                        onUpload: cropName == null
                            ? null
                            : () => _capture(cropName, ImageSource.gallery),
                      ),
                    ],
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

class _QuotaChip extends StatelessWidget {
  const _QuotaChip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final isPro = context.watch<AgriProEntitlement>().isPro;
    final now = DateTime.now();
    final quota = evaluateScanQuota(
      tier: isPro ? PlanTier.pro : PlanTier.free,
      scansUsedThisWeek: scansThisWeek(service.scanHistory, now),
      queuedScans: context.watch<ScanQueueProvider>().queuedCount,
      now: now,
    );
    final isOut = !quota.allowed;
    final accent = isPro
        ? AppColors.palay
        : isOut
        ? AppColors.clay
        : AppColors.leaf;

    return Material(
      color: accent.withValues(alpha: 0.16),
      shape: StadiumBorder(
        side: BorderSide(color: accent.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isPro ? null : () => context.push('/pro', extra: 'quota'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s1 + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPro ? Icons.workspace_premium_outlined : Icons.bolt_rounded,
                size: AppSpacing.s4,
                color: accent,
              ),
              const SizedBox(width: AppSpacing.s2),
              Flexible(
                child: Text(
                  isPro
                      ? l10n.scanQuotaUnlimited
                      : l10n.scanQuotaLeft(quota.remaining ?? 0),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textInverse,
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

/// An example of a good scan: one diseased leaf filling the reticle.
class _ViewfinderGuide extends StatelessWidget {
  const _ViewfinderGuide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 240),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/overlays/scan.webp'),
              fit: BoxFit.cover,
              alignment: Alignment(0.25, 0),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.forestInk.withValues(alpha: 0.15),
                  AppColors.forestInk.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Semantics(
              label: l10n.scanCaptureGuidance,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s4),
                child: Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: ReticleFrame(
                          arm: AppSpacing.s8,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16 + AppSpacing.s8,
                            vertical: AppSpacing.s12,
                          ),
                          child: SizedBox.shrink(),
                        ),
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: [
                        _TipChip(
                          icon: Icons.eco_outlined,
                          label: l10n.scanTipOneLeaf,
                        ),
                        _TipChip(
                          icon: Icons.crop_free_rounded,
                          label: l10n.scanTipFillFrame,
                        ),
                        _TipChip(
                          icon: Icons.wb_sunny_outlined,
                          label: l10n.scanTipNoShadows,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.forestInk.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.textInverse.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1 + 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.s4, color: AppColors.leaf),
            const SizedBox(width: AppSpacing.s1 + 2),
            Flexible(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.textInverse),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropPicker extends StatelessWidget {
  const _CropPicker({
    required this.cropNames,
    required this.selected,
    required this.onSelected,
  });

  final List<String> cropNames;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = AppColors.textInverse.withValues(alpha: 0.75);

    if (cropNames.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.scanNoCrops,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/crops'),
            style: TextButton.styleFrom(foregroundColor: AppColors.leaf),
            child: Text(l10n.scanAddCrops),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scanWhichCrop,
          style: theme.textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.s2),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final name in cropNames)
              Semantics(
                button: true,
                selected: name == selected,
                child: Material(
                  color: name == selected ? AppColors.leaf : Colors.transparent,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: name == selected
                          ? AppColors.leaf
                          : AppColors.textInverse.withValues(alpha: 0.3),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelected(name),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppLayout.touchTarget - AppSpacing.s2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                          vertical: AppSpacing.s2,
                        ),
                        child: Text(
                          name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: name == selected
                                ? AppColors.forestInk
                                : AppColors.textInverse,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.onShutter, required this.onUpload});

  final VoidCallback? onShutter;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    const shutter = AppSpacing.s16 + AppSpacing.s4;
    const side = AppLayout.touchTarget + AppSpacing.s2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              IconButton(
                tooltip: l10n.scanUploadPhoto,
                onPressed: onUpload,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(side),
                  backgroundColor: AppColors.textInverse.withValues(alpha: 0.1),
                  foregroundColor: AppColors.textInverse,
                ),
                icon: const Icon(Icons.photo_library_outlined),
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                l10n.scanUploadPhoto,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textInverse.withValues(
                alpha: onShutter == null ? 0.3 : 0.9,
              ),
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s1),
            child: IconButton(
              key: const Key('capture_button'),
              tooltip: l10n.scanTakePhoto,
              onPressed: onShutter,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(shutter - AppSpacing.s3),
                backgroundColor: AppColors.leaf,
                foregroundColor: AppColors.forestInk,
                disabledBackgroundColor: AppColors.textInverse.withValues(
                  alpha: 0.15,
                ),
              ),
              icon: const Icon(Icons.photo_camera_rounded, size: AppSpacing.s8),
            ),
          ),
        ),
        // Balances the Upload column so the shutter stays centred.
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
