import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';
import 'package:smart_crops/features/shop/screens/shop_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _StubShopService extends SmartCropsService {
  _StubShopService(this.products);

  final List<MerchantProduct> products;

  @override
  Future<List<MerchantProduct>> fetchMerchantProducts() async => products;
}

MerchantProduct _product({
  required String name,
  required String category,
  required String disease,
  required double price,
}) =>
    MerchantProduct(
      id: name,
      productName: name,
      category: category,
      targetDisease: disease,
      price: price,
      merchantName: 'AgriSupply PH',
      affiliateLink: 'https://example.com/$name',
    );

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

  Widget buildShop(
    List<MerchantProduct> products, {
    String locale = 'en',
    double textScale = 1,
    String? initialQuery,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SmartCropsService>(create: (_) => _StubShopService(products)),
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
        home: ShopScreen(initialQuery: initialQuery),
      ),
    );
  }

  final catalog = [
    _product(name: 'Copper Fungicide', category: 'Fungicide', disease: 'Blight', price: 350),
    _product(name: 'Neem Oil Organic Spray Concentrate', category: 'Organic Treatment', disease: 'Leaf Spot', price: 280),
    _product(name: 'Balanced NPK Fertilizer', category: 'Fertilizer', disease: 'Nutrient deficiency', price: 520.5),
  ];

  testWidgets('a diagnosis from a scan finds the product for its key word', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog, initialQuery: 'Early blight'));
    await tester.pumpAndSettle();

    expect(find.text('Copper Fungicide'), findsOneWidget);
  });

  testWidgets('a diagnosis from a scan hides products that do not fit it', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog, initialQuery: 'Early blight'));
    await tester.pumpAndSettle();

    expect(find.text('Balanced NPK Fertilizer'), findsNothing);
  });

  testWidgets('once the Farmer edits the search it matches every word again', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog, initialQuery: 'Early blight'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Early blight x');
    await tester.pumpAndSettle();

    expect(find.text('Copper Fungicide'), findsNothing);
  });

  testWidgets('says what the shop is for', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog));
    await tester.pumpAndSettle();

    expect(find.text('Partner products matched to your diagnosis'), findsOneWidget);
  });

  testWidgets('shows the price with two decimals', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog));
    await tester.pumpAndSettle();

    expect(find.text('₱520.50'), findsOneWidget);
  });

  testWidgets('shows what each product treats', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog));
    await tester.pumpAndSettle();

    expect(find.text('Blight'), findsOneWidget);
  });

  testWidgets('a search with no match says so, not that the catalog is empty', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(catalog));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(
      find.text('No matching products for this diagnosis. Your care plan still works without them.'),
      findsOneWidget,
    );
  });

  testWidgets('lays products out in columns on a tablet without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(buildShop(catalog));
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = original;
    }

    expect(errors, isEmpty);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await tester.pumpWidget(
          buildShop(catalog, locale: locale, textScale: 2),
        );
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }

  testWidgets('renders product cards from the catalog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop([
      _product(name: 'Copper Fungicide', category: 'Fungicide', disease: 'Blight', price: 350),
      _product(name: 'Neem Oil', category: 'Organic Treatment', disease: 'Leaf Spot', price: 280),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Copper Fungicide'), findsOneWidget);
    expect(find.text('Neem Oil'), findsOneWidget);
    expect(find.text('Partner offer'), findsNWidgets(2));
  });

  testWidgets('category chip filters the grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop([
      _product(name: 'Copper Fungicide', category: 'Fungicide', disease: 'Blight', price: 350),
      _product(name: 'Neem Oil', category: 'Organic Treatment', disease: 'Leaf Spot', price: 280),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Organic'));
    await tester.pumpAndSettle();

    expect(find.text('Neem Oil'), findsOneWidget);
    expect(find.text('Copper Fungicide'), findsNothing);
  });

  testWidgets('shows the honest empty state when the catalog is empty', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop(const []));
    await tester.pumpAndSettle();

    expect(find.text('Products will appear here as partners are added.'), findsOneWidget);
  });

  testWidgets('search query filters and ranks products', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildShop([
      _product(name: 'Copper Fungicide', category: 'Fungicide', disease: 'Blight', price: 350),
      _product(name: 'Neem Oil', category: 'Organic Treatment', disease: 'Leaf Spot', price: 280),
    ]));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'neem');
    await tester.pumpAndSettle();

    expect(find.text('Neem Oil'), findsOneWidget);
    expect(find.text('Copper Fungicide'), findsNothing);
  });
}
