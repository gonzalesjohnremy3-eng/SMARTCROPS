import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/smart_crops_service.dart';
import 'auth_screen.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _farmNameController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<SmartCropsService>(context, listen: false).currentUserProfile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _farmNameController = TextEditingController(text: profile?.farmName ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<SmartCropsService>(context, listen: false);
      await service.updateProfile(
        _nameController.text.trim(),
        _farmNameController.text.trim(),
        _locationController.text.trim(),
        _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          final profile = service.currentUserProfile;
          final selectedCrops = service.userSelectedCrops;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Profile Card
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 46,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.person, size: 50, color: primaryGreen),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile?.fullName ?? 'Farmer',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.email ?? 'farmer@smartcrops.org',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details Form / Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Edit Profile Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _farmNameController,
                                decoration: const InputDecoration(labelText: 'Farm Name', border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _locationController,
                                decoration: const InputDecoration(labelText: 'Location / Region', border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Farm Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                              const Divider(height: 20),
                              _ProfileInfoRow(icon: Icons.agriculture, label: 'Farm Name', value: profile?.farmName ?? 'Not specified'),
                              const SizedBox(height: 12),
                              _ProfileInfoRow(icon: Icons.location_on, label: 'Location', value: profile?.location ?? 'Philippines'),
                              const SizedBox(height: 12),
                              _ProfileInfoRow(icon: Icons.phone, label: 'Phone Number', value: profile?.phoneNumber ?? 'Not provided'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Managed Main Crops Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Managed Main Crops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 16, color: primaryGreen),
                              label: const Text('Manage', style: TextStyle(color: primaryGreen)),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        selectedCrops.isEmpty
                            ? const Text('No main crops selected yet. Click Manage to add crops.', style: TextStyle(color: Colors.grey, fontSize: 13))
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedCrops.map((crop) {
                                  return Chip(
                                    avatar: const CircleAvatar(backgroundColor: Color(0xFFC8E6C9), child: Icon(Icons.eco, size: 14, color: primaryGreen)),
                                    label: Text(crop.cropName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    backgroundColor: const Color(0xFFE8F5E9),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await service.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}
