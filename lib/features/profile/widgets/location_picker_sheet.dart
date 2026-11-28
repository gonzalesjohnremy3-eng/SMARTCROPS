import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/features/profile/domain/davao_locations.dart';
import 'package:smart_crops/features/profile/services/device_place_finder.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

/// Asks where the Farmer farms. Returns "Barangay, City, Davao del Sur", or
/// null if they close the sheet.
Future<String?> showLocationPicker(
  BuildContext context, {
  DevicePlaceFinder? finder,
  Future<DavaoLocations>? locations,
}) {
  final placeFinder = finder ?? context.read<DevicePlaceFinder>();
  return showModalBottomSheet<String>(
    context: context,
    // Over the whole screen, including the bottom bar of the tab it opens from.
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (_) =>
        LocationPickerSheet(finder: placeFinder, locations: locations),
  );
}

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key, required this.finder, this.locations});

  final DevicePlaceFinder finder;

  /// The list to choose from; the bundled Davao del Sur data when null.
  final Future<DavaoLocations>? locations;

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late final Future<DavaoLocations> _locations =
      widget.locations ?? DavaoLocations.load();
  final _searchController = TextEditingController();
  LocationArea? _area;
  String _query = '';
  String? _message;
  bool _isFinding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _chooseArea(LocationArea? area, {String? message}) {
    _searchController.clear();
    setState(() {
      _area = area;
      _query = '';
      _message = message;
    });
  }

  Future<void> _useCurrentLocation(DavaoLocations locations) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isFinding = true;
      _message = null;
    });
    final result = await widget.finder.findCurrentPlace();
    if (!mounted) return;
    setState(() => _isFinding = false);

    switch (result) {
      case PlaceFound(:final barangay, :final area):
        final match = locations.match(barangay: barangay, area: area);
        if (match == null) {
          setState(
            () => _message = area == null
                ? l10n.locationUnavailable
                : l10n.locationOutsideProvince,
          );
        } else if (match.barangay != null) {
          Navigator.of(context).pop(
            locations.format(area: match.area.name, barangay: match.barangay),
          );
        } else {
          _chooseArea(
            match.area,
            message: l10n.locationFoundChooseBarangay(match.area.name),
          );
        }
      case PlaceDenied():
        setState(() => _message = l10n.locationPermissionOff);
      case PlaceServiceOff():
        setState(() => _message = l10n.locationServiceOff);
      case PlaceUnavailable():
        setState(() => _message = l10n.locationUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DavaoLocations>(
      future: _locations,
      builder: (context, snapshot) {
        final locations = snapshot.data;
        if (locations == null) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildSheet(context, locations);
      },
    );
  }

  Widget _buildSheet(BuildContext context, DavaoLocations locations) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final area = _area;
    final query = _query.trim().toLowerCase();
    final options = area == null
        ? locations.areas.map((a) => a.name).toList()
        : area.barangays;
    final visible = query.isEmpty
        ? options
        : options.where((o) => o.toLowerCase().contains(query)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s2,
                AppSpacing.s5,
                AppSpacing.s2,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.locationPickerTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Fraunces',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              color: AppColors.canopy,
                            ),
                            const SizedBox(width: AppSpacing.s3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.locationProvinceLabel,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  Text(
                                    locations.province,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.canopy,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    OutlinedButton.icon(
                      onPressed: _isFinding
                          ? null
                          : () => _useCurrentLocation(locations),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppLayout.touchTarget + AppSpacing.s2,
                        ),
                        foregroundColor: AppColors.canopy,
                        shape: const StadiumBorder(),
                      ),
                      icon: _isFinding
                          ? const SizedBox(
                              width: AppSpacing.s5,
                              height: AppSpacing.s5,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: Text(
                        _isFinding
                            ? l10n.locationFinding
                            : l10n.locationUseCurrent,
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: AppSpacing.s3),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.statusWarningSurface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.s4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Text(
                                  _message!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s5),
                    Wrap(
                      spacing: AppSpacing.s2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          area == null ? l10n.locationChooseArea : area.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (area != null)
                          TextButton(
                            onPressed: () => _chooseArea(null),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.canopy,
                              minimumSize: const Size(0, AppLayout.touchTarget),
                            ),
                            child: Text(l10n.locationChangeArea),
                          ),
                      ],
                    ),
                    if (area != null)
                      Text(
                        l10n.locationChooseBarangay,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.s2),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: l10n.locationSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: AppColors.surfaceSunken,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              sliver: SliverList.builder(
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final name = visible[index];
                  return _OptionRow(
                    label: name,
                    onTap: () {
                      if (area == null) {
                        _chooseArea(locations.areaNamed(name));
                      } else {
                        Navigator.of(context).pop(
                          locations.format(area: area.name, barangay: name),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s6)),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppLayout.touchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s2,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
