import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/health_log/domain/health_log_statistics.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/models/app_models.dart';

ScanHistoryItem scan({
  required String disease,
  String source = 'ai',
}) {
  return ScanHistoryItem(
    id: '$source-$disease',
    userId: 'farmer-1',
    imageUrl: '',
    diseaseDetected: disease,
    confidenceScore: 80,
    commonCrop: 'Rice',
    recommendedActions: const [],
    scannedAt: DateTime(2026, 11, 21),
    source: source,
  );
}

void main() {
  test('demo diagnoses are excluded from season statistics', () {
    final stats = healthLogStatistics([
      scan(disease: 'Healthy'),
      scan(disease: 'Blight', source: 'demo_offline'),
      scan(disease: 'Blight', source: 'demo_offline'),
    ]);

    expect(stats.scans, 1);
    expect(stats.healthy, 1);
    expect(stats.atRisk, 0);
  });

  test('a history containing only demo diagnoses reports an empty season', () {
    final stats = healthLogStatistics([
      scan(disease: 'Blight', source: 'demo_offline'),
      scan(disease: 'Healthy', source: 'demo_offline'),
    ]);

    expect(stats.scans, 0);
    expect(stats.healthy, 0);
    expect(stats.atRisk, 0);
  });

  test('real diagnoses are counted by severity', () {
    final stats = healthLogStatistics([
      scan(disease: 'Healthy'),
      scan(disease: 'Healthy'),
      scan(disease: 'Blight'),
      scan(disease: 'Leaf spot'),
    ]);

    expect(stats.scans, 4);
    expect(stats.healthy, 2);
    expect(stats.atRisk, 1);
    expect(diagnosisSeverity('Leaf spot'), DiagnosisSeverity.watch);
  });
}
