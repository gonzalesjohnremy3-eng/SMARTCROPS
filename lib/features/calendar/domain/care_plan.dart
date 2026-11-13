import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/calendar/domain/weather_adjustment.dart';
import 'package:smart_crops/models/app_models.dart';

enum CarePlanSegment { today, thisWeek, preventive }

enum CarePlanReason { weather, overdue, scanAtRisk, routine }

class CarePlanItem {
  const CarePlanItem({
    required this.event,
    required this.effectiveDate,
    required this.isWeatherAdjusted,
    this.originalDate,
    required this.reason,
    this.relatedScanId,
  });

  final CropCalendarEvent event;
  final DateTime effectiveDate;
  final bool isWeatherAdjusted;
  final DateTime? originalDate;
  final CarePlanReason reason;
  final String? relatedScanId;
}

class CarePlanSuggestion {
  const CarePlanSuggestion({
    required this.cropName,
    required this.scan,
  });

  final String cropName;
  final ScanHistoryItem scan;
}

class CarePlan {
  const CarePlan({
    required this.today,
    required this.thisWeek,
    required this.preventive,
    required this.suggestions,
  });

  final List<CarePlanItem> today;
  final List<CarePlanItem> thisWeek;
  final List<CarePlanItem> preventive;
  final List<CarePlanSuggestion> suggestions;

  bool get isEmpty =>
      today.isEmpty && thisWeek.isEmpty && preventive.isEmpty && suggestions.isEmpty;
}

CarePlan buildCarePlan({
  required List<CropCalendarEvent> events,
  required List<ScanHistoryItem> scans,
  required DateTime now,
  WeatherForecast forecast = const WeatherForecast(precipitationMmNext24h: 0),
}) {
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekEnd = todayStart.add(const Duration(days: 8)); // today + 7 days

  final List<CarePlanItem> todayItems = [];
  final List<CarePlanItem> weekItems = [];
  final List<CarePlanItem> preventiveItems = [];

  for (final event in events) {
    if (event.isCompleted) continue;

    final adjusted = adjustForWeather(event: event, forecast: forecast);
    final effDate = adjusted.adjustedDate;
    final effDay = DateTime(effDate.year, effDate.month, effDate.day);

    final isOverdue = effDay.isBefore(todayStart);
    final isToday = effDay.isAtSameMomentAs(todayStart) || isOverdue;

    // Determine reason
    CarePlanReason reason = CarePlanReason.routine;
    String? scanId;

    if (adjusted.isAdjusted) {
      reason = CarePlanReason.weather;
    } else if (isOverdue) {
      reason = CarePlanReason.overdue;
    } else {
      // Check for at-risk scan for this crop within last 14 days
      final cropName = event.eventTitle.toLowerCase();
      ScanHistoryItem? recentScan;
      for (final scan in scans) {
        final daysAgo = now.difference(scan.scannedAt).inDays;
        if (daysAgo > 14) continue;
        if (diagnosisSeverity(scan.diseaseDetected) != DiagnosisSeverity.atRisk) {
          continue;
        }
        final matchesTitle = cropName.contains(scan.commonCrop.toLowerCase());
        final matchesCropId = event.cropId != null &&
            scan.commonCrop.toLowerCase() == event.cropId;
        if (matchesTitle || matchesCropId) {
          recentScan = scan;
          break;
        }
      }

      if (recentScan != null) {
        reason = CarePlanReason.scanAtRisk;
        scanId = recentScan.id;
      }
    }

    final item = CarePlanItem(
      event: event,
      effectiveDate: effDate,
      isWeatherAdjusted: adjusted.isAdjusted,
      originalDate: adjusted.originalDate,
      reason: reason,
      relatedScanId: scanId,
    );

    if (isToday) {
      todayItems.add(item);
    } else if (effDay.isBefore(weekEnd) || effDay.isAtSameMomentAs(weekEnd)) {
      weekItems.add(item);
    } else {
      preventiveItems.add(item);
    }
  }

  // Sort items: date asc, then priority High first
  int compareItems(CarePlanItem a, CarePlanItem b) {
    final cmp = a.effectiveDate.compareTo(b.effectiveDate);
    if (cmp != 0) return cmp;
    if (a.event.priority == 'High' && b.event.priority != 'High') return -1;
    if (b.event.priority == 'High' && a.event.priority != 'High') return 1;
    return 0;
  }

  todayItems.sort(compareItems);
  weekItems.sort(compareItems);
  preventiveItems.sort(compareItems);

  // Suggestions: at-risk scans in the last 7 days that do not have any incomplete event in the next 7 days
  final List<CarePlanSuggestion> suggestions = [];
  for (final scan in scans) {
    final daysAgo = now.difference(scan.scannedAt).inDays;
    if (daysAgo > 7) continue;
    if (diagnosisSeverity(scan.diseaseDetected) != DiagnosisSeverity.atRisk) continue;

    // Check if an event already exists for this crop
    final hasEvent = events.any((e) {
      if (e.isCompleted) return false;
      return e.eventTitle.toLowerCase().contains(scan.commonCrop.toLowerCase());
    });

    if (!hasEvent) {
      // Ensure unique by crop name
      if (!suggestions.any((s) => s.cropName.toLowerCase() == scan.commonCrop.toLowerCase())) {
        suggestions.add(CarePlanSuggestion(cropName: scan.commonCrop, scan: scan));
      }
    }
  }

  return CarePlan(
    today: todayItems,
    thisWeek: weekItems,
    preventive: preventiveItems,
    suggestions: suggestions,
  );
}

CarePlanReason resolveEventReason({
  required CropCalendarEvent event,
  required List<ScanHistoryItem> scans,
  required DateTime now,
  WeatherForecast forecast = const WeatherForecast(precipitationMmNext24h: 0),
}) {
  final adjusted = adjustForWeather(event: event, forecast: forecast);
  if (adjusted.isAdjusted) return CarePlanReason.weather;

  final todayStart = DateTime(now.year, now.month, now.day);
  final effDay = DateTime(adjusted.adjustedDate.year, adjusted.adjustedDate.month, adjusted.adjustedDate.day);
  if (effDay.isBefore(todayStart)) return CarePlanReason.overdue;

  final cropName = event.eventTitle.toLowerCase();
  final hasAtRisk = scans.any((scan) {
    final daysAgo = now.difference(scan.scannedAt).inDays;
    if (daysAgo > 14) return false;
    return diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.atRisk &&
        (cropName.contains(scan.commonCrop.toLowerCase()));
  });

  if (hasAtRisk) return CarePlanReason.scanAtRisk;
  return CarePlanReason.routine;
}
