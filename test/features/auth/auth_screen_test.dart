import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/features/auth/screens/auth_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _FakePhoneAuthService extends SmartCropsService {
  _FakePhoneAuthService({this.verifyError});

  final Object? verifyError;
  String? sentTo;
  (String, String)? verified;

  @override
  Future<void> signInWithPhoneOtp(String phoneNumber) async {
    sentTo = phoneNumber;
  }

  @override
  Future<void> verifyPhoneOtp(String phoneNumber, String token) async {
    verified = (phoneNumber, token);
    if (verifyError != null) throw verifyError!;
  }
}

const _compact = Size(390, 844);
const _wrongCode = AuthApiException(
  'Token has expired or is invalid',
  code: 'otp_expired',
);

Future<void> _pump(
  WidgetTester tester, {
  Size size = _compact,
  SmartCropsService? service,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ChangeNotifierProvider<SmartCropsService>(
      create: (_) => service ?? SmartCropsService(),
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

// The resend countdown keeps a timer running, so step with fixed pumps.
Future<void> _step(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(AppMotion.slow);
}

Future<void> _sendCode(
  WidgetTester tester, {
  String phone = '09171234567',
}) async {
  await tester.enterText(find.byKey(const Key('auth-phone-field')), phone);
  await tester.tap(find.text('Continue'));
  await _step(tester);
}

// Alternatives sit below the fold on a phone, as the Farmer would scroll to them.
Future<void> _scrollAndTap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
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

  group('layout', () {
    testWidgets('wide auth shows the trust panel beside the form', (
      tester,
    ) async {
      await _pump(tester, size: const Size(1200, 900));

      expect(
        find.descendant(
          of: find.byKey(const Key('auth-trust-panel')),
          matching: find.text('Your farm data stays private.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wide auth welcomes the Farmer to their field office', (
      tester,
    ) async {
      await _pump(tester, size: const Size(1200, 900));

      expect(find.text('Welcome to your field office.'), findsOneWidget);
    });

    testWidgets('compact auth has no separate trust panel', (tester) async {
      await _pump(tester);

      expect(find.byKey(const Key('auth-trust-panel')), findsNothing);
    });

    testWidgets('the hero states what Smart Crops does', (tester) async {
      await _pump(tester);

      expect(find.text('Know what your crops need.'), findsOneWidget);
    });

    testWidgets('brand lockup keeps the byline off the wordmark line', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('by Agri Lynk'), findsOneWidget);
    });
  });

  group('phone step', () {
    testWidgets('opens on the mobile number field', (tester) async {
      await _pump(tester);

      expect(find.text('Mobile number'), findsOneWidget);
    });

    testWidgets('shows no +63 prefix', (tester) async {
      await _pump(tester);

      expect(find.textContaining('+63'), findsNothing);
    });

    testWidgets('sends an 09 number to Supabase in +63 form', (tester) async {
      final service = _FakePhoneAuthService();
      await _pump(tester, service: service);

      await _sendCode(tester);

      expect(service.sentTo, '+639171234567');
    });

    testWidgets('explains a number that is not a mobile number', (
      tester,
    ) async {
      await _pump(tester, service: _FakePhoneAuthService());

      await _sendCode(tester, phone: '0281234');

      expect(
        find.text('Enter an 11-digit mobile number that starts with 09.'),
        findsOneWidget,
      );
    });

    testWidgets('does not send a code for an invalid number', (tester) async {
      final service = _FakePhoneAuthService();
      await _pump(tester, service: service);

      await _sendCode(tester, phone: '0281234');

      expect(service.sentTo, isNull);
    });
  });

  group('code step', () {
    testWidgets('shows six digit boxes once the code is sent', (tester) async {
      await _pump(tester, service: _FakePhoneAuthService());

      await _sendCode(tester);

      expect(find.byKey(const Key('otp-digit-box')), findsNWidgets(6));
    });

    testWidgets('names the masked number the code went to', (tester) async {
      await _pump(tester, service: _FakePhoneAuthService());

      await _sendCode(tester);

      expect(find.text('Sent by SMS to 0917 ••• 4567'), findsOneWidget);
    });

    testWidgets('locks resend behind a 60-second countdown', (tester) async {
      await _pump(tester, service: _FakePhoneAuthService());

      await _sendCode(tester);

      expect(find.text('Resend code in 60s'), findsOneWidget);
    });

    testWidgets('unlocks resend when the countdown ends', (tester) async {
      await _pump(tester, service: _FakePhoneAuthService());

      await _sendCode(tester);
      await tester.pump(const Duration(seconds: 61));

      expect(find.text('Resend code'), findsOneWidget);
    });

    testWidgets('verifies six digits against the normalized number', (
      tester,
    ) async {
      final service = _FakePhoneAuthService(verifyError: _wrongCode);
      await _pump(tester, service: service);

      await _sendCode(tester);
      await tester.enterText(find.byKey(const Key('auth-otp-field')), '482913');
      await _step(tester);

      expect(service.verified, ('+639171234567', '482913'));
    });

    testWidgets('a wrong code reads in plain words', (tester) async {
      await _pump(
        tester,
        service: _FakePhoneAuthService(verifyError: _wrongCode),
      );

      await _sendCode(tester);
      await tester.enterText(find.byKey(const Key('auth-otp-field')), '482913');
      await _step(tester);

      expect(
        find.text(
          'That code is wrong or has expired. Check the SMS or resend a new one.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Change number returns to the phone step', (tester) async {
      await _pump(tester, service: _FakePhoneAuthService());

      await _sendCode(tester);
      await tester.tap(find.text('Change number'));
      await _step(tester);

      expect(find.text('Mobile number'), findsOneWidget);
    });
  });

  group('other ways to sign in', () {
    testWidgets('phone-first auth hides the email form until asked', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Email Address'), findsNothing);
    });

    testWidgets('choosing email reveals the email form', (tester) async {
      await _pump(tester);

      await _scrollAndTap(tester, 'Use email instead');

      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('the email form offers a way back to phone', (tester) async {
      await _pump(tester);

      await _scrollAndTap(tester, 'Use email instead');
      await _scrollAndTap(tester, 'Use phone instead');

      expect(find.text('Mobile number'), findsOneWidget);
    });

    testWidgets('Google and Facebook carry their brand logos', (tester) async {
      await _pump(tester);

      expect(find.byType(SvgPicture), findsNWidgets(2));
    });

    testWidgets('Google sign-in stays available', (tester) async {
      await _pump(tester);

      expect(find.byTooltip('Continue with Google'), findsOneWidget);
    });
  });
}
