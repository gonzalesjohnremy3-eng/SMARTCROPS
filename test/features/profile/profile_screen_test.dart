import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/features/profile/screens/profile_screen.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _MemoryStore extends LanguageStore {
  @override
  Future<String?> load() async => 'en';

  @override
  Future<void> save(String languageCode) async {}
}

Future<void> _pump(WidgetTester tester, {required Size size}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final entitlement = AgriProEntitlement(fetchRow: () async => null);
  await entitlement.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SmartCropsService()),
        ChangeNotifierProvider.value(value: entitlement),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(
            preference: LanguagePreference(store: _MemoryStore()),
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
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
}
