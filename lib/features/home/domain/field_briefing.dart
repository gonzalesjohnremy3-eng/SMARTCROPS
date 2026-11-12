enum BriefingActionKind {
  criticalWeather,
  overdueTask,
  atRiskDiagnosis,
  routineCare,
  emptyFarm,
  monitor,
}

class BriefingFacts {
  const BriefingFacts({
    required this.hasCriticalWeather,
    required this.overdueTaskCount,
    required this.hasRecentAtRiskDiagnosis,
    required this.routineCareCount,
    required this.hasCrops,
  });

  final bool hasCriticalWeather;
  final int overdueTaskCount;
  final bool hasRecentAtRiskDiagnosis;
  final int routineCareCount;
  final bool hasCrops;
}

class BriefingAction {
  const BriefingAction({required this.kind, required this.copyKey});

  final BriefingActionKind kind;
  final String copyKey;
}

BriefingAction selectPriorityAction(BriefingFacts facts) {
  if (facts.hasCriticalWeather) {
    return const BriefingAction(
      kind: BriefingActionKind.criticalWeather,
      copyKey: 'home.briefing.criticalWeather',
    );
  }
  if (facts.overdueTaskCount > 0) {
    return const BriefingAction(
      kind: BriefingActionKind.overdueTask,
      copyKey: 'home.briefing.overdueTask',
    );
  }
  if (facts.hasRecentAtRiskDiagnosis) {
    return const BriefingAction(
      kind: BriefingActionKind.atRiskDiagnosis,
      copyKey: 'home.briefing.atRiskDiagnosis',
    );
  }
  if (facts.routineCareCount > 0) {
    return const BriefingAction(
      kind: BriefingActionKind.routineCare,
      copyKey: 'home.briefing.routineCare',
    );
  }
  if (!facts.hasCrops) {
    return const BriefingAction(
      kind: BriefingActionKind.emptyFarm,
      copyKey: 'home.briefing.emptyFarm',
    );
  }
  return const BriefingAction(
    kind: BriefingActionKind.monitor,
    copyKey: 'home.briefing.monitor',
  );
}
