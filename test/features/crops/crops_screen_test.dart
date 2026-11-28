import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/crops/screens/crops_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

CropItem _crop(String name, {Map<String, dynamic>? conditions}) => CropItem(
  id: 'crop-$name',
  cropName: name,
  optimalConditions:
      conditions ??
      const {'temperature_range': '20-30C', 'watering': 'Regular'},
);

ScanHistoryItem _scan(String crop, String disease) => ScanHistoryItem(
  id: 'scan-$crop',
  userId: 'u',
  imageUrl: 'https://example.com/a.jpg',
  diseaseDetected: disease,
  confidenceScore: 90,
  commonCrop: crop,
  recommendedActions: const ['Keep monitoring'],
  scannedAt: DateTime(2026, 1, 1),
);

Future<void> _pump(
  WidgetTester tester, {
  required List<CropItem> crops,
  List<ScanHistoryItem> scans = const [],
  String locale = 'en',
  double textScale = 1,
  Size size = const Size(390, 1600),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(
    loader: _StubLoader(
      FarmSnapshot(
        availableCrops: crops,
        userCrops: crops,
        scanHistory: scans,
        notifications: const [],
        calendarEvents: const [],
        fetchedAt: DateTime(2026, 1, 1),
      ),
    ),
  );
  await service.initializeUserData();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: service,
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
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const CropsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        publishableKey: 'test-anon-key',
      );
    } catch (_) {
      // Already initialized.
    }
  });

  testWidgets('counts the Main Crops under the title', (tester) async {
    await _pump(tester, crops: [_crop('Tomato'), _crop('Rice')]);

    expect(find.text('2 crops selected'), findsOneWidget);
  });

  testWidgets('shows each crop\'s health from its latest scan', (tester) async {
    await _pump(
      tester,
      crops: [_crop('Tomato')],
      scans: [_scan('Tomato', 'Early blight')],
    );

    expect(find.text('At Risk'), findsOneWidget);
  });

  testWidgets('a healthy crop reads healthy', (tester) async {
    await _pump(
      tester,
      crops: [_crop('Pechay')],
      scans: [_scan('Pechay', 'Healthy / no disease detected')],
    );

    expect(find.text('Healthy'), findsOneWidget);
  });

  testWidgets('an unscanned crop says so instead of inventing a status', (
    tester,
  ) async {
    await _pump(tester, crops: [_crop('Tomato')]);

    expect(find.text('Not scanned yet'), findsOneWidget);
  });

  testWidgets('says how many crops need attention', (tester) async {
    await _pump(
      tester,
      crops: [_crop('Tomato'), _crop('Rice')],
      scans: [_scan('Tomato', 'Early blight')],
    );

    expect(find.text('1 crop needs attention'), findsOneWidget);
  });

  testWidgets('stays quiet when nothing needs attention', (tester) async {
    await _pump(tester, crops: [_crop('Tomato')]);

    expect(find.textContaining('needs attention'), findsNothing);
  });

  testWidgets('formats the last scan date for the locale', (tester) async {
    await _pump(
      tester,
      crops: [_crop('Tomato')],
      scans: [_scan('Tomato', 'Early blight')],
    );

    expect(find.textContaining('Jan 1'), findsOneWidget);
  });

  testWidgets('each crop has one labelled scan button', (tester) async {
    await _pump(tester, crops: [_crop('Tomato')]);

    expect(find.byTooltip('Scan this crop'), findsOneWidget);
  });

  testWidgets('lists growing conditions as chips', (tester) async {
    await _pump(tester, crops: [_crop('Tomato')]);

    expect(find.text('Watering: Regular'), findsOneWidget);
  });

  testWidgets('empty state explains what to do', (tester) async {
    await _pump(tester, crops: const []);

    expect(
      find.text('No crops yet. Add your first crop to get personalized care.'),
      findsOneWidget,
    );
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          crops: [_crop('Tomato'), _crop('Rice'), _crop('Pechay')],
          scans: [_scan('Tomato', 'Early blight')],
          locale: locale,
          textScale: 2,
          size: const Size(375, 667),
        );
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
