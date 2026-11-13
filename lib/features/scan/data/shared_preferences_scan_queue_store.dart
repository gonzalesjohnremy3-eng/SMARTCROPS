import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/scan_queue.dart';

const _storageKey = 'smart_crops_scan_queue';

class SharedPreferencesScanQueueStore implements ScanQueueStore {
  @override
  Future<List<QueuedScan>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    return raw
        .map((entry) => Map<String, Object?>.from(jsonDecode(entry) as Map))
        .map(QueuedScan.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> save(List<QueuedScan> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, raw);
  }
}
