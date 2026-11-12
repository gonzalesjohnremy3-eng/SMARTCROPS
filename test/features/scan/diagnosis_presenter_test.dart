import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';

void main() {
  test('a high-confidence healthy crop is presented as healthy', () {
    final view = presentDiagnosis(
      const DiagnosisInput(
        diseaseDetected: 'Healthy / Early Leaf Spot',
        confidenceScore: 94.5,
        commonCrop: 'Pechay',
        recommendedActions: ['Keep monitoring'],
      ),
    );

    expect(view.severity, DiagnosisSeverity.healthy);
    expect(view.confidenceBand, ConfidenceBand.high);
    expect(view.confidencePercent, 94.5);
    expect(view.showRetakePrimary, isFalse);
    expect(view.allowPartnerOffers, isFalse);
  });

  test('a low-confidence diagnosis makes retake the primary action', () {
    final view = presentDiagnosis(
      const DiagnosisInput(
        diseaseDetected: 'Fungal leaf blight',
        confidenceScore: 0.52,
        commonCrop: 'Tomato',
        recommendedActions: ['Remove affected leaves'],
      ),
    );

    expect(view.severity, DiagnosisSeverity.atRisk);
    expect(view.confidenceBand, ConfidenceBand.low);
    expect(view.confidencePercent, 52);
    expect(view.showRetakePrimary, isTrue);
    expect(view.allowPartnerOffers, isFalse);
  });

  test('a medium-confidence watch diagnosis may show relevant offers', () {
    final view = presentDiagnosis(
      const DiagnosisInput(
        diseaseDetected: 'Leaf spot',
        confidenceScore: 76,
        commonCrop: 'Pechay',
        recommendedActions: ['Improve airflow'],
      ),
    );

    expect(view.severity, DiagnosisSeverity.watch);
    expect(view.confidenceBand, ConfidenceBand.medium);
    expect(view.showRetakePrimary, isFalse);
    expect(view.allowPartnerOffers, isTrue);
  });

  test('treatment steps preserve their order and cannot be mutated', () {
    final steps = ['Step one', 'Step two', 'Step three'];
    final view = presentDiagnosis(
      DiagnosisInput(
        diseaseDetected: 'Bacterial wilt',
        confidenceScore: 91,
        commonCrop: 'Tomato',
        recommendedActions: steps,
      ),
    );

    expect(view.treatmentSteps, steps);
    expect(view.allowPartnerOffers, isTrue);
    expect(() => view.treatmentSteps.add('Step four'), throwsUnsupportedError);
  });
}
