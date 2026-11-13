import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';

MerchantProduct _product({
  required String name,
  required String category,
  required String disease,
  required double price,
  String merchant = 'AgriSupply',
}) =>
    MerchantProduct(
      id: name,
      productName: name,
      category: category,
      targetDisease: disease,
      price: price,
      merchantName: merchant,
      affiliateLink: 'https://example.com/$name',
    );

void main() {
  group('filterAndSortProducts', () {
    final catalog = [
      _product(name: 'Copper Fungicide', category: 'Fungicide', disease: 'Blight', price: 350),
      _product(name: 'Neem Oil', category: 'Organic Treatment', disease: 'Leaf Spot', price: 280),
      _product(name: 'NPK 16-16-16', category: 'Fertilizer', disease: 'Nutrient Deficiency', price: 450),
      _product(name: 'Bio-Pesticide B. subtilis', category: 'Pest Control', disease: 'Powdery Mildew', price: 320),
    ];

    test('empty query returns every product sorted by price', () {
      final result = filterAndSortProducts(catalog);
      expect(result.map((p) => p.productName), ['Neem Oil', 'Bio-Pesticide B. subtilis', 'Copper Fungicide', 'NPK 16-16-16']);
    });

    test('category filter narrows the catalog', () {
      final result = filterAndSortProducts(catalog, category: 'Organic Treatment');
      expect(result, hasLength(1));
      expect(result.single.productName, 'Neem Oil');
    });

    test('query matches on disease with relevance before price', () {
      final result = filterAndSortProducts(catalog, query: 'blight');
      expect(result.single.productName, 'Copper Fungicide');
    });

    test('query tokens all must match', () {
      final result = filterAndSortProducts(catalog, query: 'copper fungicide');
      expect(result.single.productName, 'Copper Fungicide');
      expect(filterAndSortProducts(catalog, query: 'copper missing'), isEmpty);
    });

    test('query matches merchant name', () {
      final result = filterAndSortProducts(catalog, query: 'agrisupply');
      expect(result, hasLength(4));
    });

    test('no match returns empty list', () {
      expect(filterAndSortProducts(catalog, query: 'zzz'), isEmpty);
    });

    test('disease match ranks above name match for relevance then price', () {
      final ranked = filterAndSortProducts([
        _product(name: 'Zzz Blight Mix', category: 'Fungicide', disease: 'Leaf Spot', price: 100),
        _product(name: 'Balanced Mix', category: 'Fungicide', disease: 'Blight', price: 999),
      ], query: 'blight');
      expect(ranked.first.productName, 'Balanced Mix');
    });
  });
}
