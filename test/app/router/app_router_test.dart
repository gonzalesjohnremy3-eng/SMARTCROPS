import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/router/app_router.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/data/shared_preferences_scan_queue_store.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Already initialized
    }
  });

  testWidgets('app router shell renders the 5 navigation destinations', (tester) async {
    final router = buildAppRouter(
      initialLocation: '/home',
      enforceGuard: false,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SmartCropsService()),
          ChangeNotifierProvider(create: (_) => WeatherService()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tl'),
            Locale('ceb'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('My Crops'), findsOneWidget);
    expect(find.byTooltip('Scan Crop'), findsOneWidget);
    expect(find.byTooltip('Field Calendar'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
  });

  for (final location in ['/scan/review', '/scan/result']) {
    testWidgets('$location without its photo or diagnosis returns to Scan', (
      tester,
    ) async {
      final router = buildAppRouter(
        initialLocation: location,
        enforceGuard: false,
      );
      final service = SmartCropsService();
      final entitlement = AgriProEntitlement(fetchRow: () async => null);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: service),
            ChangeNotifierProvider(create: (_) => WeatherService()),
            ChangeNotifierProvider.value(value: entitlement),
            ChangeNotifierProvider(
              create: (_) => ScanQueueProvider(
                store: SharedPreferencesScanQueueStore(),
                service: service,
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tl'),
              Locale('ceb'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ScanCaptureScreen), findsOneWidget);
    });
  }

  testWidgets('an authenticated farmer landing on / reaches home, not an error page',
      (tester) async {
    final router = buildAppRouter(
      initialLocation: '/',
      isAuthenticated: () => true,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SmartCropsService()),
          ChangeNotifierProvider(create: (_) => WeatherService()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tl'),
            Locale('ceb'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Home'), findsOneWidget);
  });

  testWidgets('guard allows /home as soon as profile setup completes',
      (tester) async {
    final onboarding = OnboardingController(
      onboardingComplete: true,
      profileComplete: false,
    );
    final router = buildAppRouter(
      initialLocation: '/setup/profile',
      onboarding: onboarding,
      isOnboardingComplete: true,
      isProfileComplete: false,
      isAuthenticated: () => true,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: onboarding),
          ChangeNotifierProvider(create: (_) => SmartCropsService()),
          ChangeNotifierProvider(create: (_) => WeatherService()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tl'),
            Locale('ceb'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Home'), findsNothing,
        reason: 'profile setup must block the shell at first');

    onboarding.completeProfile();
    router.go('/home');
    await tester.pumpAndSettle();

    expect(find.byTooltip('Home'), findsOneWidget,
        reason: 'the guard must use live completion state, not startup state');
  });

  testWidgets(
    'a reload at a location without a route lands on the hub instead of the not-found screen',
    (tester) async {
      final router = buildAppRouter(
        initialLocation: '/broadcast/new',
        isAuthenticated: () => true,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SmartCropsService()),
            ChangeNotifierProvider(create: (_) => WeatherService()),
            ChangeNotifierProvider(create: (_) => AgriProEntitlement()),
            ChangeNotifierProvider.value(
              value: LocaleProvider(
                preference: LanguagePreference(
                  store: SharedPreferencesLanguageStore(),
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tl'),
              Locale('ceb'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Page Not Found'), findsNothing);
      expect(find.textContaining('GoException'), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/profile');
    },
  );
}
