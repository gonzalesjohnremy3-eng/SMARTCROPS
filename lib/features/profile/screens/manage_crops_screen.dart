import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_back_button.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/profile/widgets/crop_picker.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

/// Change the Main Crops of a Farmer who has already finished setup.
class ManageCropsScreen extends StatefulWidget {
  const ManageCropsScreen({super.key});

  @override
  State<ManageCropsScreen> createState() => _ManageCropsScreenState();
}

class _ManageCropsScreenState extends State<ManageCropsScreen> {
  late final Set<String> _selected = context
      .read<SmartCropsService>()
      .userSelectedCrops
      .map((crop) => crop.cropName)
      .toSet();
  bool _isSaving = false;

  Future<void> _save(SmartCropsService service) async {
    setState(() => _isSaving = true);
    try {
      final ids = service.availableCrops
          .where((crop) => _selected.contains(crop.cropName))
          .map((crop) => crop.id)
          .toList();
      await service.saveUserCrops(ids);
      if (!mounted) return;
      context.trackEvent('crops_selected', params: {'crop_count': ids.length});
      Navigator.of(context).maybePop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s5,
                  AppSpacing.s4,
                  AppSpacing.s5,
                  AppSpacing.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBackButton(),
                    const SizedBox(height: AppSpacing.s5),
                    Text(
                      l10n.profileSetupStep2Title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      l10n.profileSetupStep2Subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    CropPicker(
                      crops: service.availableCrops
                          .map((crop) => crop.cropName)
                          .toList(),
                      selected: _selected,
                      onToggle: (crop) => setState(() {
                        if (!_selected.remove(crop)) _selected.add(crop);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s2,
                AppSpacing.s5,
                AppSpacing.s4,
              ),
              child: PillButton(
                label: l10n.profileSave,
                isLoading: _isSaving,
                onPressed: () => _save(service),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
