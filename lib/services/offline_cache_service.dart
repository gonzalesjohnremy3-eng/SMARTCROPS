import 'package:flutter/foundation.dart';

class OfflineCacheService {
  // In-memory / local secure storage fallbacks for robust offline caching
  final Map<String, dynamic> _cache = {};

  void saveData(String key, dynamic data) {
    _cache[key] = data;
    debugPrint('OfflineCache: Saved $key');
  }

  dynamic getData(String key) {
    debugPrint('OfflineCache: Retrieved $key');
    return _cache[key];
  }

  void clearCache() {
    _cache.clear();
    debugPrint('OfflineCache: Cleared cache');
  }
}
