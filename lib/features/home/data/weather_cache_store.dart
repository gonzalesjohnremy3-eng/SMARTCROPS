import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/app_models.dart';

class WeatherCacheStore {
  static const _keyCondition = 'weather_condition';
  static const _keyLastUpdated = 'weather_last_updated';

  Future<WeatherCondition?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCondition);
    if (raw == null) return null;

    return WeatherCondition.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<DateTime?> lastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keyLastUpdated);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> save(WeatherCondition condition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCondition, jsonEncode(condition.toJson()));
    await prefs.setInt(_keyLastUpdated, DateTime.now().millisecondsSinceEpoch);
  }
}
