import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Widget buildShop(List<MerchantProduct> products) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SmartCropsService>(create: (_) => _StubShopService(products)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        home: const ShopScreen(),
      ),
    );
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
