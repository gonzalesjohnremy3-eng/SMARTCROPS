import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.carePlanTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt_outlined, size: 64, color: AppTheme.light().colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.carePlanEmpty,
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