import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/care_plan/screens/care_plan_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

CropItem _tomato() => CropItem(
      id: 'crop-tomato',
      cropName: 'Tomato',
      optimalConditions: const {},
    );

CropCalendarEvent _task({
  required String id,
  required String title,
  required DateTime date,
  String priority = 'Normal',
}) =>
    CropCalendarEvent(
      id: id,
      userId: 'u',
      eventTitle: title,
      eventCategory: 'Nutrition',
      scheduledDate: date,
      isCompleted: false,
      priority: priority,
    );

ScanHistoryItem _scan({
  required String disease,
  DateTime? scannedAt,
}) =>
    ScanHistoryItem(
      id: 'scan-$disease',
      userId: 'u',
      imageUrl: 'https://example.com/a.jpg',
      diseaseDetected: disease,
      confidenceScore: 90,
      commonCrop: 'Tomato',
      recommendedActions: const ['Keep monitoring'],
      scannedAt: scannedAt ?? DateTime.now().subtract(const Duration(days: 2)),
    );

FarmSnapshot _snapshot({
  List<CropCalendarEvent> tasks = const [],
  List<ScanHistoryItem> scans = const [],
}) =>
    FarmSnapshot(
      availableCrops: [_tomato()],
      userCrops: [_tomato()],
      scanHistory: scans,
      notifications: const [],
      calendarEvents: tasks,
      fetchedAt: DateTime(2026, 1, 1),
    );

Future<void> _pump(WidgetTester tester, FarmSnapshot snapshot) async {
  await tester.binding.setSurfaceSize(const Size(500, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(loader: _StubLoader(snapshot));
  await service.initializeUserData();

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: service),
      ChangeNotifierProvider(create: (_) => WeatherService()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      home: const CarePlanScreen(),
    ),
  ));
  await tester.pumpAndSettle();
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
      // Already initialized.
    }
  });

  testWidgets('groups tasks by segment and shows reasons', (tester) async {
    final now = DateTime.now();

    await _pump(tester, _snapshot(
      tasks: [
        _task(
          id: 'overdue',
          title: 'Mulch the beds',
          date: now.subtract(const Duration(days: 2)),
        ),
        _task(
          id: 'thisweek',
          title: 'Apply stakes',
          date: now.add(const Duration(days: 3)),
          priority: 'High',
        ),
        _task(
          id: 'preventive',
          title: 'Soil pH check',
          date: now.add(const Duration(days: 15)),
        ),
      ],
      scans: [_scan(disease: 'Early blight')],
    ));

    expect(find.text('Today'), findsWidgets);
    expect(find.text('This Week'), findsWidgets);
    expect(find.text('Preventive'), findsWidgets);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('Mulch the beds'), findsOneWidget);
    expect(find.text('Apply stakes'), findsOneWidget);
    expect(find.text('Soil pH check'), findsOneWidget);
    expect(find.text('Suggested for you'), findsOneWidget);
    expect(find.text('Add to calendar'), findsOneWidget);
    expect(find.textContaining('Recheck Tomato'), findsOneWidget);
  });

  testWidgets('shows the empty state when there is nothing to plan', (tester) async {
    await _pump(tester, _snapshot());

    expect(find.text('No care items due. Your crops look good.'), findsOneWidget);
  });
}
