import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    final recommendations = [
      {
        'title': 'Preventive Fungal Management',
        'category': 'Disease Control',
        'description': 'With current humid conditions (28°C), apply organic neem oil spray during early morning hours to prevent powdery mildew and leaf spot.'
      },
      {
        'title': 'Optimal Irrigation Schedule',
        'category': 'Water Management',
        'description': 'Water crops deeply but less frequently to encourage deep root growth. Avoid overhead watering late in the evening.'
      },
      {
        'title': 'Soil Enrichment & Fertilization',
        'category': 'Nutrition',
        'description': 'Incorporate well-composted organic matter into topsoil bi-weekly to maintain high microbial activity and nutrient uptake.'
      },
      {
        'title': 'Companion Planting Strategy',
        'category': 'Pest Prevention',
        'description': 'Plant marigolds alongside your vegetable crops to naturally repel destructive nematodes and aphids.'
      },
    ];

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Tailored Recommendations'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rec['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
                      Chip(
                        label: Text(rec['category']!),
                        backgroundColor: const Color(0xFFE8F5E9),
                        labelStyle: const TextStyle(color: primaryGreen, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(rec['description']!, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
