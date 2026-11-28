import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/analytics/analytics.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _gutter = AppSpacing.s5;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SmartCropsService>();
    final profile = service.currentUserProfile;
    final crops = service.userSelectedCrops;

    final farmSections = <Widget>[
      _Identity(
        profile: profile,
        isEditing: _isEditing,
        onToggleEdit: () => setState(() => _isEditing = !_isEditing),
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
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
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
    required this.onToggleEdit,
  });

  final UserProfile? profile;
  final bool isEditing;
  final VoidCallback onToggleEdit;

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
        Container(
          width: AppSpacing.s12 + AppSpacing.s4,
          height: AppSpacing.s12 + AppSpacing.s4,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.canopy,
            shape: BoxShape.circle,
          ),
          child: Text(
            String.fromCharCode(name.runes.first).toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Fraunces',
              color: AppColors.textInverse,
            ),
          ),
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
  });

  final bool editing;
  final bool isSaving;
  final VoidCallback onSave;
  final TextEditingController nameController;
  final TextEditingController farmController;
  final TextEditingController locationController;
  final TextEditingController phoneController;

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
          field(locationController, l10n.location),
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
        // Wrap lets "Manage" drop under long translations at large text.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _SectionTitle(l10n.profileCrops),
            TextButton(
              onPressed: () => context.go('/setup/profile'),
              style: TextButton.styleFrom(foregroundColor: AppColors.canopy),
              child: Text(l10n.profileManageCrops),
            ),
          ],
        ),
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
                        const Icon(
                          Icons.eco_outlined,
                          size: AppSpacing.s4 + 2,
                          color: AppColors.canopy,
                        ),
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
