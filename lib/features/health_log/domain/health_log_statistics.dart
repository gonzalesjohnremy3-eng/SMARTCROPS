import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/models/app_models.dart';

const demoScanSource = 'demo_offline';

class HealthLogStatistics {
  const HealthLogStatistics({
    required this.scans,
    required this.healthy,
    required this.atRisk,
  });

  final int scans;
  final int healthy;
  final int atRisk;
}

HealthLogStatistics healthLogStatistics(Iterable<ScanHistoryItem> scans) {
  final realScans = scans.where((scan) => scan.source != demoScanSource).toList();

  return HealthLogStatistics(
    scans: realScans.length,
    healthy: realScans
        .where(
          (scan) =>
              diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.healthy,
        )
        .length,
    atRisk: realScans
        .where(
          (scan) =>
              diagnosisSeverity(scan.diseaseDetected) == DiagnosisSeverity.atRisk,
        )
        .length,
  );
}
