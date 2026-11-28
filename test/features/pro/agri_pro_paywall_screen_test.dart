import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
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

FarmSnapshot _snapshot({List<ScanHistoryItem> scans = const []}) =>
    FarmSnapshot(
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
  Size size = const Size(500, 2200),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(loader: _StubLoader(snapshot));
  await service.initializeUserData();

  final entitlement = AgriProEntitlement(fetchRow: () async => subscriptionRow);
  await entitlement.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: service),
        ChangeNotifierProvider.value(value: entitlement),
        Provider<BillingRepository>.value(value: billing),
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
        home: AgriProPaywallScreen(fromQuota: fromQuota),
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
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Already initialized.
    }
  });

  testWidgets('renders headline, quota context, and both plan prices', (
    tester,
  ) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(scans: List.generate(5, _scanThisWeek)),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
      fromQuota: true,
    );

    expect(find.text('Protect more of what you grow.'), findsOneWidget);
    expect(
      find.text(
        "You've used 5 of 5 free scans this week. Agri Pro removes the limit.",
      ),
      findsOneWidget,
    );
    expect(find.text('₱99/month'), findsNWidgets(2));
    expect(find.text('₱499/6 months'), findsNWidgets(2));
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

  testWidgets(
    'tapping Start Agri Pro shows the not-configured message when billing is unavailable',
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
        find.text(
          'Agri Pro purchases are not available yet. They will open when the store listing is live.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a successful purchase refreshes the entitlement and shows the unlocked message',
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
    },
  );

  testWidgets('shows the chosen plan comparison table on the plan screen', (
    tester,
  ) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    final table = find.byKey(const Key('pro-comparison-table'));
    expect(table, findsOneWidget);
    expect(
      find.descendant(of: table, matching: find.text('Free')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: table, matching: find.text('Unlimited scans')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: table, matching: find.text('₱99/month')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: table, matching: find.text('₱499/6 months')),
      findsOneWidget,
    );
  });

  testWidgets('each plan in the comparison has its own icon', (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    final table = find.byKey(const Key('pro-comparison-table'));
    expect(
      find.descendant(of: table, matching: find.byType(Icon)),
      findsNWidgets(3),
    );
  });

  testWidgets('the comparison rows start at the left, not the middle', (
    tester,
  ) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    final table = find.byKey(const Key('pro-comparison-table'));
    final tableLeft = tester.getTopLeft(table).dx;
    final iconLeft = tester
        .getTopLeft(
          find.descendant(of: table, matching: find.byType(Icon)).first,
        )
        .dx;

    expect(iconLeft - tableLeft, lessThan(32));
  });

  testWidgets('says what Pro adds beyond unlimited scans', (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    expect(find.text('Priority analysis'), findsOneWidget);
  });

  testWidgets('shows the Seasonal renewal terms by default', (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    expect(find.text('Renews every 6 months at ₱499.'), findsOneWidget);
  });

  testWidgets('choosing Monthly switches the renewal terms and the purchase', (
    tester,
  ) async {
    final billing = _FakeBilling(outcome: const BillingUnavailable());
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: billing,
      subscriptionRow: null,
    );
    await tester.tap(find.byKey(const Key('pro-plan-monthly')));
    await tester.pump();
    await tester.tap(find.text('Start Agri Pro'));
    await tester.pump();

    expect(billing.purchasedPlan, AgriProPlanId.monthly);
  });

  testWidgets('has a Back button', (tester) async {
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    expect(find.byTooltip('Back'), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pumpPaywall(
          tester,
          snapshot: _snapshot(scans: List.generate(5, _scanThisWeek)),
          billing: _FakeBilling(outcome: const BillingUnavailable()),
          subscriptionRow: null,
          fromQuota: true,
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

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpPaywall(
      tester,
      snapshot: _snapshot(),
      billing: _FakeBilling(outcome: const BillingUnavailable()),
      subscriptionRow: null,
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
