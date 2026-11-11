import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';

class WeatherService with ChangeNotifier {
  WeatherCondition? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherCondition? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeatherForLocation(String location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Using wttr.in JSON API for lightweight 0-cost weather data
      final encodedLocation = Uri.encodeComponent(location);
      final url = Uri.parse('https://wttr.in/$encodedLocation?format=j1');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentCondition = data['current_condition'][0];

        final tempC = double.tryParse(currentCondition['temp_C'].toString()) ?? 28.0;
        final humidity = int.tryParse(currentCondition['humidity'].toString()) ?? 75;
        final weatherDescList = currentCondition['weatherDesc'] as List;
        final conditionText = weatherDescList.isNotEmpty ? weatherDescList[0]['value'] : 'Sunny';

        _currentWeather = WeatherCondition(
          locationName: location,
          temperature: tempC,
          condition: conditionText,
          humidity: humidity,
          iconCode: _mapConditionToIcon(conditionText),
        );
      } else {
        throw Exception('Failed to load weather data (status code ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      _errorMessage = 'Could not fetch live weather. Using cached/default estimate.';
      // Fallback mock weather for robust prototyping & offline support
      _currentWeather = WeatherCondition(
        locationName: location.isNotEmpty ? location : 'Farm Location',
        temperature: 30.5,
        condition: 'Partly Cloudy',
        humidity: 68,
        iconCode: '02d',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapConditionToIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('shower')) return '09d';
    if (lower.contains('cloud')) return '03d';
    if (lower.contains('thunder')) return '11d';
    if (lower.contains('snow')) return '13d';
    return '01d'; // sunny/clear
  }
}
