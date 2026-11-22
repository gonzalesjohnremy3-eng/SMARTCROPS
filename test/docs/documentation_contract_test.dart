import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('implementation status audit date reflects merged CropCare line', () {
    final status = File(
      'PROJECT_KNOWLEDGE/DOCUMENTS/IMPLEMENTATION_STATUS.md',
    ).readAsStringSync();

    expect(status, contains('**Audit date:** 2026-11-22'));
  });

  test('implementation status uses the current verification count', () {
    final status = File(
      'PROJECT_KNOWLEDGE/DOCUMENTS/IMPLEMENTATION_STATUS.md',
    ).readAsStringSync();

    expect(
      status,
      contains('Current verification: flutter test (233 passing)'),
    );
  });

  test(
    'blueprint marks direction implemented and current state as baseline',
    () {
      final blueprint = File(
        'PROJECT_KNOWLEDGE/DOCUMENTS/UI_UX_BLUEPRINT.md',
      ).readAsStringSync();

      expect(
        blueprint,
        contains('**Status:** Phase 1-2 implemented; Phase 3 in progress'),
      );
      expect(blueprint, contains('### Baseline audit (2026-11-12)'));
      expect(blueprint, isNot(contains('### Current state')));
    },
  );

  test('status records Phase 2 local closures and external blockers', () {
    final status = File(
      'PROJECT_KNOWLEDGE/DOCUMENTS/IMPLEMENTATION_STATUS.md',
    ).readAsStringSync();

    expect(status, contains('## 8. Phase 2 gap closure'));
    expect(status, contains('Health Log master-detail'));
    expect(status, contains('ANALYTICS_PRIVACY_REVIEW.md'));
    expect(status, contains('send-campaign payload/authz'));
    expect(status, contains('Externally blocked'));
  });
}
