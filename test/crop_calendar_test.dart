import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/models/app_models.dart';

void main() {
  group('Personalized Crop Calendar TDD - Seam: Model & Weather Adjustment', () {
    test('CropCalendarEvent.fromJson parses correctly', () {
      final json = {
        'id': 'cal-1',
        'user_id': 'user-1',
        'crop_id': 'crop-1',
        'event_title': 'Apply Organic Compost',
        'event_category': 'Nutrition',
        'scheduled_date': '2026-05-01T08:00:00Z',
        'is_completed': false,
        'priority': 'High',
      };

      final event = CropCalendarEvent.fromJson(json);

      expect(event.id, 'cal-1');
      expect(event.eventTitle, 'Apply Organic Compost');
      expect(event.eventCategory, 'Nutrition');
      expect(event.isCompleted, false);
      expect(event.priority, 'High');
    });

    test('Weather adjustment logic postpones watering on heavy rain', () {
      final initialEvent = CropCalendarEvent(
        id: 'cal-2',
        userId: 'user-1',
        cropId: 'crop-1',
        eventTitle: 'Deep Watering & Irrigation',
        eventCategory: 'Water Management',
        scheduledDate: DateTime(2026, 5, 2),
        isCompleted: false,
        priority: 'Normal',
      );

      final adjustment = adjustForWeather(
        event: initialEvent,
        forecast: const WeatherForecast(precipitationMmNext24h: 15),
      );

      expect(adjustment.isAdjusted, isTrue);
      expect(adjustment.adjustedDate, DateTime(2026, 5, 3));
      expect(adjustment.reasonKey, 'calendar.weatherAdjusted.rain');
    });
  });
}
