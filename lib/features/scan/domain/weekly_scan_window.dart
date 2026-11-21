import 'package:smart_crops/models/app_models.dart';

class WeekWindow {
  const WeekWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

WeekWindow weekWindow(DateTime now) {
  final startOfDay = DateTime(now.year, now.month, now.day);
  final start = startOfDay.subtract(Duration(days: now.weekday - 1));
  final end = start.add(const Duration(days: 7));
  return WeekWindow(start: start, end: end);
}

/// Scans counting toward the weekly free quota. Offline demo samples
/// (`source == 'demo_offline'`) do NOT consume the farmer's quota.
int scansThisWeek(List<ScanHistoryItem> scans, DateTime now) {
  final window = weekWindow(now);
  return scans.where((scan) {
    if (scan.source == 'demo_offline') return false;
    final scanned = scan.scannedAt;
    return !scanned.isBefore(window.start) && scanned.isBefore(window.end);
  }).length;
}
