import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/setup/profile');
    }
  }

  void _skipOnboarding() {
    context.go('/setup/profile');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(l10n.skip),
                ),
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
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: Text(l10n.back),
                        )
                      : const SizedBox(width: 80),
                  FilledButton.icon(
                    onPressed: () => _nextPage(pages.length),
                    icon: Icon(_currentPage == pages.length - 1
                        ? Icons.arrow_forward
                        : Icons.chevron_right),
                    label: Text(_currentPage == pages.length - 1
                        ? l10n.getStarted
                        : l10n.next),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}