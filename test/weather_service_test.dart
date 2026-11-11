import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/weather_service.dart';

void main() {
  group('WeatherCondition Model Tests', () {
    test('WeatherCondition.fromJson parses correctly', () {
      final json = {
        'locationName': 'Manila',
        'temperature': 31.2,
        'condition': 'Clear',
        'humidity': 65,
        'iconCode': '01d',
      };

      final weather = WeatherCondition.fromJson(json);

      expect(weather.locationName, 'Manila');
      expect(weather.temperature, 31.2);
      expect(weather.condition, 'Clear');
      expect(weather.humidity, 65);
      expect(weather.iconCode, '01d');
    });

    test('WeatherCondition.fromJson uses defaults on missing fields', () {
      final weather = WeatherCondition.fromJson({});

      expect(weather.locationName, 'Farm Location');
      expect(weather.temperature, 28.0);
      expect(weather.condition, 'Sunny');
      expect(weather.humidity, 70);
      expect(weather.iconCode, '01d');
    });
  });

  group('WeatherService Tests', () {
    test('WeatherService initial state is null and not loading', () {
      final service = WeatherService();
      expect(service.currentWeather, isNull);
      expect(service.isLoading, isFalse);
      expect(service.errorMessage, isNull);
    });
  });
}
