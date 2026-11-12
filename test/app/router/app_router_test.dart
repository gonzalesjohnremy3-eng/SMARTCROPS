import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/router/app_router.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

void main() {
  testWidgets('app router shell renders the 5 navigation destinations', (tester) async {
    final router = buildAppRouter(
      initialLocation: '/home',
      enforceGuard: false,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tl'),
          Locale('ceb'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('My Crops'), findsOneWidget);
    expect(find.byTooltip('Scan Crop'), findsOneWidget);
    expect(find.byTooltip('Field Calendar'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
  });
}
