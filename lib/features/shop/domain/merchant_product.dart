/// A partner merchant product offer (blueprint Sec 5.16, ADR 0009: never PII).
class MerchantProduct {
  const MerchantProduct({
    required this.id,
    required this.productName,
    required this.category,
    required this.targetDisease,
    required this.price,
    required this.merchantName,
    required this.affiliateLink,
    this.imageUrl,
  });

  final String id;
  final String productName;
  final String category;
  final String targetDisease;
  final double price;
  final String merchantName;
  final String affiliateLink;
  final String? imageUrl;

  factory MerchantProduct.fromJson(Map<String, dynamic> json) => MerchantProduct(
        id: json['id'] as String,
        productName: json['product_name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        targetDisease: json['target_disease'] as String? ?? '',
        price: (json['price'] ?? 0).toDouble(),
        merchantName: json['merchant_name'] as String? ?? '',
        affiliateLink: json['affiliate_link'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
      );
}

/// Shop category chip values (blueprint Sec 5.16). `null` means All.
class ShopCategory {
  const ShopCategory._();

  static const String organic = 'Organic Treatment';
  static const String fungicide = 'Fungicide';
  static const String fertilizer = 'Fertilizer';
  static const String pestControl = 'Pest Control';
}

/// Search-and-rank catalog (blueprint Sec 5.16): default sort is relevance,
/// then price. Every whitespace-separated query token must appear somewhere in
/// the product row; relevance weighs disease match, then name, then category.
///
/// A diagnosis handed over from a scan ("Early blight") is a phrase, not a
/// precise search: with [matchAnyWord] one meaningful word is enough, so the
/// "Blight" product is found. Words under three letters and bare punctuation
/// are ignored there, because they would match every product.
List<MerchantProduct> filterAndSortProducts(
  List<MerchantProduct> products, {
  String query = '',
  String? category,
  bool matchAnyWord = false,
}) {
  final normalizedCategory = category?.trim().toLowerCase();
  final words = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList();
  final tokens = matchAnyWord
      ? words
            .where(
              (word) => word.length >= 3 && RegExp(r'[a-z0-9]').hasMatch(word),
            )
            .toList()
      : words;
  if (matchAnyWord && words.isNotEmpty && tokens.isEmpty) return [];

  int relevance(MerchantProduct product) {
    if (tokens.isEmpty) return 0;
    final name = product.productName.toLowerCase();
    final disease = product.targetDisease.toLowerCase();
    final productCategory = product.category.toLowerCase();
    var score = 0;
    for (final token in tokens) {
      if (disease.contains(token)) score += 3;
      if (name.contains(token)) score += 2;
      if (productCategory.contains(token)) score += 1;
      if (product.merchantName.toLowerCase().contains(token)) score += 1;
    }
    return score;
  }

  final filtered = products.where((product) {
    if (normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        product.category.toLowerCase() != normalizedCategory) {
      return false;
    }
    if (tokens.isEmpty) return true;
    final haystack =
        '${product.productName} ${product.merchantName} ${product.targetDisease} ${product.category}'
            .toLowerCase();
    return matchAnyWord
        ? tokens.any(haystack.contains)
        : tokens.every(haystack.contains);
  }).toList();

  filtered.sort((a, b) {
    final byRelevance = relevance(b).compareTo(relevance(a));
    if (byRelevance != 0) return byRelevance;
    return a.price.compareTo(b.price);
  });
  return filtered;
}
