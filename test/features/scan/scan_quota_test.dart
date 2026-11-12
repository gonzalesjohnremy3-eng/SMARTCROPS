import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/scan/domain/scan_quota.dart';

void main() {
  test('a free farmer starts the week with five scans available', () {
    final quota = evaluateScanQuota(
      tier: PlanTier.free,
      scansUsedThisWeek: 0,
      now: DateTime(2026, 11, 12, 10),
    );

    expect(quota.allowed, isTrue);
    expect(quota.used, 0);
    expect(quota.limit, 5);
    expect(quota.remaining, 5);
    expect(quota.resetsAt, DateTime(2026, 11, 16));
    expect(quota.reason, QuotaReason.available);
  });

  test('the fifth free scan is still allowed', () {
    final quota = evaluateScanQuota(
      tier: PlanTier.free,
      scansUsedThisWeek: 4,
      now: DateTime(2026, 11, 12, 10),
    );

    expect(quota.allowed, isTrue);
    expect(quota.remaining, 1);
  });

  test('the sixth free scan is blocked until the weekly reset', () {
    final quota = evaluateScanQuota(
      tier: PlanTier.free,
      scansUsedThisWeek: 5,
      now: DateTime(2026, 11, 12, 10),
    );

    expect(quota.allowed, isFalse);
    expect(quota.remaining, 0);
    expect(quota.reason, QuotaReason.weeklyLimitReached);
  });

  test('a queued scan reserves a free slot', () {
    final quota = evaluateScanQuota(
      tier: PlanTier.free,
      scansUsedThisWeek: 4,
      queuedScans: 1,
      now: DateTime(2026, 11, 12, 10),
    );

    expect(quota.allowed, isFalse);
    expect(quota.remaining, 0);
    expect(quota.reserved, 1);
  });

  test('Agri Pro has no weekly scan limit', () {
    final quota = evaluateScanQuota(
      tier: PlanTier.pro,
      scansUsedThisWeek: 99,
      now: DateTime(2026, 11, 12, 10),
    );

    expect(quota.allowed, isTrue);
    expect(quota.limit, isNull);
    expect(quota.remaining, isNull);
    expect(quota.reason, QuotaReason.unlimited);
  });

  test('the quota resets on the next Monday at midnight', () {
    final quota = evaluateScanQuota(
      tier: PlanTier.free,
      scansUsedThisWeek: 5,
      now: DateTime(2026, 11, 15, 23, 59),
    );

    expect(quota.resetsAt, DateTime(2026, 11, 16));
  });
}
