import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/smart_crops_service.dart';
import 'dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final Set<String> _selectedCropIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<SmartCropsService>(context, listen: false);
      for (var crop in service.userSelectedCrops) {
        _selectedCropIds.add(crop.id);
      }
      setState(() {});
    });
  }

  Future<void> _saveAndProceed() async {
    if (_selectedCropIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one main crop for personalized AI monitoring.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final service = Provider.of<SmartCropsService>(context, listen: false);
      await service.saveUserCrops(_selectedCropIds.toList());
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving crops: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Select Your Main Crops'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          if (service.isLoading && service.availableCrops.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen));
          }

          final crops = service.availableCrops;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose the crops you cultivate',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select multiple main crops to receive tailored disease detection models, weather advisories, and pest prevention guidelines.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: crops.isEmpty
                      ? const Center(child: Text('No crops found in catalog.'))
                      : ListView.builder(
                          itemCount: crops.length,
                          itemBuilder: (context, index) {
                            final crop = crops[index];
                            final isSelected = _selectedCropIds.contains(crop.id);
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: CheckboxListTile(
                                title: Text(crop.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text(
                                  'Optimal: ${crop.optimalConditions['temperature_range'] ?? 'Standard'}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                secondary: const CircleAvatar(
                                  backgroundColor: Color(0xFFE8F5E9),
                                  child: Icon(Icons.eco, color: primaryGreen),
                                ),
                                value: isSelected,
                                activeColor: primaryGreen,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedCropIds.add(crop.id);
                                    } else {
                                      _selectedCropIds.remove(crop.id);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
