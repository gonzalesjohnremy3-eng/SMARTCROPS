import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/domain/scan_quota.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

String scanImageExtension(XFile file) {
  final name = file.name.contains('.') ? file.name : file.path.split('/').last;
  final dot = name.lastIndexOf('.');
  return dot < 0 ? 'jpg' : name.substring(dot + 1).toLowerCase();
}

/// What `/scan/review` needs, passed as the route's `extra`.
typedef ScanReviewRequest = ({XFile image, String cropName});

class ScanReviewScreen extends StatefulWidget {
  const ScanReviewScreen({
    super.key,
    required this.imageFile,
    required this.cropName,
  });

  final XFile imageFile;
  final String cropName;

  @override
  State<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

/// How long a photo upload may take before the scan is queued for later.
const _uploadTimeout = Duration(seconds: 45);

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _analyze() async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<SmartCropsService>();
    final queueProvider = context.read<ScanQueueProvider>();
    final entitlement = context.read<AgriProEntitlement>();

    final usedThisWeek = scansThisWeek(service.scanHistory, DateTime.now());
    final quota = evaluateScanQuota(
      tier: entitlement.isPro ? PlanTier.pro : PlanTier.free,
      scansUsedThisWeek: usedThisWeek,
      queuedScans: queueProvider.queuedCount,
      now: DateTime.now(),
    );
    if (!quota.allowed) {
      context.push('/pro', extra: 'quota');
      return;
    }

    context.trackEvent('scan_analyze_started');

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final isOnline = await _hasConnectivity();

      if (!isOnline) {
        await _queueAndReturn(queueProvider);
        if (mounted) context.trackEvent('scan_queued_offline');
        return;
      }

      final uploader = _SupabaseStorageUploader(service);
      debugPrint('scan: uploading photo');
      // A stalled upload falls into the catch below, which queues the scan.
      final imageUrl = await uploader
          .upload(widget.imageFile)
          .timeout(_uploadTimeout);
      debugPrint('scan: photo uploaded');

      final result = await service.performAiScan(imageUrl, widget.cropName);
      debugPrint(
        'scan: analysis finished (${result == null ? 'failed' : 'ok'})',
      );

      if (!mounted) return;

      if (result == null) {
        context.trackEvent('scan_failed');
        setState(() => _errorMessage = l10n.scanAnalyzeFailed);
        return;
      }

      final input = DiagnosisInput(
        diseaseDetected: result.diseaseDetected,
        confidenceScore: result.confidenceScore,
        commonCrop: result.commonCrop,
        recommendedActions: result.recommendedActions
            .map((action) => action.toString())
            .toList(),
        isDemo: result.source == 'demo_offline',
      );

      context.trackEvent('scan_analyzed', params: {'source': result.source});
      context.pushReplacement('/scan/result', extra: input);
    } catch (_) {
      if (!mounted) return;
      // Network or upload failure: queue the scan for later analysis.
      try {
        await _queueAndReturn(queueProvider);
      } catch (_) {
        if (mounted) setState(() => _errorMessage = l10n.scanAnalyzeFailed);
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _queueAndReturn(ScanQueueProvider queueProvider) async {
    await queueProvider.enqueueScan(
      localImagePath: widget.imageFile.path,
      cropName: widget.cropName,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).scanQueuedOffline)),
    );
    context.go('/scan');
  }

  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  void _retake() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/scan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = AppColors.textInverse.withValues(alpha: 0.75);

    return Scaffold(
      backgroundColor: AppColors.forestInk,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s5,
                    AppSpacing.s3,
                    AppSpacing.s5,
                    AppSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: l10n.scanReviewRetake,
                            onPressed: _isAnalyzing ? null : _retake,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.textInverse.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AppColors.textInverse,
                            ),
                            icon: const Icon(Icons.close_rounded),
                          ),
                          const Spacer(),
                          Flexible(child: _CropPill(name: widget.cropName)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Expanded(
                        child: _PhotoFrame(
                          image: widget.imageFile,
                          isAnalyzing: _isAnalyzing,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        l10n.scanReviewQuestion,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        l10n.scanReviewHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.palay,
                              size: AppSpacing.s5,
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textInverse,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s6),
                      PillButton(
                        label: _isAnalyzing
                            ? l10n.scanAnalyzing
                            : l10n.scanReviewAnalyze,
                        isLoading: _isAnalyzing,
                        onPressed: _analyze,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      TextButton(
                        onPressed: _isAnalyzing ? null : _retake,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textInverse,
                          minimumSize: const Size.fromHeight(
                            AppLayout.touchTarget,
                          ),
                        ),
                        child: Text(l10n.scanReviewRetake),
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

class _CropPill extends StatelessWidget {
  const _CropPill({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.leaf.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.leaf.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1 + 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.eco_outlined,
              size: AppSpacing.s4,
              color: AppColors.leaf,
            ),
            const SizedBox(width: AppSpacing.s1 + 2),
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.textInverse),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The captured photo inside the scan reticle; a line sweeps it while the
/// analysis runs.
class _PhotoFrame extends StatefulWidget {
  const _PhotoFrame({required this.image, required this.isAnalyzing});

  final XFile image;
  final bool isAnalyzing;

  @override
  State<_PhotoFrame> createState() => _PhotoFrameState();
}

class _PhotoFrameState extends State<_PhotoFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: AppMotion.scanSequence * 2,
    );
  }

  @override
  void didUpdateWidget(_PhotoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (widget.isAnalyzing && !reduceMotion) {
      _sweep.repeat(reverse: true);
    } else {
      _sweep
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget placeholder(BuildContext context, Object error, StackTrace? stack) =>
        const ColoredBox(color: AppColors.surfaceDark);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 240),
      child: ReticleFrame(
        arm: AppSpacing.s8,
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            fit: StackFit.expand,
            children: [
              kIsWeb
                  ? Image.network(
                      widget.image.path,
                      fit: BoxFit.cover,
                      errorBuilder: placeholder,
                    )
                  : Image.file(
                      File(widget.image.path),
                      fit: BoxFit.cover,
                      errorBuilder: placeholder,
                    ),
              if (widget.isAnalyzing) ...[
                ColoredBox(color: AppColors.forestInk.withValues(alpha: 0.35)),
                AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, _) => Align(
                    alignment: Alignment(
                      0,
                      -1 + 2 * AppMotion.standardCurve.transform(_sweep.value),
                    ),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.leaf.withValues(alpha: 0),
                            AppColors.leaf,
                            AppColors.leaf.withValues(alpha: 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.leaf.withValues(alpha: 0.5),
                            blurRadius: AppSpacing.s3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SupabaseStorageUploader {
  _SupabaseStorageUploader(this.service);

  final SmartCropsService service;

  Future<String> upload(XFile imageFile) async {
    // Upload the captured image itself on every platform: on web XFile
    // resolves the picker's blob URL to real bytes.
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw StateError('No authenticated session');
    }

    final extension = scanImageExtension(imageFile);
    final objectName =
        '${session.user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    final bytes = await imageFile.readAsBytes();
    await Supabase.instance.client.storage
        .from('scan-images')
        .uploadBinary(objectName, bytes);

    return Supabase.instance.client.storage
        .from('scan-images')
        .getPublicUrl(objectName);
  }
}
