import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/analytics/analytics.dart';

class _CaptureSink implements AnalyticsSink {
  final List<MapEntry<String, Map<String, Object?>>> events = [];

  @override
  Future<void> send(String name, Map<String, Object?> params) async {
    events.add(MapEntry(name, params));
  }
}

void main() {
  group('Analytics envelope', () {
    test('every event carries language, tier, and app_version', () async {
      final sink = _CaptureSink();
      final analytics = Analytics(
        sink: sink,
        language: () => 'tl',
        tier: () => 'pro',
      );

      await analytics.trackAsync('scan_analyzed');

      expect(sink.events, hasLength(1));
      final params = sink.events.single.value;
      expect(params['language'], 'tl');
      expect(params['tier'], 'pro');
      expect(params['app_version'], isNotEmpty);
    });

    test('PII-shaped parameters never leave the device', () async {
      final sink = _CaptureSink();
      final analytics = Analytics(
        sink: sink,
        language: () => 'en',
        tier: () => 'free',
      );

      await analytics.trackAsync('scan_analyzed', params: {
        'crop': 'Tomato',
        'confidence_bucket': 'high',
        'image_url': 'https://example.com/a.jpg',
        'phone_number': '+639170000000',
        'full_name': 'Juan Dela Cruz',
        'latitude': '7.1',
        'severity': 'at_risk',
      });

      final params = sink.events.single.value;
      expect(params['crop'], 'Tomato');
      expect(params['confidence_bucket'], 'high');
      expect(params['severity'], 'at_risk');
      expect(params.containsKey('image_url'), isFalse);
      expect(params.containsKey('phone_number'), isFalse);
      expect(params.containsKey('full_name'), isFalse);
      expect(params.containsKey('latitude'), isFalse);
    });

    test('an empty event map still produces a valid envelope', () async {
      final sink = _CaptureSink();
      final analytics = Analytics(
        sink: sink,
        language: () => 'ceb',
        tier: () => 'free',
      );

      await analytics.trackAsync('home_viewed');

      final params = sink.events.single.value;
      expect(params['language'], 'ceb');
      expect(params.containsKey('crop'), isFalse);
    });
  });
}
