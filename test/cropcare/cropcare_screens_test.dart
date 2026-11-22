import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/cropcare/screens/cropcare_home_screen.dart';
import 'package:smart_crops/cropcare/screens/cropcare_scan_screen.dart';
import 'package:smart_crops/cropcare/screens/cropcare_result_screen.dart';
import 'package:smart_crops/cropcare/screens/cropcare_history_screen.dart';
import 'package:smart_crops/cropcare/screens/cropcare_profile_screen.dart';
import 'package:smart_crops/cropcare/theme/cropcare_theme.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

void main() {
  testWidgets('CropCare home renders greeting and scan action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CropCareTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CropCareHomeScreen(),
      ),
    );

    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('Scan Your Crop'), findsOneWidget);
  });

  testWidgets('CropCare scan renders viewfinder hint and capture controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CropCareTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CropCareScanScreen(),
      ),
    );

    expect(find.text('Fill the frame with the affected leaf'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
  });

  testWidgets('CropCare result renders healthy status and next steps', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CropCareTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CropCareResultScreen(),
      ),
    );

    expect(find.text('No disease detected'), findsOneWidget);
    expect(find.text('Save to Health Log'), findsOneWidget);
  });

  testWidgets('CropCare history renders scan log', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CropCareTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CropCareHistoryScreen(),
      ),
    );

    expect(find.text('Scan History'), findsOneWidget);
    expect(find.text('Pechay'), findsOneWidget);
  });

  testWidgets('CropCare profile renders farm summary and settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CropCareTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CropCareProfileScreen(),
      ),
    );

    expect(find.text('San Isidro Plot · 2 crops'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
  });
}
