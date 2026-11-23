import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/advisories/screens/advisories_screen.dart';
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

AppNotification _notification(String id, String title, {String? severity}) =>
    AppNotification(
      id: id,
      userId: 'u',
      title: title,
      message: 'Inspect your rice today.',
      isRead: false,
      createdAt: DateTime(2026, 11, 22),
      severity: severity,
    );

Future<void> _pump(WidgetTester tester, {required bool critical}) async {
  final snapshot = FarmSnapshot(
    availableCrops: const [],
    userCrops: const [],
    scanHistory: const [],
    notifications: [
      _notification(
        'n1',
        'Blight outbreak in San Isidro',
        severity: critical ? 'critical' : null,
      ),
    ],
    calendarEvents: const [],
    fetchedAt: DateTime(2026, 11, 22),
  );
  final service = SmartCropsService(loader: _StubLoader(snapshot));
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
        home: const AdvisoriesScreen(),
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

  testWidgets('pins a real critical advisory above the inbox', (tester) async {
    await _pump(tester, critical: true);

    expect(find.byKey(const Key('critical-advisory-banner')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('critical-advisory-banner')),
        matching: find.text('Blight outbreak in San Isidro'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('does not pin an ordinary advisory as critical', (tester) async {
    await _pump(tester, critical: false);

    expect(find.byKey(const Key('critical-advisory-banner')), findsNothing);
  });
}
