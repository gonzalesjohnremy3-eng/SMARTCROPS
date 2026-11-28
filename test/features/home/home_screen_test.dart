import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
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

FarmSnapshot _farmSnapshot({List<AppNotification> notifications = const []}) =>
    FarmSnapshot(
      profile: UserProfile(
        id: 'u',
        fullName: 'Maria Santos',
        email: 'maria@example.com',
      ),
      availableCrops: [
        CropItem(id: 't', cropName: 'Tomato', optimalConditions: const {}),
      ],
      userCrops: [
        CropItem(id: 't', cropName: 'Tomato', optimalConditions: const {}),
      ],
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
      notifications: notifications,
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

  testWidgets('Home renders the critical weather priority action', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: true,
          overdueTaskCount: 3,
          hasRecentAtRiskDiagnosis: true,
          routineCareCount: 2,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Critical weather'), findsOneWidget);
    expect(find.text('Scan a crop'), findsOneWidget);
  });

  testWidgets('Home renders the overdue task priority action', (tester) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 2,
          hasRecentAtRiskDiagnosis: true,
          routineCareCount: 2,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Overdue tasks'), findsOneWidget);
  });

  testWidgets('Home renders the at-risk diagnosis priority action', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: true,
          routineCareCount: 2,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Crop needs attention'), findsOneWidget);
  });

  testWidgets('Home renders the routine care priority action', (tester) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 1,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Care Plan'), findsWidgets);
    expect(find.text('Care needed'), findsOneWidget);
  });

  testWidgets('Home renders the empty farm priority action', (tester) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 0,
          hasCrops: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your field office is ready'), findsOneWidget);
  });

  testWidgets('Home renders the all-clear monitoring action', (tester) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 0,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All clear'), findsOneWidget);
  });

  testWidgets('Home previews render real service data, not hardcoded seeds', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final service = SmartCropsService(loader: _StubLoader(_farmSnapshot()));
    await service.initializeUserData();

    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Mulch the beds'),
      findsOneWidget,
      reason: 'the Care Plan preview should show the real calendar task',
    );
    expect(
      find.text('Ampalaya'),
      findsOneWidget,
      reason: 'the Recent Diagnoses preview should show the real scan',
    );
    expect(
      find.text('Apply organic compost'),
      findsNothing,
      reason: 'the hardcoded seed task must be gone',
    );
    expect(
      find.text('Early Blight'),
      findsNothing,
      reason: 'the hardcoded seed scan must be gone',
    );
    expect(
      find.textContaining('High wind alert'),
      findsNothing,
      reason: 'the fake critical advisory must not appear without data',
    );
  });

  Future<void> pumpWithService(
    WidgetTester tester,
    SmartCropsService service,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('greets the Farmer by first name', (tester) async {
    final service = SmartCropsService(loader: _StubLoader(_farmSnapshot()));
    await service.initializeUserData();

    await pumpWithService(tester, service);

    expect(find.text('Maria'), findsOneWidget);
  });

  testWidgets('scan severity reads in words, not shouted labels', (
    tester,
  ) async {
    final service = SmartCropsService(loader: _StubLoader(_farmSnapshot()));
    await service.initializeUserData();

    await pumpWithService(tester, service);

    expect(find.text('Healthy'), findsOneWidget);
  });

  testWidgets('an unread advisory appears under the briefing', (tester) async {
    final service = SmartCropsService(
      loader: _StubLoader(
        _farmSnapshot(
          notifications: [
            AppNotification(
              id: 'n1',
              userId: 'u',
              title: 'Typhoon signal 2 in your area',
              message: 'Secure seedlings.',
              isRead: false,
              createdAt: DateTime(2026, 1, 1),
            ),
          ],
        ),
      ),
    );
    await service.initializeUserData();

    await pumpWithService(tester, service);

    expect(find.text('Typhoon signal 2 in your area'), findsOneWidget);
  });

  testWidgets('scanning is offered inline, not as a floating button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 1,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('the scan prompt explains why to scan', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 1,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Spot problems early. Point your camera at one leaf.'),
      findsOneWidget,
    );
  });

  testWidgets('weather panel never invents data when no weather is known', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 0,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 1,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('28°'),
      findsNothing,
      reason: 'invented temperature must not be shown',
    );
    expect(
      find.textContaining('Humidity 0%'),
      findsNothing,
      reason: 'invented humidity must not be shown',
    );
    expect(
      find.text('—'),
      findsWidgets,
      reason: 'unknown values should be shown honestly as dashes',
    );
  });

  testWidgets('pull-to-refresh reloads farm data', (tester) async {
    final loader = _StubLoader(_farmSnapshot());
    final service = SmartCropsService(loader: loader);
    await service.initializeUserData();
    final callsBefore = loader.farmDataCalls;

    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(
      loader.farmDataCalls,
      greaterThan(callsBefore),
      reason: 'pulling down should refresh the cached farm data',
    );
  });

  testWidgets('renders the wide split dashboard at expanded widths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 1,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 2,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-wide-split')), findsOneWidget);
    expect(find.byKey(const Key('home-wide-actions')), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = SmartCropsService(loader: _StubLoader(_farmSnapshot()));
      await service.initializeUserData();

      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => WeatherService()),
              ChangeNotifierProvider.value(value: service),
            ],
            child: MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                CebMaterialLocalizationsDelegate(),
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                CebCupertinoLocalizationsDelegate(),
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('tl'),
                Locale('ceb'),
              ],
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: const HomeScreen(
                briefingFacts: BriefingFacts(
                  hasCriticalWeather: true,
                  overdueTaskCount: 0,
                  hasRecentAtRiskDiagnosis: false,
                  routineCareCount: 1,
                  hasCrops: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }

  testWidgets('keeps the single-column dashboard compact', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildHome(
        const BriefingFacts(
          hasCriticalWeather: false,
          overdueTaskCount: 1,
          hasRecentAtRiskDiagnosis: false,
          routineCareCount: 2,
          hasCrops: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-wide-split')), findsNothing);
  });
}
