import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/health_log/domain/health_log_statistics.dart';
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

ScanHistoryItem _scan(
  String id,
  String disease, {
  DateTime? at,
  String source = 'ai',
}) => ScanHistoryItem(
  id: id,
  userId: 'u',
  imageUrl: 'https://example.com/$id.jpg',
  diseaseDetected: disease,
  confidenceScore: 90,
  commonCrop: 'Tomato',
  recommendedActions: const ['Keep monitoring'],
  scannedAt: at ?? DateTime(2026, 1, 1),
  source: source,
);

final _twoScans = [_scan('s1', 'Leaf spot'), _scan('s2', 'Early blight')];

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  List<ScanHistoryItem>? scans,
  double textScale = 1,
  String locale = 'en',
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(
    loader: _StubLoader(
      FarmSnapshot(
        availableCrops: const [],
        userCrops: const [],
        scanHistory: scans ?? _twoScans,
        notifications: const [],
        calendarEvents: const [],
        fetchedAt: DateTime(2026, 1, 1),
      ),
    ),
  );
  await service.initializeUserData();

  await tester.pumpWidget(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: service)],
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

  testWidgets('the detail leads with what to do now', (tester) async {
    await _pump(tester, size: const Size(390, 844));
    await tester.tap(find.byKey(const Key('health-log-scan-s2')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Keep monitoring'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('summarises the season with a labelled count', (tester) async {
    await _pump(tester, size: const Size(390, 1600));

    expect(find.text('Need attention'), findsOneWidget);
  });

  testWidgets('each scan names its crop', (tester) async {
    await _pump(tester, size: const Size(390, 1600));

    expect(find.text('Tomato'), findsNWidgets(2));
  });

  testWidgets('each scan carries a localized severity', (tester) async {
    await _pump(tester, size: const Size(390, 1600));

    expect(find.text('At Risk'), findsOneWidget);
  });

  testWidgets('formats scan dates for the locale', (tester) async {
    await _pump(tester, size: const Size(390, 1600));

    expect(find.textContaining('Jan 1'), findsNWidgets(2));
  });

  testWidgets('groups scans under a month heading', (tester) async {
    await _pump(
      tester,
      size: const Size(390, 1600),
      scans: [
        _scan('a', 'Leaf spot', at: DateTime(2026, 1, 3)),
        _scan('b', 'Early blight', at: DateTime(2025, 12, 5)),
      ],
    );

    expect(find.text('December 2025'), findsOneWidget);
  });

  testWidgets('a demo scan is labelled and not counted', (tester) async {
    await _pump(
      tester,
      size: const Size(390, 1600),
      scans: [_scan('d', 'Early blight', source: demoScanSource)],
    );

    expect(find.text('Demo diagnosis'), findsOneWidget);
  });

  testWidgets('empty state explains and offers a scan', (tester) async {
    await _pump(tester, size: const Size(390, 844), scans: const []);

    expect(find.text('Scan a Crop'), findsOneWidget);
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
          textScale: 2,
          locale: locale,
          scans: [
            ..._twoScans,
            _scan('d', 'Early blight', source: demoScanSource),
          ],
        );
        await tester.scrollUntilVisible(
          find.byKey(const Key('health-log-scan-s2')),
          200,
        );
        await tester.tap(find.byKey(const Key('health-log-scan-s2')));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }

  testWidgets('has a Back button, so Back does not exit the app', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.byTooltip('Back'), findsOneWidget);
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
