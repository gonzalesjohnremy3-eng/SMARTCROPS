import 'package:flutter_test/flutter_test.dart';

class RegionalOutbreakMetric {
  final String diseaseName;
  final int affectedFarmersCount;
  final double averageConfidence;

  RegionalOutbreakMetric({
    required this.diseaseName,
    required this.affectedFarmersCount,
    required this.averageConfidence,
  });

  factory RegionalOutbreakMetric.fromJson(Map<String, dynamic> json) {
    return RegionalOutbreakMetric(
      diseaseName: json['disease_name'] ?? 'Unknown',
      affectedFarmersCount: json['affected_farmers_count'] ?? 0,
      averageConfidence: (json['average_confidence'] ?? 0.0).toDouble(),
    );
  }
}

class BroadcastAdvisory {
  final String title;
  final String message;
  final String severity;

  BroadcastAdvisory({
    required this.title,
    required this.message,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'severity': severity,
  };
}

class CooperativeDashboardManager {
  List<RegionalOutbreakMetric> calculateOutbreakSummary(List<Map<String, dynamic>> rawScans) {
    final Map<String, List<double>> diseaseMap = {};

    for (var scan in rawScans) {
      final disease = scan['disease_detected'] ?? 'Healthy';
      final confidence = (scan['confidence_score'] ?? 0.0).toDouble();
      if (disease != 'Healthy / Early Leaf Spot') {
        diseaseMap.putIfAbsent(disease, () => []).add(confidence);
      }
    }

    return diseaseMap.entries.map((entry) {
      final confidences = entry.value;
      final avgConf = confidences.reduce((a, b) => a + b) / confidences.length;
      return RegionalOutbreakMetric(
        diseaseName: entry.key,
        affectedFarmersCount: confidences.length,
        averageConfidence: avgConf,
      );
    }).toList();
  }

  bool validateBroadcastAdvisory(BroadcastAdvisory advisory) {
    return advisory.title.isNotEmpty && advisory.message.isNotEmpty && ['Critical', 'Warning', 'Info'].contains(advisory.severity);
  }
}

void main() {
  group('Cooperative Dashboard TDD - Seams: Outbreak Metrics & Broadcasts', () {
    test('calculates regional outbreak metrics accurately from scan logs', () {
      final rawScans = [
        {'disease_detected': 'Leaf Spot', 'confidence_score': 92.0},
        {'disease_detected': 'Leaf Spot', 'confidence_score': 96.0},
        {'disease_detected': 'Blight', 'confidence_score': 88.0},
      ];

      final manager = CooperativeDashboardManager();
      final metrics = manager.calculateOutbreakSummary(rawScans);

      expect(metrics.length, 2);
      final leafSpotMetric = metrics.firstWhere((m) => m.diseaseName == 'Leaf Spot');
      expect(leafSpotMetric.affectedFarmersCount, 2);
      expect(leafSpotMetric.averageConfidence, 94.0);
    });

    test('validates broadcast advisories correctly', () {
      final manager = CooperativeDashboardManager();
      final valid = BroadcastAdvisory(title: 'Pest Outbreak Alert', message: 'Apply neem oil immediately.', severity: 'Critical');
      final invalid = BroadcastAdvisory(title: '', message: '', severity: 'Unknown');

      expect(manager.validateBroadcastAdvisory(valid), true);
      expect(manager.validateBroadcastAdvisory(invalid), false);
    });
  });
}
