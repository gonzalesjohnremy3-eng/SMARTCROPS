import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/app/router/app_router.dart';
import 'package:smart_crops/features/auth/screens/auth_screen.dart';
import 'package:smart_crops/features/onboarding/screens/onboarding_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InMemoryLanguageStore extends LanguageStore {
  InMemoryLanguageStore(this._value);
  String _value;
  @override
  Future<String?> load() async => _value;
  @override
  Future<void> save(String languageCode) async => _value = languageCode;
}

Widget _wrap(
  Widget child, {
  String locale = 'en',
  double textScale = 1.0,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WeatherService()),
      ChangeNotifierProvider(create: (_) => SmartCropsService()),
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(
          preference: LanguagePreference(store: InMemoryLanguageStore(locale)),
        ),
      ),
    ],
    child: Consumer<LocaleProvider>(
      child: child,
      builder: (context, localeProvider, Widget? screen) => MaterialApp(
        locale: Locale(localeProvider.currentLocale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          CebMaterialLocalizationsDelegate(),
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CebCupertinoLocalizationsDelegate(),
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: widget!,
        ),
        home: screen,
      ),
    ),
  );
}

Widget _wrapRouter(GoRouter router, {double textScale = 1.0}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WeatherService()),
      ChangeNotifierProvider(create: (_) => SmartCropsService()),
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(
          preference: LanguagePreference(store: InMemoryLanguageStore('en')),
        ),
      ),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        CebMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        CebCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: widget!,
      ),
      routerConfig: router,
    ),
  );
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
      // Already initialized
    }
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    for (final textScale in [1.0, 1.5, 2.0]) {
      testWidgets(
        'onboarding pages render without overflow at ${textScale}x text scale in $locale',
        (tester) async {
          tester.view.physicalSize = const Size(375 * 2, 667 * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          final errors = <FlutterErrorDetails>[];
          final original = FlutterError.onError;
          FlutterError.onError = errors.add;
          try {
            await tester.pumpWidget(
              _wrap(const OnboardingScreen(), locale: locale, textScale: textScale),
            );
            await tester.pumpAndSettle();
            for (var page = 0; page < 2; page++) {
              await tester.drag(find.byType(PageView), const Offset(-800, 0));
              await tester.pumpAndSettle();
            }
          } finally {
            FlutterError.onError = original;
          }

          expect(errors, isEmpty);
        },
      );
    }
  }

  testWidgets('switching to Cebuano applies immediately and the sheet closes', (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 667 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      await tester.tap(
        find.descendant(of: find.byType(ListTile), matching: find.text('Cebuano')).first,
      );
      await tester.pump();
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = original;
    }

    expect(errors, isEmpty);
    expect(find.text('Cebuano'), findsOneWidget);
    expect(find.text('Sunod'), findsOneWidget);
  });

  testWidgets('switching back from Cebuano to English works', (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 667 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(_wrap(const OnboardingScreen(), locale: 'ceb'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      await tester.tap(
        find.descendant(of: find.byType(ListTile), matching: find.text('English')).first,
      );
      await tester.pump();
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = original;
    }

    expect(errors, isEmpty);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Skip navigates to the auth route', (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 667 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final router = buildAppRouter(
      initialLocation: '/onboarding',
      isOnboardingComplete: false,
      isProfileComplete: false,
    );
    await tester.pumpWidget(_wrapRouter(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_complete'), isTrue);
  });

  testWidgets('Get Started on the last page navigates to the auth route', (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 667 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final router = buildAppRouter(
      initialLocation: '/onboarding',
      isOnboardingComplete: false,
      isProfileComplete: false,
    );
    await tester.pumpWidget(_wrapRouter(router));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
