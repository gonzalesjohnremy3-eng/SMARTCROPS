enum AdvisorySource { personal, weather, cooperative }

enum AdvisoryTarget { scan, task, crop, advisory, cooperative }

class AdvisoryLink {
  const AdvisoryLink({
    required this.source,
    required this.target,
    this.recordId,
  });

  final AdvisorySource source;
  final AdvisoryTarget target;
  final String? recordId;
}

String resolveAdvisoryDestination(AdvisoryLink link) {
  if (link.target == AdvisoryTarget.cooperative) {
    return '/profile';
  }

  final recordId = link.recordId;
  if (recordId == null || recordId.isEmpty) {
    return '/advisories';
  }
  final encodedId = Uri.encodeComponent(recordId);

  // Only destinations registered in app_router.dart. Detail-by-id routes for
  // scans and advisories are not built, so carry the id to the list surface
  // that owns the record instead of dropping the farmer at a blank screen.
  return switch (link.target) {
    AdvisoryTarget.scan => '/health-log?scan=$encodedId',
    AdvisoryTarget.task => '/calendar/events/$encodedId',
    AdvisoryTarget.crop => '/crops/$encodedId',
    AdvisoryTarget.advisory => '/advisories?highlight=$encodedId',
    AdvisoryTarget.cooperative => '/profile',
  };
}
