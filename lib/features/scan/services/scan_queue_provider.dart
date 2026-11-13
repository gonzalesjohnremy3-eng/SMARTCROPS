import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/scan_queue.dart';
import '../../../services/smart_crops_service.dart';

class ScanQueueProvider extends ChangeNotifier {
  ScanQueueProvider({
    required this.store,
    required this.service,
    this.clock = DateTime.now,
  }) {
    _queue = ScanQueue(
      store: store,
      uploader: _SupabaseStorageUploader(service),
      analyzer: _SmartCropsAnalyzer(service),
      clock: clock,
    );
  }

  final ScanQueueStore store;
  final SmartCropsService service;
  final DateTime Function() clock;

  late final ScanQueue _queue;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isProcessing = false;
  int _queuedCount = 0;

  int get queuedCount => _queuedCount;

  Future<void> initialize() async {
    await _loadQueuedCount();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(processPending());
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Queue a captured scan for analysis. Returns true when the scan is queued.
  Future<bool> enqueueScan({
    required String localImagePath,
    required String cropName,
  }) async {
    final item = await _queue.enqueue(
      localImagePath: localImagePath,
      cropName: cropName,
    );
    final imageUrl = await _imageUrlFor(item);
    if (imageUrl != null) {
      await _queue.processPending();
    } else {
      // Offline or upload failed: processPending handles retries.
      await _queue.processPending();
    }
    await _loadQueuedCount();
    return true;
  }

  /// Upload the queued images and analyze them when connectivity is available.
  Future<void> processPending() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      await _queue.processPending();
      await _loadQueuedCount();
    } finally {
      _isProcessing = false;
    }
  }

  Future<String?> _imageUrlFor(QueuedScan item) async {
    try {
      return await _uploadToStorage(item.localImagePath);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadQueuedCount() async {
    final items = await _queue.store.load();
    _queuedCount = items.where((item) => item.status != QueuedScanStatus.completed).length;
    notifyListeners();
  }

  Future<String> _uploadToStorage(String localImagePath) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw StateError('No authenticated session');
    }

    final file = File(localImagePath);
    final extension = localImagePath.split('.').last.toLowerCase();
    final objectName = '${session.user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    final bytes = await file.readAsBytes();
    await Supabase.instance.client.storage
        .from('scan-images')
        .uploadBinary(objectName, bytes);

    return Supabase.instance.client.storage
        .from('scan-images')
        .getPublicUrl(objectName);
  }
}

class _SupabaseStorageUploader implements ScanUploader {
  _SupabaseStorageUploader(this.service);

  final SmartCropsService service;

  @override
  Future<String> upload(String localImagePath) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw StateError('No authenticated session');
    }

    final file = File(localImagePath);
    final extension = localImagePath.split('.').last.toLowerCase();
    final objectName = '${session.user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    final bytes = await file.readAsBytes();
    await Supabase.instance.client.storage
        .from('scan-images')
        .uploadBinary(objectName, bytes);

    return Supabase.instance.client.storage
        .from('scan-images')
        .getPublicUrl(objectName);
  }
}

class _SmartCropsAnalyzer implements ScanAnalyzer {
  _SmartCropsAnalyzer(this.service);

  final SmartCropsService service;

  @override
  Future<String> analyze({
    required String imageUrl,
    required String cropName,
  }) async {
    final result = await service.performAiScan(imageUrl, cropName);
    if (result == null) {
      throw StateError('Analysis failed');
    }
    return result.id;
  }
}
