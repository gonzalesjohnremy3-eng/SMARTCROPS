import 'package:flutter_test/flutter_test.dart';

class MarketplaceProduct {
  final String id;
  final String productName;
  final String category;
  final String targetDisease;
  final double price;
  final String merchantName;
  final String affiliateLink;

  MarketplaceProduct({
    required this.id,
    required this.productName,
    required this.category,
    required this.targetDisease,
    required this.price,
    required this.merchantName,
    required this.affiliateLink,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['id'],
      productName: json['product_name'],
      category: json['category'],
      targetDisease: json['target_disease'],
      price: (json['price'] ?? 0.0).toDouble(),
      merchantName: json['merchant_name'],
      affiliateLink: json['affiliate_link'],
    );
  }
}

class FreemiumQuotaManager {
  static const int maxFreeScans = 5;

  bool canPerformScan(String tier, int scansUsed) {
    if (tier == 'premium') return true;
    return scansUsed < maxFreeScans;
  }
}

List<MarketplaceProduct> matchProductsForDisease(String disease, List<MarketplaceProduct> catalog) {
  return catalog.where((p) => p.targetDisease.toLowerCase().contains(disease.toLowerCase()) || disease.toLowerCase().contains(p.targetDisease.toLowerCase())).toList();
}

void main() {
  group('Monetization & Marketplace TDD - Seams: Quota & Product Matching', () {
    test('free tier user blocked after 5 scans, premium allowed', () {
      final quotaManager = FreemiumQuotaManager();

      expect(quotaManager.canPerformScan('free', 4), true);
      expect(quotaManager.canPerformScan('free', 5), false);
      expect(quotaManager.canPerformScan('premium', 50), true);
    });

    test('matches relevant affiliate products for detected disease', () {
      final catalog = [
        MarketplaceProduct(id: '1', productName: 'Organic Neem Oil', category: 'Fungicide', targetDisease: 'Leaf Spot', price: 250.0, merchantName: 'AgriSupply', affiliateLink: 'https://example.com/neem'),
        MarketplaceProduct(id: '2', productName: 'Copper Fungicide', category: 'Fungicide', targetDisease: 'Blight', price: 350.0, merchantName: 'GreenFarm', affiliateLink: 'https://example.com/copper'),
      ];

      final matches = matchProductsForDisease('Leaf Spot', catalog);
      expect(matches.length, 1);
      expect(matches[0].productName, 'Organic Neem Oil');
    });
  });
}
