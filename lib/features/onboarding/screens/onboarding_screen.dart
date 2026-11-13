import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPageData> _pages(AppLocalizations l10n) => [
        _OnboardingPageData(
          title: l10n.onboardingTitle1,
          body: l10n.onboardingBody1,
          illustration: Icons.eco_outlined,
        ),
        _OnboardingPageData(
          title: l10n.onboardingTitle2,
          body: l10n.onboardingBody2,
          illustration: Icons.camera_alt_outlined,
        ),
        _OnboardingPageData(
          title: l10n.onboardingTitle3,
          body: l10n.onboardingBody3,
          illustration: Icons.calendar_today_outlined,
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
    }
    if (mounted) {
      context.read<OnboardingController>().completeOnboarding();
      context.go('/auth');
    }
  }

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  static const _languages = [
    ('en', 'English'),
    ('tl', 'Tagalog'),
    ('ceb', 'Cebuano'),
  ];

  String _currentLanguageName(BuildContext context) {
    final locale = context.read<LocaleProvider>().currentLocale;
    return _languages.firstWhere((entry) => entry.$1 == locale, orElse: () => _languages.first).$2;
  }

  void _showLanguageSheet() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.read<LocaleProvider>();

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(l10n.languageSheetTitle, style: theme.textTheme.titleLarge),
            ),
            ..._languages.map((entry) {
              final (code, name) = entry;
              final selected = provider.currentLocale == code;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () async {
                  await provider.setLocale(code);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              );
            }),
            const SizedBox(height: 16),
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextButton.icon(
                      onPressed: _showLanguageSheet,
                      icon: const Icon(Icons.language, size: 18),
                      label: Text(
                        _currentLanguageName(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      l10n.skip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return _OnboardingPage(
                    title: page.title,
                    body: page.body,
                    illustration: page.illustration,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: _currentPage > 0
                        ? TextButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Text(
                              l10n.back,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : const SizedBox(width: 80),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: FilledButton.icon(
                      onPressed: () => _nextPage(pages.length),
                      icon: Icon(_currentPage == pages.length - 1
                          ? Icons.arrow_forward
                          : Icons.chevron_right),
                      label: Text(
                        _currentPage == pages.length - 1
                            ? l10n.getStarted
                            : l10n.next,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.illustration,
  });
  final String title;
  final String body;
  final IconData illustration;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.illustration,
  });

  final String title;
  final String body;
  final IconData illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(illustration, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              body,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}