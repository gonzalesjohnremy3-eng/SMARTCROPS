enum DiagnosisSeverity { healthy, watch, atRisk }

enum ConfidenceBand { low, medium, high }

class DiagnosisInput {
  const DiagnosisInput({
    required this.diseaseDetected,
    required this.confidenceScore,
    required this.commonCrop,
    required this.recommendedActions,
  });

  final String diseaseDetected;
  final double confidenceScore;
  final String commonCrop;
  final List<String> recommendedActions;
}

class DiagnosisView {
  const DiagnosisView({
    required this.diagnosis,
    required this.crop,
    required this.severity,
    required this.confidenceBand,
    required this.confidencePercent,
    required this.confidenceExplanationKey,
    required this.showRetakePrimary,
    required this.allowPartnerOffers,
    required this.treatmentSteps,
  });

  final String diagnosis;
  final String crop;
  final DiagnosisSeverity severity;
  final ConfidenceBand confidenceBand;
  final double confidencePercent;
  final String confidenceExplanationKey;
  final bool showRetakePrimary;
  final bool allowPartnerOffers;
  final List<String> treatmentSteps;
}

DiagnosisView presentDiagnosis(DiagnosisInput input) {
  final confidence = _normalizeConfidence(input.confidenceScore);
  final band = _confidenceBand(confidence);
  final severity = diagnosisSeverity(input.diseaseDetected);

  return DiagnosisView(
    diagnosis: input.diseaseDetected,
    crop: input.commonCrop,
    severity: severity,
    confidenceBand: band,
    confidencePercent: confidence,
    confidenceExplanationKey: 'scan.confidence.${band.name}',
    showRetakePrimary: band == ConfidenceBand.low,
    allowPartnerOffers:
        band != ConfidenceBand.low && severity != DiagnosisSeverity.healthy,
    treatmentSteps: List.unmodifiable(input.recommendedActions),
  );
}

double _normalizeConfidence(double raw) {
  final percent = raw <= 1 ? raw * 100 : raw;
  return percent.clamp(0, 100).toDouble();
}

ConfidenceBand _confidenceBand(double percent) {
  if (percent < 70) return ConfidenceBand.low;
  if (percent < 85) return ConfidenceBand.medium;
  return ConfidenceBand.high;
}

DiagnosisSeverity diagnosisSeverity(String diagnosis) {
  final text = diagnosis.toLowerCase();
  if (text.contains('healthy') ||
      text.contains('no disease') ||
      text.contains('no problem')) {
    return DiagnosisSeverity.healthy;
  }

  const highRiskTerms = [
    'blight',
    'rot',
    'wilt',
    'virus',
    'bacterial',
    'infestation',
    'severe',
  ];
  if (highRiskTerms.any(text.contains)) {
    return DiagnosisSeverity.atRisk;
  }

  return DiagnosisSeverity.watch;
}
