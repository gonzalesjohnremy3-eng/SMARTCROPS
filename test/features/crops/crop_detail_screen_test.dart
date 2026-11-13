import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/crops/screens/crop_detail_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

CropItem _tomato({Map<String, dynamic>? conditions}) => CropItem(
      id: 'crop-tomato',
      cropName: 'Tomato',
      optimalConditions: conditions ??
          const {
            'temperature_range': '20-30C',
            'soil': 'Well-drained loam',
            'watering': 'Regular',
          },
    );

ScanHistoryItem _scan({
  required String crop,
  required String disease,
  int confidence = 90,
}) =>
    ScanHistoryItem(
      id: 'scan-$crop-$disease',
      userId: 'u',
      imageUrl: 'https://example.com/a.jpg',
      diseaseDetected: disease,
      confidenceScore: confidence.toDouble(),
      commonCrop: crop,
      recommendedActions: const ['Keep monitoring'],
      scannedAt: DateTime(2026, 1, 1),
    );

CropCalendarEvent _task({
  required String id,
  required String title,
  String? cropId,
  bool completed = false,
}) =>
    CropCalendarEvent(
      id: id,
      userId: 'u',
      cropId: cropId,
      eventTitle: title,
      eventCategory: 'Water Management',
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      isCompleted: completed,
      priority: 'Normal',
    );

FarmSnapshot _snapshot({
  List<ScanHistoryItem> scans = const [],
  List<CropCalendarEvent> tasks = const [],
}) =>
    FarmSnapshot(
      availableCrops: [_tomato()],
      userCrops: [_tomato()],
      scanHistory: scans,
      notifications: const [],
      calendarEvents: tasks,
      fetchedAt: DateTime(2026, 1, 1),
    );

Future<void> _pump(
  WidgetTester tester, {
  required CropItem crop,
  required FarmSnapshot snapshot,
}) async {
  await tester.binding.setSurfaceSize(const Size(500, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(loader: _StubLoader(snapshot));
  await service.initializeUserData();

  await tester.pumpWidget(MultiProvider(
    providers: [ChangeNotifierProvider.value(value: service)],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      home: CropDetailScreen(crop: crop),
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

  testWidgets('renders the crop name and catalog growing conditions',
      (tester) async {
    await _pump(tester, crop: _tomato(), snapshot: _snapshot());

    expect(find.text('Tomato'), findsWidgets);
    expect(find.textContaining('20-30C'), findsOneWidget);
    expect(find.textContaining('Well-drained loam'), findsOneWidget);
  });

  testWidgets('shows Not available instead of inventing missing conditions',
      (tester) async {
    await _pump(
      tester,
      crop: _tomato(conditions: const {}),
      snapshot: _snapshot(),
    );

    expect(find.text('Not available'), findsWidgets);
  });

  testWidgets('lists only the latest scans for this crop', (tester) async {
    await _pump(
      tester,
      crop: _tomato(),
      snapshot: _snapshot(scans: [
        _scan(crop: 'Tomato', disease: 'Early blight'),
        _scan(crop: 'Tomato', disease: 'Leaf spot'),
        _scan(crop: 'Tomato', disease: 'Third scan'),
        _scan(crop: 'Pechay', disease: 'Aphids'),
      ]),
    );

    expect(find.textContaining('Early blight'), findsOneWidget);
    expect(find.textContaining('Leaf spot'), findsOneWidget);
    expect(find.textContaining('Third scan'), findsNothing,
        reason: 'only the latest two scans for this crop are shown');
    expect(find.textContaining('Aphids'), findsNothing,
        reason: 'scans for other crops must not appear');
  });

  testWidgets('shows Not scanned yet when the crop has no scans',
      (tester) async {
    await _pump(tester, crop: _tomato(), snapshot: _snapshot());

    expect(find.text('Not scanned yet'), findsWidgets);
  });

  testWidgets('shows upcoming tasks for this crop with a calendar link',
      (tester) async {
    await _pump(
      tester,
      crop: _tomato(),
      snapshot: _snapshot(tasks: [
        _task(id: 't1', title: 'Water deeply', cropId: 'crop-tomato'),
        _task(id: 't2', title: 'Unrelated task', cropId: 'crop-corn'),
      ]),
    );

    expect(find.text('Water deeply'), findsOneWidget);
    expect(find.text('Unrelated task'), findsNothing,
        reason: 'tasks for other crops must not appear');
    expect(find.text('Open calendar'), findsOneWidget);
  });

  testWidgets('offers Scan this crop as the primary action', (tester) async {
    await _pump(tester, crop: _tomato(), snapshot: _snapshot());

    expect(
      find.widgetWithText(FilledButton, 'Scan this crop'),
      findsOneWidget,
    );
  });
}
