import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;
const _stateHeight = 280.0;

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.initialQuery});

  /// Pre-filled search query (e.g. `?q=Rice black bug` from a scan result).
  final String? initialQuery;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final TextEditingController _queryController = TextEditingController(
    text: widget.initialQuery ?? '',
  );
  late String _query = _queryController.text;
  String? _category;
  Future<List<MerchantProduct>>? _productsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productsFuture ??= context
        .read<SmartCropsService>()
        .fetchMerchantProducts();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(
      () => _productsFuture = context
          .read<SmartCropsService>()
          .fetchMerchantProducts(),
    );
  }

  void _submitSearch(String value) {
    setState(() => _query = value);
    context.trackEvent(
      'shop_search',
      params: {'query_length': value.trim().length},
    );
  }

  void _selectCategory(String? category) {
    setState(() => _category = category);
    context.trackEvent(
      'shop_filter_changed',
      params: {'category': category ?? 'all'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final categories = <(String?, String)>[
      (null, l10n.shopAll),
      (ShopCategory.organic, l10n.shopCategoryOrganic),
      (ShopCategory.fungicide, l10n.shopCategoryFungicide),
      (ShopCategory.fertilizer, l10n.shopCategoryFertilizer),
      (ShopCategory.pestControl, l10n.shopCategoryPestControl),
    ];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            _gutter,
            AppSpacing.s4,
            _gutter,
            AppSpacing.s10,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Navigator.of(context).canPop())
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s2),
                    child: IconButton(
                      tooltip: l10n.back,
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(AppLayout.touchTarget),
                        backgroundColor: AppColors.surfaceSunken,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shopTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        l10n.shopProfileSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s5),
            TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.shopSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        tooltip: l10n.profileCancel,
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (value, label) in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s2),
                      child: _CategoryPill(
                        label: label,
                        selected: _category == value,
                        onTap: () => _selectCategory(value),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s5),
            FutureBuilder<List<MerchantProduct>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: _stateHeight),
                    child: const LoadingState(),
                  );
                }
                if (snapshot.hasError) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: _stateHeight),
                    child: ErrorState(
                      message: l10n.shopCouldNotLoad,
                      onRetry: _reload,
                    ),
                  );
                }
                final products = filterAndSortProducts(
                  snapshot.data ?? const [],
                  query: _query,
                  category: _category,
                );
                if (products.isEmpty) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: _stateHeight),
                    child: EmptyState(
                      icon: Icons.storefront_outlined,
                      message: (snapshot.data ?? const []).isEmpty
                          ? l10n.shopEmptyAll
                          : l10n.shopEmpty,
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1200 - 2 * _gutter
                        ? 3
                        : constraints.maxWidth >= 600 - 2 * _gutter
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * AppSpacing.s3) /
                        columns;
                    return Wrap(
                      spacing: AppSpacing.s3,
                      runSpacing: AppSpacing.s3,
                      children: [
                        for (final product in products)
                          SizedBox(
                            width: width,
                            child: _ProductCard(
                              product: product,
                              onTap: () => context.push(
                                '/shop/products/${product.id}',
                                extra: product,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.canopy : AppColors.mist,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppLayout.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final MerchantProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestInk.withValues(alpha: 0.06),
            blurRadius: AppSpacing.s4,
            offset: const Offset(0, AppSpacing.s1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSpacing.s12,
                  height: AppSpacing.s12,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(AppRadius.card - 4),
                  ),
                  child: Icon(
                    _categoryIcon(product.category),
                    color: AppColors.canopy,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        product.merchantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (product.targetDisease.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.healing_outlined,
                              size: AppSpacing.s4,
                              color: AppColors.canopy,
                            ),
                            const SizedBox(width: AppSpacing.s1 + 2),
                            Expanded(
                              child: Text(
                                product.targetDisease,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s3),
                      Wrap(
                        spacing: AppSpacing.s2,
                        runSpacing: AppSpacing.s2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '₱${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.canopy,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.mist,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s3 - 2,
                                vertical: AppSpacing.s1,
                              ),
                              child: Text(
                                l10n.shopPartnerOffer,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
