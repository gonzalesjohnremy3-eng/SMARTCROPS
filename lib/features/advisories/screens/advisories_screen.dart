import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class AdvisoriesScreen extends StatelessWidget {
  const AdvisoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.advisoriesTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 64, color: AppTheme.light().colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.advisoriesEmpty,
                textAlign: TextAlign.center,
                style: AppTheme.light().textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}