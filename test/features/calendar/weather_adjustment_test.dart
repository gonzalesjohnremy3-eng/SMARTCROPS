import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/models/app_models.dart';

CropCalendarEvent _waterTask() {
  return CropCalendarEvent(
    id: 'cal-2',
    userId: 'user-1',
    cropId: 'crop-1',
    eventTitle: 'Deep Watering & Irrigation',
    eventCategory: 'Water Management',
    scheduledDate: DateTime(2026, 5, 2),
    isCompleted: false,
    priority: 'Normal',
  );
}

void main() {
  test('heavy rain postpones a water task by one day', () {
    final event = _waterTask();

    final adjustment = adjustForWeather(
      event: event,
      forecast: const WeatherForecast(precipitationMmNext24h: 12),
    );

    expect(adjustment.isAdjusted, isTrue);
    expect(adjustment.originalDate, DateTime(2026, 5, 2));
    expect(adjustment.adjustedDate, DateTime(2026, 5, 3));
    expect(adjustment.event.scheduledDate, DateTime(2026, 5, 3));
    expect(adjustment.reasonKey, 'calendar.weatherAdjusted.rain');
  });

  test('light rain does not move the task', () {
    final event = _waterTask();

    final adjustment = adjustForWeather(
      event: event,
      forecast: const WeatherForecast(precipitationMmNext24h: 9.9),
    );

    expect(adjustment.isAdjusted, isFalse);
    expect(adjustment.adjustedDate, DateTime(2026, 5, 2));
    expect(adjustment.reasonKey, isNull);
  });

  test('exactly ten millimeters triggers the rain rule', () {
    final event = _waterTask();

    final adjustment = adjustForWeather(
      event: event,
      forecast: const WeatherForecast(precipitationMmNext24h: 10),
    );

    expect(adjustment.isAdjusted, isTrue);
    expect(adjustment.adjustedDate, DateTime(2026, 5, 3));
  });

  test('heavy rain does not move a non-water task', () {
    final event = CropCalendarEvent(
      id: 'cal-3',
      userId: 'user-1',
      eventTitle: 'Apply compost',
      eventCategory: 'Nutrition',
      scheduledDate: DateTime(2026, 5, 2),
      isCompleted: false,
      priority: 'High',
    );

    final adjustment = adjustForWeather(
      event: event,
      forecast: const WeatherForecast(precipitationMmNext24h: 30),
    );

    expect(adjustment.isAdjusted, isFalse);
    expect(adjustment.adjustedDate, DateTime(2026, 5, 2));
  });
}
