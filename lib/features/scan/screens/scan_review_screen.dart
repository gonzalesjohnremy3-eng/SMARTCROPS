import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';

class ScanReviewScreen extends StatefulWidget {
  const ScanReviewScreen({
    super.key,
    required this.localImagePath,
    required this.cropName,
  });

  final String localImagePath;
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
          localImagePath: widget.localImagePath,
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
      }

      // Online: upload the captured image and analyze it.
      final uploader = _SupabaseStorageUploader(service);
      final imageUrl = await uploader.upload(widget.localImagePath);

      final result = await service.performAiScan(imageUrl, widget.cropName);

      if (!mounted) return;

      if (result == null) {
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
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(input: input),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      // Network or upload failure: queue the scan for later analysis.
      try {
        await queueProvider.enqueueScan(
          localImagePath: widget.localImagePath,
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
                      ? Image.network(widget.localImagePath, fit: BoxFit.cover)
                      : Image.file(File(widget.localImagePath), fit: BoxFit.cover),
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

  Future<String> upload(String localImagePath) async {
    // Online path: upload to Supabase Storage so the Edge Function
    // receives a public URL instead of a local path.
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw StateError('No authenticated session');
    }

    final extension = localImagePath.split('.').last.toLowerCase();
    final objectName = '${session.user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    if (kIsWeb) {
      // Web receives bytes via a data URI; fall back to a sample URL in the prototype.
      return 'https://images.unsplash.com/photo-1592417817098-8f3d691a4bf5?auto=format&fit=crop&w=800&q=80';
    }

    final file = File(localImagePath);
    final bytes = await file.readAsBytes();
    await Supabase.instance.client.storage
        .from('scan-images')
        .uploadBinary(objectName, bytes);

    return Supabase.instance.client.storage
        .from('scan-images')
        .getPublicUrl(objectName);
  }
}
