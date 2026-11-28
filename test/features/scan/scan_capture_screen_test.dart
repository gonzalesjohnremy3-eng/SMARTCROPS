import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/data/shared_preferences_scan_queue_store.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
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

final _tomato = CropItem(
  id: 't',
  cropName: 'Tomato',
  optimalConditions: const {},
);

FarmSnapshot _snapshot({
  List<CropItem>? crops,
  List<ScanHistoryItem> scans = const [],
}) => FarmSnapshot(
  availableCrops: crops ?? [_tomato],
  userCrops: crops ?? [_tomato],
  scanHistory: scans,
  notifications: const [],
  calendarEvents: const [],
  fetchedAt: DateTime(2026, 1, 1),
);

ScanHistoryItem _scanToday() => ScanHistoryItem(
  id: 's1',
  userId: 'u',
  imageUrl: 'https://example.com/a.jpg',
  diseaseDetected: 'Healthy',
  confidenceScore: 90,
  commonCrop: 'Tomato',
  recommendedActions: const [],
  scannedAt: DateTime.now(),
);

Future<void> _pump(
  WidgetTester tester, {
  FarmSnapshot? snapshot,
  Size size = const Size(390, 844),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(
    loader: _StubLoader(snapshot ?? _snapshot()),
  );
  await service.initializeUserData();
  final entitlement = AgriProEntitlement(fetchRow: () async => null);
  await entitlement.load();
  final queue = ScanQueueProvider(
    store: SharedPreferencesScanQueueStore(),
    service: service,
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: service),
        ChangeNotifierProvider.value(value: entitlement),
        ChangeNotifierProvider.value(value: queue),
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
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const ScanCaptureScreen(),
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

  testWidgets('the shutter is announced as Take photo', (tester) async {
    await _pump(tester);

    expect(find.byTooltip('Take photo'), findsOneWidget);
  });

  testWidgets('upload has its own label', (tester) async {
    await _pump(tester);

    expect(find.text('Upload'), findsOneWidget);
  });

  testWidgets('offers the Main Crops to choose from', (tester) async {
    await _pump(tester);

    expect(find.text('Tomato'), findsOneWidget);
  });

  testWidgets('shows how many free scans are left this week', (tester) async {
    await _pump(tester, snapshot: _snapshot(scans: [_scanToday()]));

    expect(find.text('4 free scans left this week'), findsOneWidget);
  });

  testWidgets('shows framing tips before the photo', (tester) async {
    await _pump(tester);

    expect(find.text('Fill the frame'), findsOneWidget);
  });

  testWidgets('without crops, asks the Farmer to add Main Crops', (
    tester,
  ) async {
    await _pump(tester, snapshot: _snapshot(crops: const []));

    expect(find.text('Add your Main Crops to start scanning.'), findsOneWidget);
  });

  testWidgets('without crops, the shutter is disabled', (tester) async {
    await _pump(tester, snapshot: _snapshot(crops: const []));

    final shutter = tester.widget<IconButton>(
      find.byKey(const Key('capture_button')),
    );
    expect(shutter.onPressed, isNull);
  });

  testWidgets('the Scan tab has no Back button', (tester) async {
    await _pump(tester);

    expect(find.byType(BackButton), findsNothing);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          size: const Size(375, 667),
          locale: locale,
          textScale: 2,
        );
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
