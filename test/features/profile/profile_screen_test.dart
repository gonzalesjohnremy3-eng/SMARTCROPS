import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/features/profile/screens/profile_screen.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _MemoryStore extends LanguageStore {
  @override
  Future<String?> load() async => 'en';

  @override
  Future<void> save(String languageCode) async {}
}

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

final _maria = UserProfile(
  id: 'u',
  fullName: 'Maria Santos',
  email: 'maria@example.com',
  farmName: 'Santos Farm',
  location: 'Nueva Ecija',
);

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  UserProfile? profile,
  List<CropItem> crops = const [],
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(
    loader: _StubLoader(
      FarmSnapshot(
        availableCrops: crops,
        userCrops: crops,
        scanHistory: const [],
        notifications: const [],
        calendarEvents: const [],
        fetchedAt: DateTime(2026, 1, 1),
        profile: profile,
      ),
    ),
  );
  await service.initializeUserData();
  final entitlement = AgriProEntitlement(fetchRow: () async => null);
  await entitlement.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: service),
        ChangeNotifierProvider.value(value: entitlement),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(
            preference: LanguagePreference(store: _MemoryStore()),
          ),
        ),
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
        home: const ProfileScreen(),
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

  testWidgets('shows two grouped columns at expanded width', (tester) async {
    await _pump(tester, size: const Size(1200, 900));

    expect(find.byKey(const Key('profile-wide-two-column')), findsOneWidget);
    expect(find.byKey(const Key('profile-farm-column')), findsOneWidget);
    expect(find.byKey(const Key('profile-settings-column')), findsOneWidget);
  });

  testWidgets('keeps one grouped list at compact width', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.byKey(const Key('profile-wide-two-column')), findsNothing);
  });

  group('identity', () {
    testWidgets('names the Farmer', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('Maria Santos'), findsOneWidget);
    });

    testWidgets('shows the email', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('maria@example.com'), findsOneWidget);
    });

    testWidgets('uses the first initial as the avatar', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('M'), findsOneWidget);
    });
  });

  group('farm details', () {
    testWidgets('shows the farm name, not the Farmer\'s name', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('Santos Farm'), findsOneWidget);
    });

    testWidgets('shows the location', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('Nueva Ecija'), findsOneWidget);
    });

    testWidgets('a missing phone number shows a dash, not a blank', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('editing reveals the four fields', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await tester.tap(find.byKey(const Key('profile_edit')));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('editing offers a clearly labelled save', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await tester.tap(find.byKey(const Key('profile_edit')));
      await tester.pumpAndSettle();

      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  testWidgets('lists the Main Crops', (tester) async {
    await _pump(
      tester,
      size: const Size(390, 1600),
      profile: _maria,
      crops: [CropItem(id: 'r', cropName: 'Rice', optimalConditions: {})],
    );

    expect(find.text('Rice'), findsOneWidget);
  });

  testWidgets('offers all three languages', (tester) async {
    await _pump(tester, size: const Size(390, 1600), profile: _maria);

    expect(find.text('Cebuano'), findsOneWidget);
  });

  testWidgets('keeps sign out reachable', (tester) async {
    await _pump(tester, size: const Size(390, 1600), profile: _maria);

    expect(find.text('Sign Out'), findsOneWidget);
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
          profile: _maria,
          crops: [
            CropItem(id: 'r', cropName: 'Rice', optimalConditions: {}),
            CropItem(id: 't', cropName: 'Tomato', optimalConditions: {}),
          ],
          locale: locale,
          textScale: 2,
        );
        await tester.tap(find.byKey(const Key('profile_edit')));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
