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
    return '/cooperative';
  }

  final recordId = link.recordId;
  if (recordId == null || recordId.isEmpty) {
    return '/advisories';
  }
  final encodedId = Uri.encodeComponent(recordId);

  return switch (link.target) {
    AdvisoryTarget.scan => '/scan/result/$encodedId',
    AdvisoryTarget.task => '/calendar/events/$encodedId',
    AdvisoryTarget.crop => '/crops/$encodedId',
    AdvisoryTarget.advisory => '/advisories/$encodedId',
    AdvisoryTarget.cooperative => '/cooperative',
  };
}
