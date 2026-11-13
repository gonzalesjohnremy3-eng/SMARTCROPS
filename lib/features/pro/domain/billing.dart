import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/pro/domain/entitlement.dart';

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

/// TESTER MODE. No money changes hands and no payment method is used.
///
/// Behaves exactly like a real purchase for demo/testing: writes the same
/// `user_subscriptions` row a live purchase would, so the tester account is
/// Agri Pro everywhere the app looks (and survives reinstalls). Swap for a
/// real `in_app_purchase` implementation (or [UnconfiguredBillingRepository])
/// before the store launch.
class SimulatedProBilling implements BillingRepository {
  SimulatedProBilling(this._client);

  final SupabaseClient _client;

  @override
  Future<BillingOutcome> purchase(AgriProPlanId plan) async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return const BillingFailed('Sign in to start Agri Pro.');
    }

    final now = DateTime.now();
    final months = plan == AgriProPlanId.monthly ? 1 : 6;
    final expires = DateTime(now.year, now.month + months, now.day);

    try {
      await _client.from('user_subscriptions').upsert({
        'user_id': session.user.id,
        'tier': 'premium',
        'expires_at': expires.toIso8601String(),
      }, onConflict: 'user_id');
      return const BillingSucceeded();
    } catch (error) {
      return BillingFailed(error.toString());
    }
  }

  @override
  Future<BillingOutcome> restore() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return const BillingUnavailable();
    }

    final row = await _client
        .from('user_subscriptions')
        .select('tier, expires_at')
        .eq('user_id', session.user.id)
        .maybeSingle();

    if (row == null) {
      return const BillingUnavailable();
    }

    final view = evaluateEntitlement(
      tier: row['tier'] as String?,
      expiresAt: row['expires_at'] != null
          ? DateTime.tryParse(row['expires_at'].toString())
          : null,
      now: DateTime.now(),
    );
    return view.isPro ? const BillingSucceeded() : const BillingUnavailable();
  }
}
