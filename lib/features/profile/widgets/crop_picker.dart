import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

/// Search, crop pills and a running count: how a Farmer chooses Main Crops.
/// Shared by profile setup and Manage crops so the two never drift apart.
class CropPicker extends StatefulWidget {
  const CropPicker({
    super.key,
    required this.crops,
    required this.selected,
    required this.onToggle,
  });

  final List<String> crops;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<CropPicker> createState() => _CropPickerState();
}

class _CropPickerState extends State<CropPicker> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _visible {
    if (_search.isEmpty) return widget.crops;
    final query = _search.toLowerCase();
    return widget.crops
        .where((crop) => crop.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _search = value),
          decoration: InputDecoration(
            hintText: l10n.searchCrops,
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: AppColors.surfaceSunken,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final crop in _visible)
              _CropPill(
                label: crop,
                selected: widget.selected.contains(crop),
                onTap: () => widget.onToggle(crop),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s5),
        Text(
          l10n.cropsSelectedCount(widget.selected.length),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CropPill extends StatelessWidget {
  const _CropPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.canopy : AppColors.mist,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppLayout.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(
                      Icons.check_rounded,
                      size: AppSpacing.s5,
                      color: AppColors.textInverse,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
