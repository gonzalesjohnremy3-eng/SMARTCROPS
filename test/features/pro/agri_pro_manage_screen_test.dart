import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/screens/agri_pro_manage_screen.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class _FakeBilling implements BillingRepository {
  @override
  Future<BillingOutcome> purchase(AgriProPlanId plan) async =>
      const BillingUnavailable();

  @override
  Future<BillingOutcome> restore() async => const BillingUnavailable();
}

const _proRow = {'tier': 'premium', 'expires_at': '2026-12-31T12:00:00Z'};

Future<void> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? row = _proRow,
  Size size = const Size(390, 1600),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final entitlement = AgriProEntitlement(fetchRow: () async => row);
  await entitlement.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: entitlement),
        Provider<BillingRepository>.value(value: _FakeBilling()),
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
        home: const AgriProManageScreen(),
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

  group('Pro Farmer', () {
    testWidgets('sees their plan is active', (tester) async {
      await _pump(tester);

      expect(find.text('Agri Pro — Active'), findsOneWidget);
    });

    testWidgets('sees the renewal date in the locale\'s format', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.textContaining('Dec 31'), findsOneWidget);
    });

    testWidgets('sees the billing row labelled in English, not Tagalog', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Billing'), findsOneWidget);
    });

    testWidgets('is told how to cancel', (tester) async {
      await _pump(tester);

      expect(
        find.textContaining('To cancel, open Google Play'),
        findsOneWidget,
      );
    });

    testWidgets('can restore a purchase', (tester) async {
      await _pump(tester);

      expect(find.text('Restore purchase'), findsOneWidget);
    });

    testWidgets('is not pushed to upgrade', (tester) async {
      await _pump(tester);

      expect(find.text('See Agri Pro plans'), findsNothing);
    });
  });

  group('Free Farmer', () {
    testWidgets('is told they are on the Free plan', (tester) async {
      await _pump(tester, row: null);

      expect(find.text("You're on the Free plan"), findsOneWidget);
    });

    testWidgets('has See Agri Pro plans as the primary action', (tester) async {
      await _pump(tester, row: null);

      expect(
        find.widgetWithText(FilledButton, 'See Agri Pro plans'),
        findsOneWidget,
      );
    });

    testWidgets('is not offered a restore they cannot use', (tester) async {
      await _pump(tester, row: null);

      expect(find.text('Restore purchase'), findsNothing);
    });
  });

  testWidgets('has a Back button', (tester) async {
    await _pump(tester);

    expect(find.byTooltip('Back'), findsOneWidget);
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
    await _pump(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
