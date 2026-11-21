import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_knowledge_base.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/domain/offline_demo_diagnosis.dart';
import 'package:smart_crops/features/scan/domain/weekly_scan_window.dart';
import 'package:smart_crops/models/app_models.dart';

void main() {
  group('offline demo diagnosis', () {
    test('is deterministic for the same crop and seed', () {
      final a = buildOfflineDemoDiagnosis(cropName: 'Rice', seed: 'https://x/rice1.jpg');
      final b = buildOfflineDemoDiagnosis(cropName: 'Rice', seed: 'https://x/rice1.jpg');

      expect(a.diseaseDetected, b.diseaseDetected);
      expect(a.confidenceScore, b.confidenceScore);
      expect(a.recommendedActions, b.recommendedActions);
    });

    test('stays within the plausible confidence band', () {
      for (final seed in ['a.jpg', 'b.jpg', 'c.jpg', 'd.jpg', 'e.jpg']) {
        final demo = buildOfflineDemoDiagnosis(cropName: 'Tomato', seed: seed);
        expect(demo.confidenceScore, greaterThanOrEqualTo(68.0));
        expect(demo.confidenceScore, lessThan(96.0));
        expect(demo.recommendedActions, isNotEmpty);
      }
    });

    test('crop-scoped candidates include crop diseases and healthy', () {
      final rice = demoCandidatesForCrop('Rice');
      expect(rice.any((c) => c.$1 == 'Rice Blast'), isTrue);
      expect(rice.any((c) => c.$1 == 'Rice Tungro'), isTrue);
      expect(rice.any((c) => c.$1.contains('Healthy')), isTrue);

      final tomato = demoCandidatesForCrop('Tomato');
      expect(tomato.any((c) => c.$1 == 'Tomato Early Blight'), isTrue);
      expect(tomato.any((c) => c.$1 == 'Tomato Late Blight'), isTrue);
    });

    test('unknown crops get the full curated catalog', () {
      final weird = demoCandidatesForCrop('Dragonfruit');
      expect(weird.length, allCuratedDetails.length + 1);
    });
  });

  group('curated knowledge base', () {
    test('every curated disease is complete', () {
      for (final details in allCuratedDetails) {
        expect(details.cause, isNotEmpty);
        expect(details.symptoms.length, greaterThanOrEqualTo(2));
        expect(details.immediateActions.length, greaterThanOrEqualTo(2));
        expect(details.prevention.length, greaterThanOrEqualTo(2));
        expect(details.expertNote, isNotEmpty);
      }
    });

    test('knowledgeFor falls back to honest generic guidance for unknown diseases', () {
      final details = knowledgeFor(
        diseaseDetected: 'Mysterious sparkle blight of unknown origin',
        cropName: 'Dragonfruit',
      );
      expect(details.cause, isNotEmpty);
      expect(details.immediateActions, isNotEmpty);
    });

    test('healthy diagnoses resolve to healthy guidance', () {
      final details = knowledgeFor(
        diseaseDetected: 'Healthy / no disease detected',
        cropName: 'Pechay',
      );
      expect(details.isHealthy, isTrue);
    });

    test('crop-scoped matches win over generic keyword matches', () {
      final rice = knowledgeFor(
        diseaseDetected: 'Bacterial Leaf Blight',
        cropName: 'Palay',
      );
      expect(rice.cause, contains('Xanthomonas'));
    });
  });

  group('demo rows and quota', () {
    test('demo_offline scans do not consume the weekly quota', () {
      final now = DateTime(2026, 5, 13, 10, 0);
      ScanHistoryItem scan(DateTime at, String source) => ScanHistoryItem(
            id: at.millisecondsSinceEpoch.toString(),
            userId: 'u',
            imageUrl: 'https://example.com/a.jpg',
            diseaseDetected: 'X',
            confidenceScore: 80,
            commonCrop: 'Tomato',
            recommendedActions: const ['Monitor'],
            scannedAt: at,
            source: source,
          );

      final scans = [
        scan(DateTime(2026, 5, 12), 'ai'),
        scan(DateTime(2026, 5, 12), 'demo_offline'),
        scan(DateTime(2026, 5, 13), 'ai'),
        scan(DateTime(2026, 5, 13), 'demo_offline'),
      ];

      expect(scansThisWeek(scans, now), 2);
    });
  });

  group('source round-trip', () {
    test('source survives fromJson/toJson and defaults to ai', () {
      const demoJson = {
        'id': '1',
        'user_id': 'u',
        'image_url': 'https://x',
        'disease_detected': 'Rice Blast',
        'confidence_score': 81,
        'common_crop': 'Rice',
        'recommended_actions': ['a'],
        'scanned_at': '2026-05-13T02:00:00.000Z',
        'source': 'demo_offline',
      };
      final item = ScanHistoryItem.fromJson(Map<String, dynamic>.from(demoJson));
      expect(item.source, 'demo_offline');
      expect(item.toJson()['source'], 'demo_offline');

      final legacy = Map<String, dynamic>.from(demoJson)..remove('source');
      expect(ScanHistoryItem.fromJson(legacy).source, 'ai');
    });
  });

  group('presenter passthrough', () {
    test('isDemo flows from input to view', () {
      const input = DiagnosisInput(
        diseaseDetected: 'Rice Blast',
        confidenceScore: 74,
        commonCrop: 'Rice',
        recommendedActions: ['Remove affected tillers'],
        isDemo: true,
      );

      final view = presentDiagnosis(input);
      expect(view.isDemo, isTrue);
    });
  });
}
