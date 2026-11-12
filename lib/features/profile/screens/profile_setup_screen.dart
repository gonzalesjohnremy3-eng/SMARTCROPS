import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const onboardingCompleteKey = 'onboarding_complete';
const profileCompleteKey = 'profile_complete';

const _fallbackCrops = [
  'Pechay',
  'Corn',
  'Rice',
  'Tomato',
  'Eggplant',
];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cropSearchController = TextEditingController();

  int _currentStep = 0;
  final Set<String> _selectedCrops = {};
  String _cropSearch = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _cropSearchController.dispose();
    super.dispose();
  }

  List<String> _availableCropNames(SmartCropsService service) {
    final names = service.availableCrops.map((c) => c.cropName).toList();
    return names.isEmpty ? _fallbackCrops : names;
  }

  List<String> _filteredCrops(List<String> crops) {
    if (_cropSearch.isEmpty) return crops;
    final query = _cropSearch.toLowerCase();
    return crops.where((crop) => crop.toLowerCase().contains(query)).toList();
  }

  Future<void> _save(SmartCropsService service) async {
    setState(() => _isSaving = true);
    try {
      await service.updateProfile(
        _fullNameController.text.trim(),
        _farmNameController.text.trim(),
        _locationController.text.trim(),
        _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (_selectedCrops.isNotEmpty) {
        final cropIds = service.availableCrops
            .where((crop) => _selectedCrops.contains(crop.cropName))
            .map((crop) => crop.id)
            .toList();
        if (cropIds.isNotEmpty) {
          await service.saveUserCrops(cropIds);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(onboardingCompleteKey, true);
      await prefs.setBool(profileCompleteKey, true);

      if (mounted) {
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _nextStep(List<String> crops) {
    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final crops = _availableCropNames(service);
    final filteredCrops = _filteredCrops(crops);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileSetupStep1Title),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _AboutYouStep(
              formKey: _formKey,
              fullNameController: _fullNameController,
              farmNameController: _farmNameController,
              locationController: _locationController,
              phoneController: _phoneController,
              l10n: l10n,
              theme: theme,
            ),
            _MainCropsStep(
              searchController: _cropSearchController,
              filteredCrops: filteredCrops,
              selectedCrops: _selectedCrops,
              cropSearch: _cropSearch,
              onSearchChanged: (value) => setState(() => _cropSearch = value),
              onCropToggled: (crop) => setState(() {
                if (_selectedCrops.contains(crop)) {
                  _selectedCrops.remove(crop);
                } else {
                  _selectedCrops.add(crop);
                }
              }),
              l10n: l10n,
              theme: theme,
            ),
            _PermissionsStep(
              l10n: l10n,
              theme: theme,
              isSaving: _isSaving,
              onComplete: () => _save(service),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _currentStep < 2
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => _nextStep(crops),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l10n.next),
                ),
              ),
            )
          : null,
    );
  }
}

class _AboutYouStep extends StatelessWidget {
  const _AboutYouStep({
    required this.formKey,
    required this.fullNameController,
    required this.farmNameController,
    required this.locationController,
    required this.phoneController,
    required this.l10n,
    required this.theme,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController farmNameController;
  final TextEditingController locationController;
  final TextEditingController phoneController;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profileSetupStep1Title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.profileSetupStep1Subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l10n.errorGeneric : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: farmNameController,
              decoration: InputDecoration(
                labelText: l10n.farmName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l10n.errorGeneric : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: l10n.location,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l10n.errorGeneric : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCropsStep extends StatelessWidget {
  const _MainCropsStep({
    required this.searchController,
    required this.filteredCrops,
    required this.selectedCrops,
    required this.cropSearch,
    required this.onSearchChanged,
    required this.onCropToggled,
    required this.l10n,
    required this.theme,
  });

  final TextEditingController searchController;
  final List<String> filteredCrops;
  final Set<String> selectedCrops;
  final String cropSearch;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCropToggled;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupStep2Title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(l10n.profileSetupStep2Subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: l10n.searchCrops,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredCrops.map((crop) {
              final selected = selectedCrops.contains(crop);
              return FilterChip(
                label: Text(crop),
                selected: selected,
                onSelected: (_) => onCropToggled(crop),
                avatar: selected ? const Icon(Icons.check, size: 18) : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cropsSelectedCount(selectedCrops.length),
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _PermissionsStep extends StatelessWidget {
  const _PermissionsStep({
    required this.l10n,
    required this.theme,
    required this.isSaving,
    required this.onComplete,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isSaving;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSetupStep3Title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(l10n.profileSetupStep3Subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          _PermissionTile(
            icon: Icons.camera_alt_outlined,
            title: l10n.cameraPermission,
            description: l10n.cameraPermissionDescription,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.location_on_outlined,
            title: l10n.locationPermission,
            description: l10n.locationPermissionDescription,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.notifications_outlined,
            title: l10n.notificationsPermission,
            description: l10n.notificationsPermissionDescription,
            theme: theme,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: isSaving ? null : onComplete,
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(l10n.completeSetup),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String description;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}