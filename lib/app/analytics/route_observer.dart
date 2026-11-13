import 'package:flutter/material.dart';
import 'package:smart_crops/app/analytics/analytics.dart';

/// Maps initial and named top-level routes to page-view events.
/// Deep links, unnamed MaterialPageRoutes, and repeated branch switches
/// do not fire duplicates.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this.analytics);

  final Analytics analytics;

  static const Map<String, String> _exactEvents = {
    '/home': 'home_viewed',
    '/crops': 'crops_viewed',
    '/scan': 'scan_capture_opened',
    '/calendar': 'calendar_viewed',
    '/care-plan': 'care_plan_viewed',
    '/health-log': 'health_log_viewed',
    '/advisories': 'advisories_viewed',
    '/profile': 'profile_viewed',
    '/pro': 'paywall_viewed',
    '/pro/manage': 'manage_plan_viewed',
    '/onboarding': 'onboarding_viewed',
  };

  static const Map<String, String> _prefixEvents = {
    '/crops/': 'crop_detail_viewed',
    '/calendar/events/': 'task_opened',
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? oldRoute, Route<dynamic>? newRoute}) {
    super.didReplace(oldRoute: oldRoute, newRoute: newRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final path = route.settings.name;
    if (path == null || path.isEmpty) return;
    final event = _eventFor(path);
    if (event == null) return;
    analytics.track(
      event,
      params: {'source_screen': path},
    );
  }

  String? _eventFor(String path) {
    final exact = _exactEvents[path];
    if (exact != null) return exact;
    for (final entry in _prefixEvents.entries) {
      if (path.startsWith(entry.key)) return entry.value;
    }
    return null;
  }
}
