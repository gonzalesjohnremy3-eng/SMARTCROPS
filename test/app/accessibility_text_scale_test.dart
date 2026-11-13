import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';
import 'package:smart_crops/features/home/screens/home_screen.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WeatherService()),
      ChangeNotifierProvider(create: (_) => SmartCropsService()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      home: child,
      builder: (context, widget) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
          child: widget!,
        );
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Already initialized
    }
  });

  testWidgets('Home renders without overflow at 200% text scale', (tester) async {
    await tester.pumpWidget(_wrap(const HomeScreen(
      briefingFacts: BriefingFacts(
        hasCriticalWeather: true,
        overdueTaskCount: 1,
        hasRecentAtRiskDiagnosis: true,
        routineCareCount: 2,
        hasCrops: true,
      ),
    )));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Scan Result renders without overflow at 200% text scale', (tester) async {
    await tester.pumpWidget(_wrap(const ScanResultScreen(
      input: DiagnosisInput(
        diseaseDetected: 'Fungal leaf blight',
        confidenceScore: 52,
        commonCrop: 'Tomato',
        recommendedActions: [
          'Remove affected leaves and dispose of them away from the field',
          'Improve airflow around the canopy by spacing and pruning',
          'Apply a copper-based fungicide following the label instructions',
        ],
      ),
    )));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
