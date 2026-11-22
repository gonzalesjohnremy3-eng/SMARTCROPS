import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';

class CropCareShell extends StatelessWidget {
  const CropCareShell({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  static const paths = [
    '/cropcare/home',
    '/cropcare/scan',
    '/cropcare/history',
    '/cropcare/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          CropSpacing.s6,
          0,
          CropSpacing.s6,
          CropSpacing.s4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CropRadius.pill),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) => context.go(paths[value]),
            backgroundColor: CropColors.primary,
            selectedItemColor: CropColors.accent,
            unselectedItemColor: CropColors.inverse,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: l10n.cropCareHome,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.crop_free_outlined),
                label: l10n.cropCareScan,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: l10n.cropCareHistory,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: l10n.cropCareProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
