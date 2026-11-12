import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/router/advisory_link_resolver.dart';

void main() {
  test('a scan advisory opens the scan result', () {
    final destination = resolveAdvisoryDestination(
      const AdvisoryLink(
        source: AdvisorySource.personal,
        target: AdvisoryTarget.scan,
        recordId: 'scan-42',
      ),
    );

    expect(destination, '/scan/result/scan-42');
  });

  test('task, crop, advisory, and cooperative targets resolve to their routes', () {
    expect(
      resolveAdvisoryDestination(
        const AdvisoryLink(
          source: AdvisorySource.weather,
          target: AdvisoryTarget.task,
          recordId: 'task-10',
        ),
      ),
      '/calendar/events/task-10',
    );

    expect(
      resolveAdvisoryDestination(
        const AdvisoryLink(
          source: AdvisorySource.personal,
          target: AdvisoryTarget.crop,
          recordId: 'crop-pechay',
        ),
      ),
      '/crops/crop-pechay',
    );

    expect(
      resolveAdvisoryDestination(
        const AdvisoryLink(
          source: AdvisorySource.cooperative,
          target: AdvisoryTarget.advisory,
          recordId: 'adv-99',
        ),
      ),
      '/advisories/adv-99',
    );

    expect(
      resolveAdvisoryDestination(
        const AdvisoryLink(
          source: AdvisorySource.cooperative,
          target: AdvisoryTarget.cooperative,
        ),
      ),
      '/cooperative',
    );
  });

  test('a link missing a required record ID falls back to advisories inbox', () {
    expect(
      resolveAdvisoryDestination(
        const AdvisoryLink(
          source: AdvisorySource.weather,
          target: AdvisoryTarget.scan,
        ),
      ),
      '/advisories',
    );
  });
}
