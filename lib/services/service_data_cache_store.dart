import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'farm_snapshot.dart';

class ServiceDataCacheStore {
  static const _keySnapshot = 'farm_data_snapshot';

  String? _userId;

  String get _scopedKey => _userId == null ? _keySnapshot : '${_keySnapshot}_$_userId';

  /// Bind the store to a farmer. Switching farmers switches the cache key so a
  /// failed refresh can never fall back to another farmer's private snapshot.
  Future<void> useUser(String? userId) async {
    _userId = userId;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scopedKey);
  }

  Future<FarmSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey);
    if (raw == null) return null;

    try {
      return FarmSnapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(FarmSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopedKey, jsonEncode(snapshot.toJson()));
  }
}
