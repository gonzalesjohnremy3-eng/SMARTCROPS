import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/health_log/screens/health_log_screen.dart';
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

ScanHistoryItem _scan(String id, String disease) => ScanHistoryItem(
  id: id,
  userId: 'u',
  imageUrl: 'https://example.com/$id.jpg',
  diseaseDetected: disease,
  confidenceScore: 90,
  commonCrop: 'Tomato',
  recommendedActions: const ['Keep monitoring'],
  scannedAt: DateTime(2026, 1, 1),
);

FarmSnapshot _snapshot() => FarmSnapshot(
  availableCrops: const [],
  userCrops: const [],
  scanHistory: [_scan('s1', 'Leaf spot'), _scan('s2', 'Early blight')],
  notifications: const [],
  calendarEvents: const [],
  fetchedAt: DateTime(2026, 1, 1),
);

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(loader: _StubLoader(_snapshot()));
  await service.initializeUserData();

  await tester.pumpWidget(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: service)],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        home: const HealthLogScreen(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
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

  testWidgets('shows master-detail and selects a scan by tap', (tester) async {
    await _pump(tester, size: const Size(1200, 900));

    expect(find.byType(VerticalDivider), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('health-log-detail')),
        matching: find.text('Leaf spot'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('health-log-scan-s2')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('health-log-detail')),
        matching: find.text('Early blight'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('compact tap opens scan detail', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.byType(VerticalDivider), findsNothing);

    await tester.tap(find.byKey(const Key('health-log-scan-s2')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Early blight'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders at 200% text scale', (tester) async {
    await _pump(tester, size: const Size(390, 844), textScale: 2);

    expect(find.byType(HealthLogScreen), findsOneWidget);
  });

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, size: const Size(390, 844));

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
