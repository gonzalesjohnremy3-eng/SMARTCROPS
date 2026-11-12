import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';

void main() {
  test('critical weather outranks every other briefing action', () {
    final action = selectPriorityAction(
      const BriefingFacts(
        hasCriticalWeather: true,
        overdueTaskCount: 2,
        hasRecentAtRiskDiagnosis: true,
        routineCareCount: 3,
        hasCrops: true,
      ),
    );

    expect(action.kind, BriefingActionKind.criticalWeather);
  });

  test('an overdue task outranks a recent at-risk diagnosis', () {
    final action = selectPriorityAction(
      const BriefingFacts(
        hasCriticalWeather: false,
        overdueTaskCount: 1,
        hasRecentAtRiskDiagnosis: true,
        routineCareCount: 2,
        hasCrops: true,
      ),
    );

    expect(action.kind, BriefingActionKind.overdueTask);
  });

  test('a recent at-risk diagnosis outranks routine care', () {
    final action = selectPriorityAction(
      const BriefingFacts(
        hasCriticalWeather: false,
        overdueTaskCount: 0,
        hasRecentAtRiskDiagnosis: true,
        routineCareCount: 2,
        hasCrops: true,
      ),
    );

    expect(action.kind, BriefingActionKind.atRiskDiagnosis);
  });

  test('routine care is shown when nothing is urgent', () {
    final action = selectPriorityAction(
      const BriefingFacts(
        hasCriticalWeather: false,
        overdueTaskCount: 0,
        hasRecentAtRiskDiagnosis: false,
        routineCareCount: 1,
        hasCrops: true,
      ),
    );

    expect(action.kind, BriefingActionKind.routineCare);
  });

  test('an empty farm invites the first scan', () {
    final action = selectPriorityAction(
      const BriefingFacts(
        hasCriticalWeather: false,
        overdueTaskCount: 0,
        hasRecentAtRiskDiagnosis: false,
        routineCareCount: 0,
        hasCrops: false,
      ),
    );

    expect(action.kind, BriefingActionKind.emptyFarm);
  });

  test('a healthy farm without tasks shows a monitoring prompt', () {
    final action = selectPriorityAction(
      const BriefingFacts(
        hasCriticalWeather: false,
        overdueTaskCount: 0,
        hasRecentAtRiskDiagnosis: false,
        routineCareCount: 0,
        hasCrops: true,
      ),
    );

    expect(action.kind, BriefingActionKind.monitor);
  });
}
