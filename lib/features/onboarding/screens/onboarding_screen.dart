import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_logo.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _languages = [
    ('en', 'English'),
    ('tl', 'Tagalog'),
    ('ceb', 'Cebuano'),
  ];

  List<_OnboardingPageData> _pages(AppLocalizations l10n) => [
    _OnboardingPageData(
      title: l10n.onboardingTitle1,
      body: l10n.onboardingBody1,
      imagePath: 'assets/images/overlays/crop_detail.webp',
      imageAlignment: Alignment.center,
      motif: const _BrandMotif(),
    ),
    _OnboardingPageData(
      title: l10n.onboardingTitle2,
      body: l10n.onboardingBody2,
      imagePath: 'assets/images/overlays/scan.webp',
      // Keeps the blast lesion inside the portrait crop.
      imageAlignment: const Alignment(0.25, 0),
      motif: const _ScanMotif(),
    ),
    _OnboardingPageData(
      title: l10n.onboardingTitle3,
      body: l10n.onboardingBody3,
      imagePath: 'assets/images/overlays/home.webp',
      imageAlignment: Alignment.center,
      motif: const _ForecastMotif(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
    } catch (_) {
      // The in-memory controller below still lets the Farmer continue.
    }
    if (mounted) {
      context.read<OnboardingController>().completeOnboarding();
      context.go('/auth');
    }
  }

  void _goToPage(int page) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _pageController.jumpToPage(page);
    } else {
      _pageController.animateToPage(
        page,
        duration: AppMotion.slow,
        curve: AppMotion.emphasizedCurve,
      );
    }
  }

  void _handleNext(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _finishOnboarding();
    }
  }

  String _currentLanguageName(BuildContext context) {
    final locale = context.read<LocaleProvider>().currentLocale;
    return _languages
        .firstWhere(
          (entry) => entry.$1 == locale,
          orElse: () => _languages.first,
        )
        .$2;
  }

  void _showLanguageSheet() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.read<LocaleProvider>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s6,
                  0,
                  AppSpacing.s6,
                  AppSpacing.s2,
                ),
                child: Text(
                  l10n.languageSheetTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ..._languages.map((entry) {
                final (code, name) = entry;
                final selected = provider.currentLocale == code;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s6,
                  ),
                  leading: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected ? AppColors.canopy : AppColors.borderStrong,
                  ),
                  title: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    await provider.setLocale(code);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                );
              }),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages(l10n);
    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      _OnboardingPage(data: pages[index]),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s6,
                    AppSpacing.s2,
                    AppSpacing.s6,
                    AppSpacing.s4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProgressDashes(
                        current: _currentPage,
                        total: pages.length,
                        label: l10n.onboardingProgress(
                          _currentPage + 1,
                          pages.length,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            IconButton(
                              tooltip: l10n.back,
                              onPressed: () => _goToPage(_currentPage - 1),
                              style: IconButton.styleFrom(
                                fixedSize: const Size.square(
                                  AppLayout.touchTarget + AppSpacing.s2,
                                ),
                                backgroundColor: AppColors.surfaceSunken,
                                foregroundColor: AppColors.textPrimary,
                              ),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: AppSpacing.s3),
                          ],
                          Expanded(
                            child: PillButton(
                              label: isLast ? l10n.getStarted : l10n.next,
                              onPressed: () => _handleNext(pages.length),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: _LanguagePill(
                      label: _currentLanguageName(context),
                      onPressed: _showLanguageSheet,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Flexible(
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textInverse,
                      ),
                      child: Text(
                        l10n.skip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.imagePath,
    required this.imageAlignment,
    required this.motif,
  });

  final String title;
  final String body;
  final String imagePath;
  final Alignment imageAlignment;
  final Widget motif;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // The photo takes what the text leaves, but never less than 220.
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 220),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data.imagePath),
                          fit: BoxFit.cover,
                          alignment: data.imageAlignment,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.forestInk.withValues(alpha: 0.6),
                              AppColors.forestInk.withValues(alpha: 0.05),
                              AppColors.forestInk.withValues(alpha: 0.55),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s6,
                              AppSpacing.s16,
                              AppSpacing.s6,
                              AppSpacing.s10,
                            ),
                            child: data.motif,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // The sheet rises over the photo's lower edge, as on Auth.
                Transform.translate(
                  offset: const Offset(0, -AppSpacing.s6),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.hero),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s6,
                        AppSpacing.s8,
                        AppSpacing.s6,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s3),
                          Text(
                            data.body,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// Page 1: the brand introduction.
class _BrandMotif extends StatelessWidget {
  const _BrandMotif();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Row(
        children: [
          const AppLogo(size: 64),
          const SizedBox(width: AppSpacing.s4),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.authBrandName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textInverse,
                    height: 1.05,
                  ),
                ),
                Text(
                  l10n.authBrandByline,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 2: the scan reticle sweeps once over the diseased leaf.
class _ScanMotif extends StatefulWidget {
  const _ScanMotif();

  @override
  State<_ScanMotif> createState() => _ScanMotifState();
}

class _ScanMotifState extends State<_ScanMotif>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: AppMotion.scanSequence * 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _sweep.value = 0.5;
    } else if (!_sweep.isAnimating && _sweep.value == 0) {
      _sweep.forward();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ReticleFrame(
        arm: AppSpacing.s6,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 176,
          height: 120,
          child: AnimatedBuilder(
            animation: _sweep,
            builder: (context, _) {
              final t = AppMotion.standardCurve.transform(_sweep.value);
              return Align(
                alignment: Alignment(0, -1 + 2 * t),
                child: Opacity(
                  opacity: _sweep.isCompleted ? 0 : 1,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.leaf.withValues(alpha: 0),
                          AppColors.leaf,
                          AppColors.leaf.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Page 3: an example of the Field Calendar reacting to the forecast.
class _ForecastMotif extends StatelessWidget {
  const _ForecastMotif();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      // No maxWidth box: under IntrinsicHeight it would mis-measure the text.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestInk.withValues(alpha: 0.25),
              blurRadius: AppSpacing.s6,
              offset: const Offset(0, AppSpacing.s2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.s10,
                height: AppSpacing.s10,
                decoration: const BoxDecoration(
                  color: AppColors.statusInfoSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.rain,
                  size: AppSpacing.s5,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.onboardingExampleForecast,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.rain,
                      ),
                    ),
                    Text(
                      l10n.onboardingExampleTask,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDashes extends StatelessWidget {
  const _ProgressDashes({
    required this.current,
    required this.total,
    required this.label,
  });

  final int current;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.s1 + 2),
            AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              width: i == current ? AppSpacing.s8 : AppSpacing.s2,
              height: AppSpacing.s1 + 2,
              decoration: BoxDecoration(
                color: i == current ? AppColors.canopy : AppColors.borderStrong,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.forestInk.withValues(alpha: 0.45),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.textInverse.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppLayout.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language,
                  size: AppSpacing.s4 + 2,
                  color: AppColors.textInverse,
                ),
                const SizedBox(width: AppSpacing.s2),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textInverse,
                    ),
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
