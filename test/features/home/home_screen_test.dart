import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/features/home/domain/field_briefing.dart';
import 'package:smart_crops/features/home/screens/home_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;
  int farmDataCalls = 0;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async {
    farmDataCalls++;
    return snapshot;
  }
}

FarmSnapshot _farmSnapshot() => FarmSnapshot(
      availableCrops: [CropItem(id: 't', cropName: 'Tomato', optimalConditions: const {})],
      userCrops: [CropItem(id: 't', cropName: 'Tomato', optimalConditions: const {})],
      scanHistory: [
        ScanHistoryItem(
          id: 's1',
          userId: 'u',
          imageUrl: 'https://example.com/a.jpg',
          diseaseDetected: 'Healthy',
          confidenceScore: 96,
          commonCrop: 'Ampalaya',
          recommendedActions: const ['Keep monitoring'],
          scannedAt: DateTime(2026, 1, 1),
        ),
      ],
      notifications: const [],
      calendarEvents: [
        CropCalendarEvent(
          id: 'e1',
          userId: 'u',
          eventTitle: 'Mulch the beds',
          eventCategory: 'Nutrition',
          scheduledDate: DateTime(2026, 1, 2),
          isCompleted: false,
          priority: 'Normal',
        ),
      ],
      fetchedAt: DateTime(2026, 1, 1),
    );

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

  Widget buildHome(BriefingFacts facts) {
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
        home: HomeScreen(briefingFacts: facts),
      ),
    );
  }

  testWidgets('Home renders the critical weather priority action', (tester) async {
    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: true,
      overdueTaskCount: 3,
      hasRecentAtRiskDiagnosis: true,
      routineCareCount: 2,
      hasCrops: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Critical weather'), findsOneWidget);
    expect(find.text('Scan a Crop'), findsOneWidget);
  });

  testWidgets('Home renders the overdue task priority action', (tester) async {
    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: false,
      overdueTaskCount: 2,
      hasRecentAtRiskDiagnosis: true,
      routineCareCount: 2,
      hasCrops: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Overdue tasks'), findsOneWidget);
  });

  testWidgets('Home renders the at-risk diagnosis priority action', (tester) async {
    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: false,
      overdueTaskCount: 0,
      hasRecentAtRiskDiagnosis: true,
      routineCareCount: 2,
      hasCrops: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Crop needs attention'), findsOneWidget);
  });

  testWidgets('Home renders the routine care priority action', (tester) async {
    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: false,
      overdueTaskCount: 0,
      hasRecentAtRiskDiagnosis: false,
      routineCareCount: 1,
      hasCrops: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Care Plan'), findsWidgets);
    expect(find.text('Care needed'), findsOneWidget);
  });

  testWidgets('Home renders the empty farm priority action', (tester) async {
    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: false,
      overdueTaskCount: 0,
      hasRecentAtRiskDiagnosis: false,
      routineCareCount: 0,
      hasCrops: false,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Your field office is ready'), findsOneWidget);
  });

  testWidgets('Home renders the all-clear monitoring action', (tester) async {
    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: false,
      overdueTaskCount: 0,
      hasRecentAtRiskDiagnosis: false,
      routineCareCount: 0,
      hasCrops: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('All clear'), findsOneWidget);
  });

  testWidgets('Home previews render real service data, not hardcoded seeds',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final service = SmartCropsService(loader: _StubLoader(_farmSnapshot()));
    await service.initializeUserData();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider.value(value: service),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        home: const HomeScreen(
          briefingFacts: BriefingFacts(
            hasCriticalWeather: false,
            overdueTaskCount: 0,
            hasRecentAtRiskDiagnosis: false,
            routineCareCount: 1,
            hasCrops: true,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mulch the beds'), findsOneWidget,
        reason: 'the Care Plan preview should show the real calendar task');
    expect(find.text('Ampalaya'), findsOneWidget,
        reason: 'the Recent Diagnoses preview should show the real scan');
    expect(find.text('Apply organic compost'), findsNothing,
        reason: 'the hardcoded seed task must be gone');
    expect(find.text('Early Blight'), findsNothing,
        reason: 'the hardcoded seed scan must be gone');
    expect(find.textContaining('High wind alert'), findsNothing,
        reason: 'the fake critical advisory must not appear without data');
  });

  testWidgets('weather panel never invents data when no weather is known',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildHome(const BriefingFacts(
      hasCriticalWeather: false,
      overdueTaskCount: 0,
      hasRecentAtRiskDiagnosis: false,
      routineCareCount: 1,
      hasCrops: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('28°'), findsNothing,
        reason: 'invented temperature must not be shown');
    expect(find.textContaining('Humidity 0%'), findsNothing,
        reason: 'invented humidity must not be shown');
    expect(find.text('—'), findsWidgets,
        reason: 'unknown values should be shown honestly as dashes');
  });

  testWidgets('pull-to-refresh reloads farm data', (tester) async {
    final loader = _StubLoader(_farmSnapshot());
    final service = SmartCropsService(loader: loader);
    await service.initializeUserData();
    final callsBefore = loader.farmDataCalls;

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider.value(value: service),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        home: const HomeScreen(
          briefingFacts: BriefingFacts(
            hasCriticalWeather: false,
            overdueTaskCount: 0,
            hasRecentAtRiskDiagnosis: false,
            routineCareCount: 1,
            hasCrops: true,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(CustomScrollView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(loader.farmDataCalls, greaterThan(callsBefore),
        reason: 'pulling down should refresh the cached farm data');
  });
}
