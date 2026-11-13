import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.initialQuery});

  /// Pre-filled search query (e.g. `?q=Rice black bug` from a scan result).
  final String? initialQuery;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final TextEditingController _queryController =
      TextEditingController(text: widget.initialQuery ?? '');
  late String _query = _queryController.text;
  String? _category;
  Future<List<MerchantProduct>>? _productsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productsFuture ??= context.read<SmartCropsService>().fetchMerchantProducts();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _productsFuture = context.read<SmartCropsService>().fetchMerchantProducts());
  }

  void _submitSearch(String value) {
    setState(() => _query = value);
    context.trackEvent('shop_search', params: {'query_length': value.trim().length});
  }

  void _selectCategory(String? category) {
    setState(() => _category = category);
    context.trackEvent('shop_filter_changed', params: {'category': category ?? 'all'});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final chips = <(String?, String)>[
      (null, l10n.shopAll),
      (ShopCategory.organic, l10n.shopCategoryOrganic),
      (ShopCategory.fungicide, l10n.shopCategoryFungicide),
      (ShopCategory.fertilizer, l10n.shopCategoryFertilizer),
      (ShopCategory.pestControl, l10n.shopCategoryPestControl),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.shopSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: l10n.profileCancel,
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final (value, label) in chips)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: FilterChip(
                      label: Text(label),
                      selected: _category == value,
                      onSelected: (_) => _selectCategory(value),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MerchantProduct>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: l10n.shopCouldNotLoad,
                    onRetry: _reload,
                  );
                }
                final products = filterAndSortProducts(
                  snapshot.data ?? const [],
                  query: _query,
                  category: _category,
                );
                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.storefront_outlined,
                    message: (snapshot.data ?? const []).isEmpty ? l10n.shopEmptyAll : l10n.shopEmpty,
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1200
                        ? 3
                        : constraints.maxWidth >= 600
                            ? 2
                            : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 2.1 : 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _ProductCard(
                        product: products[index],
                        columns: columns,
                        onTap: () => context.push(
                          '/shop/products/${products[index].id}',
                          extra: products[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.columns, required this.onTap});

  final MerchantProduct product;
  final int columns;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          product.merchantName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '₱${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.shopPartnerOffer,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final icon = Container(
      width: columns == 1 ? 72 : double.infinity,
      height: columns == 1 ? 72 : 96,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _categoryIcon(product.category),
        size: 36,
        color: theme.colorScheme.primary,
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: columns == 1
              ? Row(
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Expanded(child: info),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    icon,
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: info,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('organic')) return Icons.eco_outlined;
  if (normalized.contains('fungic')) return Icons.biotech_outlined;
  if (normalized.contains('fertil')) return Icons.science_outlined;
  if (normalized.contains('pest')) return Icons.bug_report_outlined;
  return Icons.spa_outlined;
}
