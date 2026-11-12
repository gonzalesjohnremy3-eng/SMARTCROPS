import '../../../models/app_models.dart';

const weatherAdjustmentRainThresholdMm = 10.0;

class WeatherForecast {
  const WeatherForecast({required this.precipitationMmNext24h});

  final double precipitationMmNext24h;
}

class WeatherAdjustment {
  const WeatherAdjustment({
    required this.event,
    required this.originalDate,
    required this.adjustedDate,
    required this.isAdjusted,
    this.reasonKey,
  });

  final CropCalendarEvent event;
  final DateTime originalDate;
  final DateTime adjustedDate;
  final bool isAdjusted;
  final String? reasonKey;
}

WeatherAdjustment adjustForWeather({
  required CropCalendarEvent event,
  required WeatherForecast forecast,
}) {
  final isWaterTask = event.eventCategory.toLowerCase().contains('water');
  final hasHeavyRain =
      forecast.precipitationMmNext24h >= weatherAdjustmentRainThresholdMm;

  if (!isWaterTask || !hasHeavyRain) {
    return WeatherAdjustment(
      event: event,
      originalDate: event.scheduledDate,
      adjustedDate: event.scheduledDate,
      isAdjusted: false,
    );
  }

  final adjustedDate = event.scheduledDate.add(const Duration(days: 1));
  return WeatherAdjustment(
    event: _copyWithDate(event, adjustedDate),
    originalDate: event.scheduledDate,
    adjustedDate: adjustedDate,
    isAdjusted: true,
    reasonKey: 'calendar.weatherAdjusted.rain',
  );
}

CropCalendarEvent _copyWithDate(CropCalendarEvent event, DateTime date) {
  return CropCalendarEvent(
    id: event.id,
    userId: event.userId,
    cropId: event.cropId,
    eventTitle: event.eventTitle,
    eventCategory: event.eventCategory,
    scheduledDate: date,
    isCompleted: event.isCompleted,
    priority: event.priority,
  );
}
