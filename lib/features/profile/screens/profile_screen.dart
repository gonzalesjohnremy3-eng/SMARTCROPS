import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final profile = service.currentUserProfile;
    final crops = service.userSelectedCrops;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : () => _save(service),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.profileEdit),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(profile: profile, l10n: l10n, theme: theme),
          const SizedBox(height: 16),
          _EditSection(
            editing: _isEditing,
            onToggleEdit: () => setState(() => _isEditing = !_isEditing),
            nameController: _nameController,
            farmController: _farmController,
            locationController: _locationController,
            phoneController: _phoneController,
            l10n: l10n,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _CropsSection(crops: crops, l10n: l10n, theme: theme),
          const SizedBox(height: 16),
          _LanguageSection(l10n: l10n, theme: theme),
          const SizedBox(height: 16),
          _SignOutSection(l10n: l10n, theme: theme),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.l10n,
    required this.theme,
  });

  final UserProfile? profile;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 42, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.fullName ?? l10n.profileName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  const _EditSection({
    required this.editing,
    required this.onToggleEdit,
    required this.nameController,
    required this.farmController,
    required this.locationController,
    required this.phoneController,
    required this.l10n,
    required this.theme,
  });

  final bool editing;
  final VoidCallback onToggleEdit;
  final TextEditingController nameController;
  final TextEditingController farmController;
  final TextEditingController locationController;
  final TextEditingController phoneController;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.profileTitle, style: theme.textTheme.titleLarge),
                IconButton(
                  icon: Icon(editing ? Icons.close : Icons.edit),
                  onPressed: onToggleEdit,
                  tooltip: editing ? l10n.profileCancel : l10n.profileEdit,
                ),
              ],
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: farmController,
                decoration: InputDecoration(
                  labelText: l10n.farmName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: l10n.location,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ] else ...[
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.agriculture, label: l10n.farmName, value: nameController.text, theme: theme),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.location_on, label: l10n.location, value: locationController.text, theme: theme),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.phone, label: l10n.phoneNumber, value: phoneController.text, theme: theme),
            ],
          ],
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
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CropsSection extends StatelessWidget {
  const _CropsSection({
    required this.crops,
    required this.l10n,
    required this.theme,
  });

  final List<CropItem> crops;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.profileCrops, style: theme.textTheme.titleLarge),
                TextButton(
                  onPressed: () => context.go('/setup/profile'),
                  child: Text(l10n.profileManageCrops),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (crops.isEmpty)
              Text(l10n.cropsEmpty, style: theme.textTheme.bodyMedium)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: crops.map((crop) {
                  return Chip(
                    avatar: Icon(Icons.eco, size: 18, color: theme.colorScheme.primary),
                    label: Text(crop.cropName),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  static const _languages = [
    ('en', 'English'),
    ('tl', 'Tagalog'),
    ('ceb', 'Cebuano'),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = localeProvider.currentLocale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.languageSheetTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._languages.map((entry) {
              final (code, name) = entry;
              final selected = currentLocale == code;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
                title: Text(name),
                onTap: () => context.read<LocaleProvider>().setLocale(code),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SignOutSection extends StatelessWidget {
  const _SignOutSection({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.logout, color: theme.colorScheme.error),
        title: Text(
          l10n.profileSignout,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
        ),
        onTap: () async {
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
                    backgroundColor: theme.colorScheme.error,
                  ),
                  child: Text(l10n.profileSignOutAction),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await context.read<SmartCropsService>().signOut();
            if (context.mounted) {
              context.go('/auth');
            }
          }
        },
      ),
    );
  }
}