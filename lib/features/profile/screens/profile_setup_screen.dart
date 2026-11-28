import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/profile/widgets/crop_picker.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const onboardingCompleteKey = 'onboarding_complete';
const profileCompleteKey = 'profile_complete';

const _gutter = AppSpacing.s5;
const _stepCount = 3;

const _fallbackCrops = ['Pechay', 'Corn', 'Rice', 'Tomato', 'Eggplant'];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PageController _pageController;

  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  int _currentStep = 0;
  final Set<String> _selectedCrops = {};
  bool _isSaving = false;

  static bool _aboutYouAlreadySet(UserProfile? profile) {
    return profile != null &&
        profile.fullName.isNotEmpty &&
        profile.farmName != null &&
        profile.location != null;
  }

  @override
  void initState() {
    super.initState();
    final profile = context.read<SmartCropsService>().currentUserProfile;
    _fullNameController.text = profile?.fullName ?? '';
    _farmNameController.text = profile?.farmName ?? '';
    _locationController.text = profile?.location ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
    if (_aboutYouAlreadySet(profile)) {
      // About You was already filled in and saved earlier (e.g. an earlier
      // login where the local completion flag is missing). Start at the Main
      // Crops step so About You is not shown again and saving the wizard
      // cannot overwrite the saved profile.
      _currentStep = 1;
    }
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<String> _availableCropNames(SmartCropsService service) {
    final names = service.availableCrops.map((c) => c.cropName).toList();
    return names.isEmpty ? _fallbackCrops : names;
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
        if (mounted) {
          context.trackEvent(
            'crops_selected',
            params: {'crop_count': _selectedCrops.length},
          );
        }
        if (cropIds.isNotEmpty) {
          await service.saveUserCrops(cropIds);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(onboardingCompleteKey, true);
      await prefs.setBool(profileCompleteKey, true);

      if (mounted) {
        context.trackEvent('profile_completed');
        context.read<OnboardingController>().completeProfile();
        context.go('/home');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _persistAboutYou(SmartCropsService service) async {
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
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _nextStep(SmartCropsService service) async {
    context.trackEvent(
      'profile_step_completed',
      params: {'step': _currentStep},
    );
    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      // Persist About You as its own step so closing the app before the final
      // save cannot lose it and bring the empty step back.
      if (!await _persistAboutYou(service)) return;
    }
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep += 1);
      _pageController.nextPage(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      _pageController.previousPage(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<SmartCropsService>();
    final crops = _availableCropNames(service);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(
              step: _currentStep,
              onBack: _currentStep > 0 ? _previousStep : null,
            ),
            Expanded(
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
                  ),
                  _MainCropsStep(
                    crops: crops,
                    selectedCrops: _selectedCrops,
                    onCropToggled: (crop) => setState(() {
                      if (_selectedCrops.contains(crop)) {
                        _selectedCrops.remove(crop);
                      } else {
                        _selectedCrops.add(crop);
                      }
                    }),
                  ),
                  _PermissionsStep(
                    isSaving: _isSaving,
                    onComplete: () => _save(service),
                  ),
                ],
              ),
            ),
            if (_currentStep < _stepCount - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _gutter,
                  AppSpacing.s2,
                  _gutter,
                  AppSpacing.s4,
                ),
                child: PillButton(
                  label: l10n.next,
                  isLoading: _isSaving,
                  onPressed: () => _nextStep(service),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.onBack});

  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _gutter,
        AppSpacing.s4,
        _gutter,
        AppSpacing.s2,
      ),
      child: Row(
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s3),
              child: IconButton(
                tooltip: l10n.back,
                onPressed: onBack,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(AppLayout.touchTarget),
                  backgroundColor: AppColors.surfaceSunken,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          Expanded(
            child: ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < _stepCount; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.s1 + 2),
                    Expanded(
                      child: AnimatedContainer(
                        duration: AppMotion.standard,
                        height: AppSpacing.s1,
                        decoration: BoxDecoration(
                          color: i <= step
                              ? AppColors.canopy
                              : AppColors.borderSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Flexible(
            child: Text(
              textAlign: TextAlign.end,
              l10n.onboardingProgress(step + 1, _stepCount),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
      ],
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
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController farmNameController;
  final TextEditingController locationController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String? required(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

    Widget field(
      TextEditingController controller,
      String label, {
      bool isRequired = true,
      TextInputType? keyboardType,
      bool last = false,
      Iterable<String>? autofillHints,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: keyboardType == null
            ? TextCapitalization.words
            : TextCapitalization.none,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        autofillHints: autofillHints,
        decoration: InputDecoration(labelText: label),
        validator: isRequired ? required : null,
      ),
    );

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          _gutter,
          AppSpacing.s4,
          _gutter,
          AppSpacing.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepTitle(
              title: l10n.profileSetupStep1Title,
              subtitle: l10n.profileSetupStep1Subtitle,
            ),
            field(
              fullNameController,
              l10n.fullName,
              autofillHints: const [AutofillHints.name],
            ),
            field(farmNameController, l10n.farmName),
            field(locationController, l10n.location),
            field(
              phoneController,
              l10n.phoneNumber,
              isRequired: false,
              keyboardType: TextInputType.phone,
              last: true,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCropsStep extends StatelessWidget {
  const _MainCropsStep({
    required this.crops,
    required this.selectedCrops,
    required this.onCropToggled,
  });

  final List<String> crops;
  final Set<String> selectedCrops;
  final ValueChanged<String> onCropToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _gutter,
        AppSpacing.s4,
        _gutter,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: l10n.profileSetupStep2Title,
            subtitle: l10n.profileSetupStep2Subtitle,
          ),
          CropPicker(
            crops: crops,
            selected: selectedCrops,
            onToggle: onCropToggled,
          ),
        ],
      ),
    );
  }
}

class _PermissionsStep extends StatefulWidget {
  const _PermissionsStep({required this.isSaving, required this.onComplete});

  final bool isSaving;
  final VoidCallback onComplete;

  @override
  State<_PermissionsStep> createState() => _PermissionsStepState();
}

class _PermissionsStepState extends State<_PermissionsStep> {
  static const _permissions = [
    Permission.camera,
    Permission.locationWhenInUse,
    Permission.notification,
  ];

  final Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _refreshStatuses();
  }

  Future<void> _refreshStatuses() async {
    try {
      final statuses = <Permission, PermissionStatus>{};
      for (final permission in _permissions) {
        statuses[permission] = await permission.status;
      }
      if (!mounted) return;
      setState(() {
        _statuses
          ..clear()
          ..addAll(statuses);
      });
    } catch (_) {
      // Permission APIs are only available on mobile platforms.
    }
  }

  Future<void> _request(Permission permission) async {
    try {
      final status = await permission.request();
      if (!mounted) return;
      context.trackEvent(
        status.isGranted ? 'permission_granted' : 'permission_denied',
        params: {'permission': permission.toString()},
      );
      setState(() => _statuses[permission] = status);
      if (!status.isGranted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorPermission),
            action: SnackBarAction(
              label: l10n.settingsTitle,
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } catch (_) {
      // Permission APIs are only available on mobile platforms.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final rows = [
      (
        Icons.camera_alt_outlined,
        l10n.cameraPermission,
        l10n.cameraPermissionDescription,
        Permission.camera,
      ),
      (
        Icons.location_on_outlined,
        l10n.locationPermission,
        l10n.locationPermissionDescription,
        Permission.locationWhenInUse,
      ),
      (
        Icons.notifications_outlined,
        l10n.notificationsPermission,
        l10n.notificationsPermissionDescription,
        Permission.notification,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _gutter,
        AppSpacing.s4,
        _gutter,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: l10n.profileSetupStep3Title,
            subtitle: l10n.profileSetupStep3Subtitle,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forestInk.withValues(alpha: 0.06),
                  blurRadius: AppSpacing.s4,
                  offset: const Offset(0, AppSpacing.s1),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: AppSpacing.s4,
                      endIndent: AppSpacing.s4,
                      color: AppColors.borderSubtle,
                    ),
                  _PermissionRow(
                    icon: rows[i].$1,
                    title: rows[i].$2,
                    description: rows[i].$3,
                    granted: _statuses[rows[i].$4]?.isGranted ?? false,
                    onTap: () => _request(rows[i].$4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          PillButton(
            label: l10n.completeSetup,
            isLoading: widget.isSaving,
            onPressed: widget.onComplete,
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          children: [
            Container(
              width: AppLayout.touchTarget,
              height: AppLayout.touchTarget,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(AppRadius.card - 4),
              ),
              child: Icon(icon, color: AppColors.canopy),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Icon(
              granted
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: granted ? AppColors.canopy : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
