import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/router/app_router.dart';

void main() {
  testWidgets('app router shell renders the 5 navigation destinations', (tester) async {
    final router = buildAppRouter(initialLocation: '/home');

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nav_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_crops')), findsOneWidget);
    expect(find.byKey(const Key('nav_scan')), findsOneWidget);
    expect(find.byKey(const Key('nav_calendar')), findsOneWidget);
    expect(find.byKey(const Key('nav_profile')), findsOneWidget);
  });
}
