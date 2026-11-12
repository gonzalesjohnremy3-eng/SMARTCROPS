enum PlanTier { free, pro }

enum QuotaReason { available, weeklyLimitReached, unlimited }

class ScanQuota {
  const ScanQuota({
    required this.allowed,
    required this.used,
    required this.limit,
    required this.remaining,
    required this.reserved,
    required this.resetsAt,
    required this.reason,
  });

  final bool allowed;
  final int used;
  final int? limit;
  final int? remaining;
  final int reserved;
  final DateTime resetsAt;
  final QuotaReason reason;
}

const _freeWeeklyScanLimit = 5;

ScanQuota evaluateScanQuota({
  required PlanTier tier,
  required int scansUsedThisWeek,
  int queuedScans = 0,
  required DateTime now,
}) {
  final startOfDay = DateTime(now.year, now.month, now.day);
  final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
  final resetsAt = startOfWeek.add(const Duration(days: 7));

  if (tier == PlanTier.pro) {
    return ScanQuota(
      allowed: true,
      used: scansUsedThisWeek,
      limit: null,
      remaining: null,
      reserved: queuedScans,
      resetsAt: resetsAt,
      reason: QuotaReason.unlimited,
    );
  }

  final committed = (scansUsedThisWeek < 0 ? 0 : scansUsedThisWeek) +
      (queuedScans < 0 ? 0 : queuedScans);
  final remaining = _freeWeeklyScanLimit - committed;

  return ScanQuota(
    allowed: remaining > 0,
    used: scansUsedThisWeek,
    limit: _freeWeeklyScanLimit,
    remaining: remaining > 0 ? remaining : 0,
    reserved: queuedScans,
    resetsAt: resetsAt,
    reason: remaining > 0
        ? QuotaReason.available
        : QuotaReason.weeklyLimitReached,
  );
}
