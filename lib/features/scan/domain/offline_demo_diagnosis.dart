import 'diagnosis_knowledge_base.dart';

class DemoDiagnosis {
  const DemoDiagnosis({
    required this.diseaseDetected,
    required this.confidenceScore,
    required this.recommendedActions,
  });

  final String diseaseDetected;
  final double confidenceScore;
  final List<String> recommendedActions;
}

/// Deterministic FNV-1a hash so the same (crop, image) pair always yields
/// the same sample diagnosis. Different photos surface different diseases.
int _fnv1a(String input) {
  const prime = 16777619;
  var hash = 2166136261;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * prime) & 0xFFFFFFFF;
  }
  return hash;
}

/// Sample candidates for a crop: every disease matching the crop plus a
/// healthy outcome, so repeated demo scans feel alive rather than canned.
List<(String, DiagnosisDetails)> demoCandidatesForCrop(String cropName) {
  final matching = demoDiagnosesForCrop(cropName);
  return <(String, DiagnosisDetails)>[
    ...matching,
    ('Healthy crop - no disease detected', knowledgeFor(
        diseaseDetected: 'healthy crop', cropName: cropName)),
  ];
}

/// Builds a labeled offline sample diagnosis for a captured photo.
///
/// Used ONLY when the AI Edge Function cannot deliver a real diagnosis
/// (offline-first resilience). The UI marks the result as a demo.
DemoDiagnosis buildOfflineDemoDiagnosis({
  required String cropName,
  required String seed,
}) {
  final candidates = demoCandidatesForCrop(cropName);
  final hash = _fnv1a('$cropName::$seed');
  final (label, details) = candidates[hash % candidates.length];

  // Confidence in a plausible-looking band; high confidence feels like a "real"
  // AI answer while remaining clearly marked as a demo elsewhere in the app.
  final confidence = 68.0 + (hash ~/ 7) % 28;

  return DemoDiagnosis(
    diseaseDetected: label,
    confidenceScore: confidence,
    recommendedActions: List<String>.unmodifiable(details.immediateActions),
  );
}
