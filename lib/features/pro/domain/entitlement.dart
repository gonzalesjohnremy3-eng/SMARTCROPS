enum EntitlementTier { free, pro }

class EntitlementView {
  const EntitlementView({
    required this.tier,
    required this.isPro,
    required this.planId,
    required this.expiresAt,
  });

  final EntitlementTier tier;
  final bool isPro;
  final String? planId;
  final DateTime? expiresAt;

  static const free = EntitlementView(
    tier: EntitlementTier.free,
    isPro: false,
    planId: null,
    expiresAt: null,
  );
}

String? _normalizePlanId(String? tier) {
  final value = tier?.toLowerCase().trim();
  if (value == null || value.isEmpty) return null;
  if (value == 'premium' || value == 'pro') return value;
  return null;
}

EntitlementView evaluateEntitlement({
  required String? tier,
  required DateTime? expiresAt,
  required DateTime now,
}) {
  final normalized = _normalizePlanId(tier);
  if (normalized == null) {
    return EntitlementView.free;
  }
  if (expiresAt != null && !expiresAt.isAfter(now)) {
    return EntitlementView.free;
  }
  return EntitlementView(
    tier: EntitlementTier.pro,
    isPro: true,
    planId: normalized,
    expiresAt: expiresAt,
  );
}
