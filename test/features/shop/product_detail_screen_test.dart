import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';
import 'package:smart_crops/features/shop/screens/product_detail_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _StubShopService extends SmartCropsService {
  _StubShopService({this.fetched});

  final MerchantProduct? fetched;

  @override
  Future<MerchantProduct?> fetchMerchantProductById(String productId) async =>
      fetched;
}

const _product = MerchantProduct(
  id: 'p1',
  productName: 'Copper Fungicide',
  category: 'Fungicide',
  targetDisease: 'Blight',
  price: 350,
  merchantName: 'AgriSupply PH',
  affiliateLink: 'https://example.com/p1',
);

Future<void> _pump(
  WidgetTester tester, {
  MerchantProduct? passed = _product,
  MerchantProduct? fetched,
  Size size = const Size(390, 1600),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ChangeNotifierProvider<SmartCropsService>(
      create: (_) => _StubShopService(fetched: fetched),
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
        home: ProductDetailScreen(productId: 'p1', product: passed),
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

  testWidgets('shows the product name', (tester) async {
    await _pump(tester);

    expect(find.text('Copper Fungicide'), findsOneWidget);
  });

  testWidgets('shows the price with two decimals', (tester) async {
    await _pump(tester);

    expect(find.text('₱350.00'), findsOneWidget);
  });

  testWidgets('names the merchant', (tester) async {
    await _pump(tester);

    expect(find.text('AgriSupply PH'), findsOneWidget);
  });

  testWidgets('labels the offer as a partner offer', (tester) async {
    await _pump(tester);

    expect(find.text('Partner offer'), findsOneWidget);
  });

  testWidgets('explains why it matches the diagnosis', (tester) async {
    await _pump(tester);

    expect(
      find.text('Commonly used in Philippine farms for Blight.'),
      findsOneWidget,
    );
  });

  testWidgets('Go to merchant is the primary action', (tester) async {
    await _pump(tester);

    expect(find.widgetWithText(FilledButton, 'Go to merchant'), findsOneWidget);
  });

  testWidgets('the partner disclosure is one tap away', (tester) async {
    await _pump(tester);

    expect(find.text('Partner disclosure'), findsOneWidget);
  });

  testWidgets('shows the disclosure before leaving for the merchant', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Go to merchant'));
    await tester.pumpAndSettle();

    expect(find.text('Continue to merchant'), findsOneWidget);
  });

  testWidgets('has Back and Share buttons', (tester) async {
    await _pump(tester);

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Share'), findsOneWidget);
  });

  testWidgets('loads the product by id when it was not passed in', (
    tester,
  ) async {
    await _pump(tester, passed: null, fetched: _product);

    expect(find.text('Copper Fungicide'), findsOneWidget);
  });

  testWidgets('says so when the product cannot be loaded', (tester) async {
    await _pump(tester, passed: null, fetched: null);

    expect(find.text("Couldn't load products"), findsOneWidget);
  });

  testWidgets('a failed load still has a Back button', (tester) async {
    await _pump(tester, passed: null, fetched: null);

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
        await tester.scrollUntilVisible(find.byType(FilledButton), 200);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
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
