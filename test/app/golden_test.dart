import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      debugShowCheckedModeBanner: false,
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

Future<void> _loadFonts() async {
  final fraunces = FontLoader('Fraunces')
    ..addFont(rootBundle.load('assets/fonts/fraunces/fraunces-v38-latin-regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/fraunces/fraunces-v38-latin-600.ttf'));
  final publicSans = FontLoader('Public Sans')
    ..addFont(rootBundle.load('assets/fonts/public_sans/public-sans-v21-latin-regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/public_sans/public-sans-v21-latin-600.ttf'));

  final loaders = <Future<void>>[fraunces.load(), publicSans.load()];

  // The Material Icons font is not declared in pubspec, so the test bundle
  // cannot resolve it by asset key. Load it from the SDK cache when present.
  for (final path in _materialIconsCandidates()) {
    final file = File(path);
    if (file.existsSync()) {
      final materialIcons = FontLoader('MaterialIcons')
        ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
      loaders.add(materialIcons.load());
      break;
    }
  }

  await Future.wait(loaders);
}

Iterable<String> _materialIconsCandidates() sync* {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    yield '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  }
  yield 'build/flutter_assets/fonts/MaterialIcons-Regular.otf';
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
    await _loadFonts();
  });

  setUp(() {
    Directory('test/goldens').createSync(recursive: true);
  });

  Future<void> pumpAtPhone(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(_wrap(child));
    await tester.pumpAndSettle();
  }

  testWidgets('Home with an overdue task matches the golden', (tester) async {
    await pumpAtPhone(
      tester,
      const HomeScreen(
        briefingFacts: BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 1,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 1,
          hasCrops: true,
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_overdue_task.png'),
    );
  });

  testWidgets('Scan Result low confidence matches the golden', (tester) async {
    await pumpAtPhone(
      tester,
      const ScanResultScreen(
        input: DiagnosisInput(
          diseaseDetected: 'Fungal leaf blight',
          confidenceScore: 52,
          commonCrop: 'Tomato',
          recommendedActions: ['Remove affected leaves'],
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/scan_result_low_confidence.png'),
    );
  });
}
