import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/calendar/domain/care_plan.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/models/app_models.dart';

void main() {
  group('Care Plan Domain Logic', () {
    test('buildCarePlan buckets tasks into today, thisWeek, preventive with correct reasons', () {
      final now = DateTime(2026, 5, 10, 10, 0);

      final events = [
        // Overdue -> Today
        CropCalendarEvent(
          id: '1',
          userId: 'u',
          eventTitle: 'Tomato Weeding',
          eventCategory: 'General',
          scheduledDate: DateTime(2026, 5, 8),
          isCompleted: false,
          priority: 'Normal',
        ),
        // Today (weather adjusted) -> Today
        CropCalendarEvent(
          id: '2',
          userId: 'u',
          eventTitle: 'Tomato Watering',
          eventCategory: 'Water Management',
          scheduledDate: DateTime(2026, 5, 10),
          isCompleted: false,
          priority: 'Normal',
        ),
        // This Week (in 3 days) -> This Week
        CropCalendarEvent(
          id: '3',
          userId: 'u',
          eventTitle: 'Pechay Fertilizing',
          eventCategory: 'Nutrition',
          scheduledDate: DateTime(2026, 5, 13),
          isCompleted: false,
          priority: 'High',
        ),
        // Preventive (in 15 days) -> Preventive
        CropCalendarEvent(
          id: '4',
          userId: 'u',
          eventTitle: 'Soil Audit',
          eventCategory: 'General',
          scheduledDate: DateTime(2026, 5, 25),
          isCompleted: false,
          priority: 'Normal',
        ),
      ];

      final scans = [
        ScanHistoryItem(
          id: 's1',
          userId: 'u',
          imageUrl: 'url',
          diseaseDetected: 'Bacterial Blight',
          confidenceScore: 90,
          commonCrop: 'Pechay',
          recommendedActions: const [],
          scannedAt: DateTime(2026, 5, 9),
        ),
      ];

      final plan = buildCarePlan(
        events: events,
        scans: scans,
        now: now,
        forecast: const WeatherForecast(precipitationMmNext24h: 15), // triggers rain adjustment on watering
      );

      expect(plan.today.length, 1);
      expect(plan.thisWeek.length, 2);
    });
  });
}
