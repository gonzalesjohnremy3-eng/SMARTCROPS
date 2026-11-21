import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/domain/scan_quota.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/analytics/analytics_view.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';

String scanImageExtension(XFile file) {
  final name = file.name.contains('.') ? file.name : file.path.split('/').last;
  final dot = name.lastIndexOf('.');
  return dot < 0 ? 'jpg' : name.substring(dot + 1).toLowerCase();
}

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

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _analyze() async {
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
      // Until image upload to Storage is wired, the Edge Function receives a
      // sample image URL. The captured image is uploaded by the scan queue
      // and by the online path below.
      final isOnline = await _hasConnectivity();

      if (!isOnline) {
        await queueProvider.enqueueScan(
          localImagePath: widget.imageFile.path,
          cropName: widget.cropName,
        );
        if (!mounted) return;
        context.trackEvent('scan_queued_offline');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).scanQueuedOffline),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      // Online: upload the captured image and analyze it.
      final uploader = _SupabaseStorageUploader(service);
      final imageUrl = await uploader.upload(widget.imageFile);

      final result = await service.performAiScan(imageUrl, widget.cropName);

      if (!mounted) return;

      if (result == null) {
        context.trackEvent('scan_failed');
        setState(() {
          _errorMessage = 'Analysis failed. Please try again.';
          _isAnalyzing = false;
        });
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

      context.trackEvent(
        'scan_analyzed',
        params: {'source': result.source},
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AnalyticsView(
            event: 'scan_result_viewed',
            child: ScanResultScreen(input: input),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      // Network or upload failure: queue the scan for later analysis.
      try {
        await queueProvider.enqueueScan(
          localImagePath: widget.imageFile.path,
          cropName: widget.cropName,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).scanQueuedOffline),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      } catch (_) {
        setState(() => _errorMessage = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<bool> _hasConnectivity() async {
    try {
      // Simple reachability check: connectivity_plus tells us if an interface is up.
      final result = await Connectivity().checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanReviewTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: kIsWeb
                      ? Image.network(widget.imageFile.path, fit: BoxFit.cover)
                      : Image.file(File(widget.imageFile.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.grass, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(widget.cropName, style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.replay),
                      label: Text(l10n.scanReviewRetake),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isAnalyzing ? null : _analyze,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isAnalyzing ? l10n.scanAnalyzing : l10n.scanReviewAnalyze,
                      ),
                    ),
                  ),
                ],
              ),
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
    final objectName = '${session.user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    final bytes = await imageFile.readAsBytes();
    await Supabase.instance.client.storage
        .from('scan-images')
        .uploadBinary(objectName, bytes);

    return Supabase.instance.client.storage
        .from('scan-images')
        .getPublicUrl(objectName);
  }
}
