import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/pro/domain/entitlement.dart';

void main() {
  group('evaluateEntitlement', () {
    final now = DateTime(2026, 5, 13, 10, 0);

    test('a missing subscription row means the free tier', () {
      final view = evaluateEntitlement(tier: null, expiresAt: null, now: now);
      expect(view.tier, EntitlementTier.free);
      expect(view.isPro, isFalse);
    });

    test('an unrecognized tier is treated as free', () {
      final view = evaluateEntitlement(tier: 'trial', expiresAt: null, now: now);
      expect(view.isPro, isFalse);
    });

    test('premium tier without expiry is Agri Pro', () {
      final view = evaluateEntitlement(tier: 'premium', expiresAt: null, now: now);
      expect(view.isPro, isTrue);
      expect(view.tier, EntitlementTier.pro);
      expect(view.planId, 'premium');
    });

    test('pro tier with a future expiry is Agri Pro', () {
      final view = evaluateEntitlement(
        tier: 'pro',
        expiresAt: DateTime(2026, 6, 13),
        now: now,
      );
      expect(view.isPro, isTrue);
    });

    test('premium tier with a past expiry is free again', () {
      final view = evaluateEntitlement(
        tier: 'premium',
        expiresAt: DateTime(2026, 5, 12, 23, 59),
        now: now,
      );
      expect(view.isPro, isFalse);
      expect(view.tier, EntitlementTier.free);
    });

    test('whitespace and case do not defeat tier matching', () {
      final view = evaluateEntitlement(tier: '  PREMIUM ', expiresAt: null, now: now);
      expect(view.isPro, isTrue);
    });
  });
}
