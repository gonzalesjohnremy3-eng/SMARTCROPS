enum AgriProPlanId { monthly, seasonal }

class AgriProPlan {
  const AgriProPlan({
    required this.id,
    required this.pricePHP,
    required this.months,
    required this.savePercent,
  });

  final AgriProPlanId id;
  final int pricePHP;
  final int months;
  final int savePercent;
}

const agriProMonthlyPlan = AgriProPlan(
  id: AgriProPlanId.monthly,
  pricePHP: 99,
  months: 1,
  savePercent: 0,
);

const agriProSeasonalPlan = AgriProPlan(
  id: AgriProPlanId.seasonal,
  pricePHP: 499,
  months: 6,
  savePercent: 16,
);

const agriProPlans = <AgriProPlan>[agriProMonthlyPlan, agriProSeasonalPlan];

sealed class BillingOutcome {
  const BillingOutcome();
}

class BillingSucceeded extends BillingOutcome {
  const BillingSucceeded();
}

/// The store is not configured / products are not live yet.
class BillingUnavailable extends BillingOutcome {
  const BillingUnavailable();
}

class BillingFailed extends BillingOutcome {
  const BillingFailed(this.message);

  final String message;
}

abstract class BillingRepository {
  Future<BillingOutcome> purchase(AgriProPlanId plan);
  Future<BillingOutcome> restore();
}

/// Honest default until Play Console / App Store Connect products are live:
/// reports that billing is not configured yet instead of faking a purchase.
class UnconfiguredBillingRepository implements BillingRepository {
  const UnconfiguredBillingRepository();

  @override
  Future<BillingOutcome> purchase(AgriProPlanId plan) async =>
      const BillingUnavailable();

  @override
  Future<BillingOutcome> restore() async => const BillingUnavailable();
}
