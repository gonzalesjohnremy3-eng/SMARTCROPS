import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/analytics/route_observer.dart';

class _CaptureSink implements AnalyticsSink {
  final List<String> events = [];

  @override
  Future<void> send(String name, Map<String, Object?> params) async {
    events.add(name);
  }
}

Future<void> _pumpInitial(
  WidgetTester tester,
  AnalyticsRouteObserver observer,
  String initialRoute,
) async {
  final routes = <String, WidgetBuilder>{
    '/home': (_) => const Scaffold(),
    '/crops': (_) => const Scaffold(),
    '/crops/crop-1': (_) => const Scaffold(),
    '/calendar/events/event-1': (_) => const Scaffold(),
    '/pro': (_) => const Scaffold(),
    '/pro/manage': (_) => const Scaffold(),
    '/health-log': (_) => const Scaffold(),
    '/scan': (_) => const Scaffold(),
    '/scan/review': (_) => const Scaffold(),
    '/scan/result': (_) => const Scaffold(),
    '/care-plan': (_) => const Scaffold(),
    '/advisories': (_) => const Scaffold(),
    '/shop': (_) => const Scaffold(),
    '/shop/products/p-1': (_) => const Scaffold(),
  };

  await tester.pumpWidget(MaterialApp(
    navigatorObservers: [observer],
    initialRoute: initialRoute,
    routes: routes,
  ));
  await tester.pumpAndSettle();
}

void main() {
  const cases = <String, String>{
    '/home': 'home_viewed',
    '/crops': 'crops_viewed',
    '/crops/crop-1': 'crop_detail_viewed',
    '/calendar/events/event-1': 'task_opened',
    '/pro': 'paywall_viewed',
    '/pro/manage': 'manage_plan_viewed',
    '/health-log': 'health_log_viewed',
    '/scan': 'scan_capture_opened',
    '/scan/review': 'scan_review_viewed',
    '/scan/result': 'scan_result_viewed',
    '/care-plan': 'care_plan_viewed',
    '/advisories': 'advisories_viewed',
    '/shop': 'shop_viewed',
    '/shop/products/p-1': 'shop_product_viewed',
  };

  cases.forEach((route, event) {
    testWidgets('$route emits $event', (tester) async {
      final sink = _CaptureSink();
      final observer = AnalyticsRouteObserver(
        Analytics(sink: sink, language: () => 'en', tier: () => 'free'),
      );

      await _pumpInitial(tester, observer, route);

      expect(sink.events, contains(event),
          reason: 'expected $route to emit $event, got ${sink.events}');
    });
  });
}
