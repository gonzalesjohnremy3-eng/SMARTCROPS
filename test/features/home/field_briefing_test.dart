import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';
import 'package:smart_crops/models/app_models.dart';

WeatherCondition weather({
  required String condition,
  required bool isSample,
}) {
  return WeatherCondition(
    locationName: 'San Isidro',
    temperature: 28,
    condition: condition,
    humidity: 70,
    iconCode: '11d',
    isSample: isSample,
  );
}

void main() {
  test('live thunderstorm produces a critical weather briefing', () {
    expect(
      isCriticalWeather(weather(condition: 'Thunderstorm', isSample: false)),
      isTrue,
    );
  });

  test('sample thunderstorm never produces a critical weather briefing', () {
    expect(
      isCriticalWeather(weather(condition: 'Thunderstorm', isSample: true)),
      isFalse,
    );
  });

  test('missing weather is not treated as critical', () {
    expect(isCriticalWeather(null), isFalse);
  });
}
