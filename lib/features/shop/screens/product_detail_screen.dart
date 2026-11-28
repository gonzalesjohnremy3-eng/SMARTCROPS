import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/feedback_states.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/scrimmed_image.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;

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
      final product = await context
          .read<SmartCropsService>()
          .fetchMerchantProductById(widget.productId);
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
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.paper,
      builder: (sheetContext) {
        final sheetL10n = AppLocalizations.of(sheetContext);
        final sheetTheme = Theme.of(sheetContext);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _gutter,
              AppSpacing.s2,
              _gutter,
              AppSpacing.s5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  sheetL10n.shopPartnerDisclosureTitle,
                  style: sheetTheme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Fraunces',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  sheetL10n.shopPartnerDisclosureBody,
                  style: sheetTheme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s5),
                PillButton(
                  label: sheetL10n.shopContinueToMerchant,
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                ),
                const SizedBox(height: AppSpacing.s2),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size.fromHeight(AppLayout.touchTarget),
                  ),
                  child: Text(sheetL10n.profileCancel),
                ),
              ],
            ),
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
  }

  void _showDisclosure() {
    context.trackEvent('partner_disclosure_viewed');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocalizations.of(dialogContext).shopPartnerDisclosureTitle,
        ),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(dialogContext).shopPartnerDisclosureBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext).profileCancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final product = _product;

    if (_isLoading || product == null) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _gutter,
                  AppSpacing.s4,
                  _gutter,
                  0,
                ),
                child: _RoundButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: l10n.back,
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const LoadingState()
                    : ErrorState(
                        message: l10n.shopCouldNotLoad,
                        onRetry: _load,
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.maxWidths['reading']!,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                _gutter,
                AppSpacing.s4,
                _gutter,
                AppSpacing.s10,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: l10n.back,
                      onPressed: () => context.pop(),
                    ),
                    _RoundButton(
                      icon: Icons.share_outlined,
                      tooltip: l10n.scanResultShare,
                      onPressed: () => Share.share(
                        '${product.productName} — ₱${product.price.toStringAsFixed(2)}\n${product.affiliateLink}',
                        subject: product.productName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.hero),
                  child: ScrimmedImage(
                    imagePath: 'assets/images/overlays/product.webp',
                    scrim: AppColors.forestInk.withValues(alpha: 0.62),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: AppLayout.touchTarget,
                            height: AppLayout.touchTarget,
                            decoration: BoxDecoration(
                              color: AppColors.textInverse.withValues(
                                alpha: 0.16,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _categoryIcon(product.category),
                              color: AppColors.textInverse,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Text(
                            product.productName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Fraunces',
                              color: AppColors.textInverse,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s1),
                          Text(
                            product.merchantName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textInverse.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s5),
                // Wrap keeps the price and label on one line when they fit and
                // stacks them at large text instead of overflowing.
                Wrap(
                  spacing: AppSpacing.s3,
                  runSpacing: AppSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '₱${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Fraunces',
                        color: AppColors.canopy,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s3,
                          vertical: AppSpacing.s1 + 2,
                        ),
                        child: Text(
                          l10n.shopPartnerOffer,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s6),
                DecoratedBox(
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
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shopWhyMatchesHeader,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Fraunces',
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          l10n.shopCommonlyFor(product.targetDisease),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: AppSpacing.s5,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            Expanded(
                              child: Text(
                                l10n.shopSafetyCopy,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                PillButton(
                  label: l10n.shopGoToMerchant,
                  onPressed: () => _openMerchant(product),
                ),
                const SizedBox(height: AppSpacing.s2),
                Center(
                  child: TextButton(
                    onPressed: _showDisclosure,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      minimumSize: const Size(0, AppLayout.touchTarget),
                    ),
                    child: Text(l10n.shopPartnerDisclosureTitle),
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

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppLayout.touchTarget),
        backgroundColor: AppColors.surfaceSunken,
        foregroundColor: AppColors.textPrimary,
      ),
      icon: Icon(icon),
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
