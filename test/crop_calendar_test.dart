import 'package:flutter_test/flutter_test.dart';
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
        'priority': 'High'
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

      // Weather condition: Heavy Rain
      final adjusted = adjustEventForWeather(initialEvent, 'Heavy Rain');
      expect(adjusted.eventTitle.contains('Postponed due to Rain'), true);
      expect(adjusted.priority, 'Weather-Adjusted');
    });
  });
}

// Helper function to be implemented in models or service
CropCalendarEvent adjustEventForWeather(CropCalendarEvent event, String weatherCondition) {
  if (event.eventCategory == 'Water Management' && (weatherCondition.toLowerCase().contains('rain') || weatherCondition.toLowerCase().contains('shower'))) {
    return CropCalendarEvent(
      id: event.id,
      userId: event.userId,
      cropId: event.cropId,
      eventTitle: '${event.eventTitle} (Postponed due to Rain)',
      eventCategory: event.eventCategory,
      scheduledDate: event.scheduledDate.add(const Duration(days: 1)),
      isCompleted: event.isCompleted,
      priority: 'Weather-Adjusted',
    );
  }
  return event;
}
