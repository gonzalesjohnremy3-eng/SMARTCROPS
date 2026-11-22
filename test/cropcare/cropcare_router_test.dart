import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/router/app_router.dart';
import 'package:smart_crops/cropcare/theme/cropcare_theme.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

void main() {
  testWidgets('/cropcare redirects to the isolated home screen', (
    tester,
  ) async {
    final router = buildAppRouter(
      initialLocation: '/cropcare',
      enforceGuard: false,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: CropCareTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('History'), findsWidgets);
  });
}
