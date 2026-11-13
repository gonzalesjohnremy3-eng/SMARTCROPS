import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'farm_snapshot.dart';

class ServiceDataCacheStore {
  static const _keySnapshot = 'farm_data_snapshot';

  Future<FarmSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySnapshot);
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
    await prefs.setString(_keySnapshot, jsonEncode(snapshot.toJson()));
  }
}
