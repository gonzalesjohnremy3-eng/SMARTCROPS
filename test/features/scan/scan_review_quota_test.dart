import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smart_crops/features/pro/screens/agri_pro_paywall_screen.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/screens/scan_review_screen.dart';
import 'package:smart_crops/features/scan/data/shared_preferences_scan_queue_store.dart';
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

CropItem _tomato() => CropItem(
      id: 'tomato',
      cropName: 'Tomato',
      optimalConditions: const {},
    );

ScanHistoryItem _scanThisWeek(int index) => ScanHistoryItem(
      id: 'scan-w-$index',
      userId: 'u',
      imageUrl: 'https://example.com/a.jpg',
      diseaseDetected: 'Early blight',
      confidenceScore: 90,
      commonCrop: 'Tomato',
      recommendedActions: const ['Keep monitoring'],
      scannedAt: DateTime.now(),
    );

FarmSnapshot _snapshot({List<ScanHistoryItem> scans = const []}) => FarmSnapshot(
      availableCrops: [_tomato()],
      userCrops: [_tomato()],
      scanHistory: scans,
      notifications: const [],
      calendarEvents: const [],
      fetchedAt: DateTime(2026, 1, 1),
    );

Future<void> _pumpReview(
  WidgetTester tester,
  FarmSnapshot snapshot,
) async {
  await tester.binding.setSurfaceSize(const Size(500, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(loader: _StubLoader(snapshot));
  await service.initializeUserData();

  final entitlement = AgriProEntitlement(fetchRow: () async => null);
  await entitlement.load();

  final queue = ScanQueueProvider(
    store: SharedPreferencesScanQueueStore(),
    service: service,
  );

  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ScanReviewScreen(
        localImagePath: 'test.png',
        cropName: 'Tomato',
      ),
    ),
    GoRoute(
      path: '/pro',
      builder: (context, state) => const AgriProPaywallScreen(fromQuota: true),
    ),
  ]);

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: service),
      ChangeNotifierProvider.value(value: entitlement),
      ChangeNotifierProvider.value(value: queue),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
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

  testWidgets('a free farmer out of weekly scans is sent to the paywall',
      (tester) async {
    await _pumpReview(tester, _snapshot(scans: List.generate(5, _scanThisWeek)));

    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();

    expect(find.text('Protect more of what you grow.'), findsOneWidget);
    expect(
      find.text("You've used 5 of 5 free scans this week. Agri Pro removes the limit."),
      findsOneWidget,
    );
  });

  testWidgets('a free farmer with scans remaining is not blocked', (tester) async {
    await _pumpReview(tester, _snapshot(scans: List.generate(2, _scanThisWeek)));

    await tester.tap(find.text('Analyze'));
    // The offline retry loop books real timers; pump a couple of frames instead of
    // settling so the assertion runs before retry scheduling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Protect more of what you grow.'), findsNothing);
  });
}
