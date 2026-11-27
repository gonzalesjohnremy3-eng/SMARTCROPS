import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/features/auth/screens/auth_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

Future<void> _pump(WidgetTester tester, {required Size size}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SmartCropsService())],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        home: const AuthScreen(),
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

  testWidgets('wide auth shows the chosen trust panel beside the form', (
    tester,
  ) async {
    await _pump(tester, size: const Size(1200, 900));

    expect(find.byKey(const Key('auth-trust-panel')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('auth-trust-panel')),
        matching: find.text('Welcome to your field office.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('auth-trust-panel')),
        matching: find.text('Your farm data stays private.'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('auth-form-card')), findsOneWidget);
  });

  testWidgets('compact auth keeps the phone-first form only', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.byKey(const Key('auth-trust-panel')), findsNothing);
    expect(find.byKey(const Key('auth-form-card')), findsOneWidget);
  });

  testWidgets('compact auth opens on the phone number field', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.text('Mobile Number (+63...)'), findsOneWidget);
  });

  testWidgets('phone-first auth hides the email form until asked', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.text('Email Address'), findsNothing);
  });

  testWidgets('choosing email instead reveals the email form', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    await tester.tap(find.text('Use email instead'));
    await tester.pumpAndSettle();

    expect(find.text('Email Address'), findsOneWidget);
  });

  testWidgets('email form offers a way back to phone', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    await tester.tap(find.text('Use email instead'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use phone instead'));
    await tester.pumpAndSettle();

    expect(find.text('Mobile Number (+63...)'), findsOneWidget);
  });

  testWidgets('phone-first auth keeps Google and Facebook sign-in', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
