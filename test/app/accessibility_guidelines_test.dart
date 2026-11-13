import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';
import 'package:smart_crops/features/home/screens/home_screen.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WeatherService()),
      ChangeNotifierProvider(create: (_) => SmartCropsService()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      home: child,
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

  group('Home accessibility', () {
    testWidgets('meets Android and iOS tap-target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const HomeScreen(
        briefingFacts: BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 1,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 2,
          hasCrops: true,
        ),
      )));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every tappable control has a semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const HomeScreen(
        briefingFacts: BriefingFacts(
          hasCriticalWeather: true,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 0,
          hasCrops: true,
        ),
      )));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('Scan Result accessibility', () {
    testWidgets('meets Android and iOS tap-target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const ScanResultScreen(
        input: DiagnosisInput(
          diseaseDetected: 'Fungal leaf blight',
          confidenceScore: 52,
          commonCrop: 'Tomato',
          recommendedActions: ['Remove affected leaves'],
        ),
      )));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every tappable control has a semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const ScanResultScreen(
        input: DiagnosisInput(
          diseaseDetected: 'Early blight',
          confidenceScore: 92,
          commonCrop: 'Tomato',
          recommendedActions: ['Apply copper fungicide'],
        ),
      )));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });
}
