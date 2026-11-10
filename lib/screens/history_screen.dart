import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/smart_crops_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Scan History & Past Reviews'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          final history = service.scanHistory;

          if (history.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No scan history found. Use the Scan Crop module to analyze your farm health.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(item.scannedAt);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.commonCrop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryGreen)),
                          Chip(
                            label: Text('${item.confidenceScore}% Confidence'),
                            backgroundColor: const Color(0xFFE8F5E9),
                            labelStyle: const TextStyle(color: primaryGreen, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Diagnosis: ${item.diseaseDetected}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      const SizedBox(height: 4),
                      Text('Scanned at: $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Divider(height: 20),
                      const Text('Recommended Actions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 4),
                      ...(item.recommendedActions.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(action.toString(), style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        );
                      })),
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
