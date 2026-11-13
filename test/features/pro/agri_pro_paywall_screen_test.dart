import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/screens/agri_pro_paywall_screen.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
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

class _FakeBilling implements BillingRepository {
  _FakeBilling({required this.outcome});

  final BillingOutcome outcome;
  AgriProPlanId? purchasedPlan;

  @override
  Future<BillingOutcome> purchase(AgriProPlanId plan) async {
    purchasedPlan = plan;
    return outcome;
  }

  @override
  Future<BillingOutcome> restore() async => outcome;
}

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
      availableCrops: [
        CropItem(id: 'tomato', cropName: 'Tomato', optimalConditions: const {}),
      ],
      userCrops: [
        CropItem(id: 'tomato', cropName: 'Tomato', optimalConditions: const {}),
      ],
      scanHistory: scans,
      notifications: const [],
      calendarEvents: const [],
      fetchedAt: DateTime(2026, 1, 1),
    );

Future<void> _pumpPaywall(
  WidgetTester tester, {
  required FarmSnapshot snapshot,
  required BillingRepository billing,
  required Map<String, dynamic>? subscriptionRow,
  bool fromQuota = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(500, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(loader: _StubLoader(snapshot));
  await service.initializeUserData();

  final entitlement = AgriProEntitlement(fetchRow: () async => subscriptionRow);
  await entitlement.load();

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: service),
      ChangeNotifierProvider.value(value: entitlement),
      Provider<BillingRepository>.value(value: billing),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      home: AgriProPaywallScreen(fromQuota: fromQuota),
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

  testWidgets('renders headline, quota context, and both plan prices', (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(scans: List.generate(5, _scanThisWeek)),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
      fromQuota: true,
    );

    expect(find.text('Protect more of what you grow.'), findsOneWidget);
    expect(
      find.text("You've used 5 of 5 free scans this week. Agri Pro removes the limit."),
      findsOneWidget,
    );
    expect(find.text('₱99/month'), findsOneWidget);
    expect(find.text('₱499/6 months'), findsOneWidget);
    expect(find.text('Save 16%'), findsOneWidget);
    expect(find.text('Start Agri Pro'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('Cancel anytime.'), findsOneWidget);
  });

  testWidgets('the Seasonal plan is pre-selected', (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('tapping Start Agri Pro shows the not-configured message when billing is unavailable',
      (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    await tester.tap(find.text('Start Agri Pro'));
    await tester.pump();

    expect(
      find.text('Agri Pro purchases are not available yet. They will open when the store listing is live.'),
      findsOneWidget,
    );
  });

  testWidgets('a successful purchase refreshes the entitlement and shows the unlocked message',
      (tester) async {
    final billing = _FakeBilling(outcome: const BillingSucceeded());

    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: billing,
      subscriptionRow: const {'tier': 'premium', 'expires_at': null},
    );

    await tester.tap(find.text('Start Agri Pro'));
    await tester.pumpAndSettle();

    expect(billing.purchasedPlan, AgriProPlanId.seasonal);
    expect(find.text('Agri Pro unlocked.'), findsOneWidget);
  });
}
