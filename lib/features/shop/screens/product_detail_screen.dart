import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId, this.product});

  final String productId;
  final MerchantProduct? product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  MerchantProduct? _product;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    if (_product == null) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final product = await context.read<SmartCropsService>().fetchMerchantProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openMerchant(MerchantProduct product) async {
    context.trackEvent('partner_disclosure_viewed');
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final sheetL10n = AppLocalizations.of(sheetContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                sheetL10n.shopPartnerDisclosureTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                sheetL10n.shopPartnerDisclosureBody,
                style: Theme.of(sheetContext).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: Text(AppLocalizations.of(sheetContext).profileCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: Text(sheetL10n.shopContinueToMerchant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (proceed != true) return;
    if (!mounted) return;
    context.trackEvent('partner_link_opened');
    final uri = Uri.tryParse(product.affiliateLink);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shopTitle)),
        body: const LoadingState(),
      );
    }
    final product = _product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shopTitle)),
        body: ErrorState(message: l10n.shopCouldNotLoad, onRetry: _load),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _categoryIcon(product.category),
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.productName,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '₱${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    l10n.shopPartnerOffer,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.merchantName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shopWhyMatchesHeader,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.shopCommonlyFor(product.targetDisease),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.shopSafetyCopy,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openMerchant(product),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.shopGoToMerchant),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              context.trackEvent('partner_disclosure_viewed');
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(AppLocalizations.of(dialogContext).shopPartnerDisclosureTitle),
                  content: Text(AppLocalizations.of(dialogContext).shopPartnerDisclosureBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(AppLocalizations.of(dialogContext).profileCancel),
                    ),
                  ],
                ),
              );
            },
            child: Text(l10n.shopPartnerDisclosureTitle),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Share.share(
              '${product.productName} — ₱${product.price.toStringAsFixed(2)}\n${product.affiliateLink}',
              subject: product.productName,
            ),
            icon: const Icon(Icons.share_outlined),
            label: Text(l10n.scanResultShare),
          ),
        ],
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
