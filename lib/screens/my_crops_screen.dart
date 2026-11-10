import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/smart_crops_service.dart';

class MyCropsScreen extends StatelessWidget {
  const MyCropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('My Crops & Care Guides'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          final userCrops = service.userSelectedCrops;

          if (userCrops.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No main crops selected yet. Please configure your crops in profile settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userCrops.length,
            itemBuilder: (context, index) {
              final crop = userCrops[index];
              final conditions = crop.optimalConditions;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.eco, color: primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            crop.cropName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('Optimal Growing Conditions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      _ConditionRow(label: 'Temperature Range', value: conditions['temperature_range'] ?? 'N/A'),
                      _ConditionRow(label: 'Soil Requirements', value: conditions['soil'] ?? 'N/A'),
                      _ConditionRow(label: 'Watering Guide', value: conditions['watering'] ?? 'N/A'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConditionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        ],
      ),
    );
  }
}
