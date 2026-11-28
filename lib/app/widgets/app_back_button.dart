import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

/// The round Back button for a page opened on top of another.
///
/// When nothing is behind the page (a notification or a link opened it
/// directly) it goes Home instead of leaving the app.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).back,
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppLayout.touchTarget),
        backgroundColor: AppColors.surfaceSunken,
        foregroundColor: AppColors.textPrimary,
      ),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}
