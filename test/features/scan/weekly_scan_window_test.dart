import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/models/app_models.dart';

ScanHistoryItem _scan(DateTime at) => ScanHistoryItem(
      id: at.millisecondsSinceEpoch.toString(),
      userId: 'u',
      imageUrl: 'https://example.com/a.jpg',
      diseaseDetected: 'Healthy',
      confidenceScore: 95,
      commonCrop: 'Tomato',
      recommendedActions: const ['Monitor'],
      scannedAt: at,
    );

void main() {
  group('weekly_scan_window', () {
    test('the week starts on Monday at midnight and ends the next Monday', () {
      final window = weekWindow(DateTime(2026, 5, 13, 10, 30)); // a Wednesday
      expect(window.start, DateTime(2026, 5, 11));
      expect(window.end, DateTime(2026, 5, 18));

      final monday = weekWindow(DateTime(2026, 5, 11, 0, 5));
      expect(monday.start, DateTime(2026, 5, 11));

      final sunday = weekWindow(DateTime(2026, 5, 17, 23, 59));
      expect(sunday.start, DateTime(2026, 5, 11));
    });

    test('counts only scans inside the current week', () {
      final now = DateTime(2026, 5, 13, 10, 0); // Wednesday
      final scans = [
        _scan(DateTime(2026, 5, 4)), // previous week
        _scan(DateTime(2026, 5, 11, 0, 0)), // Monday boundary counts
        _scan(DateTime(2026, 5, 13, 8, 15)), // this week
        _scan(DateTime(2026, 5, 17, 23, 59)), // Sunday boundary counts
        _scan(DateTime(2026, 5, 18, 0, 0)), // next Monday does not count
      ];

      expect(scansThisWeek(scans, now), 3);
    });

    test('zero scans in an empty history', () {
      expect(scansThisWeek(const [], DateTime(2026, 5, 13)), 0);
    });
  });
}
