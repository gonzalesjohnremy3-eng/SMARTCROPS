import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/profile/widgets/location_picker_sheet.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/crops/widgets/crop_icon.dart';

const _gutter = AppSpacing.s5;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.pickLocation, this.pickAvatar});

  /// Asks where the Farmer farms; the Davao del Sur picker when null.
  final Future<String?> Function(BuildContext context)? pickLocation;

  /// Picks a profile photo; the camera or gallery when null.
  final Future<XFile?> Function(ImageSource source)? pickAvatar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _farmController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final service = context.read<SmartCropsService>();
    final profile = service.currentUserProfile;
    _nameController.text = profile?.fullName ?? '';
    _farmController.text = profile?.farmName ?? '';
    _locationController.text = profile?.location ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save(SmartCropsService service) async {
    setState(() => _isSaving = true);
    try {
      await service.updateProfile(
        _nameController.text.trim(),
        _farmController.text.trim(),
        _locationController.text.trim(),
        _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        context.trackEvent('profile_edited');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).profileUpdated)),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _chooseLocation() async {
    final chosen = await (widget.pickLocation ?? showLocationPicker)(context);
    if (chosen != null && mounted) {
      setState(() => _locationController.text = chosen);
    }
  }

  Future<void> _changeAvatar() async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<SmartCropsService>();
    final messenger = ScaffoldMessenger.of(context);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: AppColors.paper,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PhotoSourceTile(
              icon: Icons.photo_camera_outlined,
              label: l10n.avatarTake,
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            _PhotoSourceTile(
              icon: Icons.photo_library_outlined,
              label: l10n.avatarChoose,
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.s2),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final pick =
        widget.pickAvatar ??
        (ImageSource s) =>
            ImagePicker().pickImage(source: s, maxWidth: 600, imageQuality: 85);
    final file = await pick(source);
    if (file == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final bytes = await file.readAsBytes();
      final isPng = file.name.toLowerCase().endsWith('.png');
      await service.updateAvatar(bytes, extension: isPng ? 'png' : 'jpg');
      messenger.showSnackBar(SnackBar(content: Text(l10n.avatarUpdated)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.avatarUploadFailed)));
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SmartCropsService>();
    final profile = service.currentUserProfile;
    final crops = service.userSelectedCrops;

    final farmSections = <Widget>[
      _Identity(
        profile: profile,
        isEditing: _isEditing,
        isUploadingAvatar: _isUploadingAvatar,
        onToggleEdit: () => setState(() => _isEditing = !_isEditing),
        onChangePhoto: _changeAvatar,
      ),
      const SizedBox(height: AppSpacing.s5),
      _FarmDetails(
        editing: _isEditing,
        isSaving: _isSaving,
        onSave: () => _save(service),
        nameController: _nameController,
        farmController: _farmController,
        locationController: _locationController,
        phoneController: _phoneController,
        onChooseLocation: _chooseLocation,
      ),
      const SizedBox(height: AppSpacing.s8),
      _CropsSection(crops: crops),
    ];
    final settingsSections = <Widget>[
      const _LinksSection(),
      const SizedBox(height: AppSpacing.s8),
      const _LanguageSection(),
      const SizedBox(height: AppSpacing.s8),
      const _SignOutRow(),
    ];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < AppLayout.breakpoints['expanded']!) {
            return _Column(
              children: [
                ...farmSections,
                const SizedBox(height: AppSpacing.s8),
                ...settingsSections,
              ],
            );
          }

          return Row(
            key: const Key('profile-wide-two-column'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                key: const Key('profile-farm-column'),
                flex: 5,
                child: _Column(children: farmSections),
              ),
              const VerticalDivider(width: 1, color: AppColors.borderSubtle),
              Expanded(
                key: const Key('profile-settings-column'),
                flex: 5,
                child: _Column(
                  children: [
                    const SizedBox(height: AppSpacing.s12),
                    ...settingsSections,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          _gutter,
          AppSpacing.s4,
          _gutter,
          AppSpacing.s10,
        ),
        children: children,
      ),
    );
  }
}

/// Rows grouped on one raised surface, separated by hairlines.
class _Raised extends StatelessWidget {
  const _Raised({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.s4,
                endIndent: AppSpacing.s4,
                color: AppColors.borderSubtle,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.padded = true});

  final String text;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padded ? AppSpacing.s3 : 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'Fraunces',
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.profile,
    required this.isEditing,
    required this.isUploadingAvatar,
    required this.onToggleEdit,
    required this.onChangePhoto,
  });

  final UserProfile? profile;
  final bool isEditing;
  final bool isUploadingAvatar;
  final VoidCallback onToggleEdit;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPro = context.watch<AgriProEntitlement>().isPro;
    final name = profile?.fullName.trim().isNotEmpty == true
        ? profile!.fullName.trim()
        : l10n.profileName;
    final email = profile?.email ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          name: name,
          imageUrl: profile?.avatarUrl,
          isEditing: isEditing,
          isUploading: isUploadingAvatar,
          onTap: onChangePhoto,
        ),
        const SizedBox(width: AppSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (isPro) ...[
                const SizedBox(height: AppSpacing.s2),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.statusHealthySurface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3 - 2,
                      vertical: AppSpacing.s1,
                    ),
                    child: Text(
                      l10n.agriProTitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.statusHealthy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          key: const Key('profile_edit'),
          tooltip: isEditing ? l10n.profileCancel : l10n.profileEdit,
          onPressed: onToggleEdit,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(AppLayout.touchTarget),
            backgroundColor: AppColors.surfaceSunken,
            foregroundColor: AppColors.textPrimary,
          ),
          icon: Icon(isEditing ? Icons.close_rounded : Icons.edit_outlined),
        ),
      ],
    );
  }
}

class _FarmDetails extends StatelessWidget {
  const _FarmDetails({
    required this.editing,
    required this.isSaving,
    required this.onSave,
    required this.nameController,
    required this.farmController,
    required this.locationController,
    required this.phoneController,
    required this.onChooseLocation,
  });

  final bool editing;
  final bool isSaving;
  final VoidCallback onSave;
  final TextEditingController nameController;
  final TextEditingController farmController;
  final TextEditingController locationController;
  final TextEditingController phoneController;
  final VoidCallback onChooseLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (editing) {
      Widget field(
        TextEditingController c,
        String label, {
        bool phone = false,
      }) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
        child: TextField(
          controller: c,
          keyboardType: phone ? TextInputType.phone : null,
          decoration: InputDecoration(labelText: label),
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field(nameController, l10n.fullName),
          field(farmController, l10n.farmName),
          _LocationField(
            key: const Key('profile_location_field'),
            controller: locationController,
            onTap: onChooseLocation,
          ),
          field(phoneController, l10n.phoneNumber, phone: true),
          const SizedBox(height: AppSpacing.s2),
          PillButton(
            label: l10n.profileSave,
            onPressed: onSave,
            isLoading: isSaving,
          ),
        ],
      );
    }

    return _Raised(
      children: [
        _InfoRow(
          icon: Icons.agriculture_outlined,
          label: l10n.farmName,
          value: farmController.text,
        ),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: l10n.location,
          value: locationController.text,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: l10n.phoneNumber,
          value: phoneController.text,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.imageUrl,
    required this.isEditing,
    required this.isUploading,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool isEditing;
  final bool isUploading;
  final VoidCallback onTap;

  static const double _size = AppSpacing.s12 + AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final initial = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      color: AppColors.canopy,
      child: Text(
        String.fromCharCode(name.runes.first).toUpperCase(),
        style: theme.textTheme.headlineMedium?.copyWith(
          fontFamily: 'Fraunces',
          color: AppColors.textInverse,
        ),
      ),
    );
    final url = imageUrl;

    return Semantics(
      button: isEditing,
      label: isEditing ? l10n.avatarChange : null,
      child: InkWell(
        key: const Key('profile_avatar'),
        customBorder: const CircleBorder(),
        onTap: isEditing && !isUploading ? onTap : null,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Every photo is cropped to a circle, whatever its shape.
              ClipOval(
                child: url == null
                    ? initial
                    : Image.network(
                        url,
                        key: const Key('profile_avatar_image'),
                        width: _size,
                        height: _size,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => initial,
                      ),
              ),
              if (isUploading)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x66000000),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: AppSpacing.s6,
                        height: AppSpacing.s6,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isEditing && !isUploading)
                Positioned(
                  right: -AppSpacing.s1,
                  bottom: -AppSpacing.s1,
                  child: Container(
                    key: const Key('profile_avatar_badge'),
                    width: AppSpacing.s6 + AppSpacing.s1,
                    height: AppSpacing.s6 + AppSpacing.s1,
                    decoration: BoxDecoration(
                      color: AppColors.actionPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.paper, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: AppSpacing.s4,
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppLayout.touchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s5,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.canopy),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The location is chosen from the Davao del Sur list, not typed.
class _LocationField extends StatelessWidget {
  const _LocationField({
    super.key,
    required this.controller,
    required this.onTap,
  });

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = controller.text.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InputDecorator(
          isEmpty: text.isEmpty,
          decoration: InputDecoration(
            labelText: l10n.location,
            hintText: l10n.locationChoose,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: const Icon(Icons.my_location_rounded),
          ),
          child: text.isEmpty
              ? null
              : Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.s5, color: AppColors.canopy),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value.isEmpty ? '—' : value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropsSection extends StatelessWidget {
  const _CropsSection({required this.crops});

  final List<CropItem> crops;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionTitle(l10n.profileCrops, padded: false)),
            TextButton(
              onPressed: () => context.push('/manage-crops'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.canopy,
                minimumSize: const Size(0, AppLayout.touchTarget),
              ),
              child: Text(l10n.profileManageCrops),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        if (crops.isEmpty)
          Text(
            l10n.cropsEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final crop in crops)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CropIcon(name: crop.cropName, size: AppSpacing.s4 + 2),
                        const SizedBox(width: AppSpacing.s2),
                        Flexible(
                          child: Text(
                            crop.cropName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _LinksSection extends StatelessWidget {
  const _LinksSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPro = context.watch<AgriProEntitlement>().isPro;

    return _Raised(
      children: [
        _LinkRow(
          icon: isPro
              ? Icons.workspace_premium
              : Icons.workspace_premium_outlined,
          title: l10n.agriProTitle,
          subtitle: isPro
              ? l10n.agriProPlanActive
              : l10n.agriProFeatureUnlimited,
          onTap: () => context.push(isPro ? '/pro/manage' : '/pro'),
        ),
        _LinkRow(
          icon: Icons.storefront_outlined,
          title: l10n.shopTitle,
          subtitle: l10n.shopProfileSubtitle,
          onTap: () => context.push('/shop'),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
            Icon(icon, color: AppColors.canopy),
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
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  static const _languages = [
    ('en', 'English'),
    ('tl', 'Tagalog'),
    ('ceb', 'Cebuano'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = context.watch<LocaleProvider>().currentLocale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.languageSheetTitle),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final (code, name) in _languages)
              Semantics(
                button: true,
                selected: code == current,
                child: Material(
                  color: code == current ? AppColors.canopy : AppColors.mist,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () {
                      context.trackEvent(
                        'language_changed',
                        params: {'language': code},
                      );
                      context.read<LocaleProvider>().setLocale(code);
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppLayout.touchTarget,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                        ),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: code == current
                                      ? AppColors.textInverse
                                      : AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SignOutRow extends StatelessWidget {
  const _SignOutRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.profileSignOutConfirm),
              content: Text(l10n.profileSignOutConfirmBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.profileCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.clay,
                  ),
                  child: Text(l10n.profileSignOutAction),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            context.trackEvent('sign_out');
            await context.read<SmartCropsService>().signOut();
            if (context.mounted) {
              context.go('/auth');
            }
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.clay,
          minimumSize: const Size(0, AppLayout.touchTarget),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: Text(l10n.profileSignout),
      ),
    );
  }
}
