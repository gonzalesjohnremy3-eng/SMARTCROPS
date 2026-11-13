import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/push/push_notifications.dart';

void main() {
  group('routeForNotificationData', () {
    test('explicit safe path wins over target mapping', () {
      expect(routeForNotificationData({'path': '/calendar/events/e-9', 'target': 'scan'}), '/calendar/events/e-9');
    });

    test('path outside the safe prefixes falls back to mapping', () {
      expect(routeForNotificationData({'path': '/cooperative', 'target': 'task', 'recordId': 'e-1'}), '/calendar/events/e-1');
    });

    test('target task maps to the calendar event with encoded id', () {
      expect(routeForNotificationData({'target': 'task', 'recordId': 'e/1'}), '/calendar/events/e%2F1');
    });

    test('target crop maps to the crop detail', () {
      expect(routeForNotificationData({'target': 'crop', 'recordId': 'c-1'}), '/crops/c-1');
    });

    test('target scan falls back to the health log', () {
      expect(routeForNotificationData({'target': 'scan', 'recordId': 's-1'}), '/health-log');
    });

    test('target advisory falls back to the inbox', () {
      expect(routeForNotificationData({'target': 'advisory', 'recordId': 'a-1'}), '/advisories');
    });

    test('target cooperative falls back to the inbox until Phase 3 ships', () {
      expect(routeForNotificationData({'target': 'cooperative'}), '/advisories');
    });

    test('missing or unknown target falls back to the inbox', () {
      expect(routeForNotificationData(const {}), '/advisories');
      expect(routeForNotificationData({'target': 'nonsense'}), '/advisories');
    });

    test('task without recordId falls back to the inbox', () {
      expect(routeForNotificationData({'target': 'task'}), '/advisories');
    });
  });
}
