import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/smart_crops_service.dart';

class PersonalizedCropCalendarScreen extends StatelessWidget {
  const PersonalizedCropCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Personalized Crop Calendar'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          final events = service.calendarEvents;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFE8F5E9),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: primaryGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Your Unique Farm Timeline',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryGreen),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Smartly adapted to your main crops, scan history, and live weather conditions.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: events.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No calendar events generated yet. Select your main crops in profile settings to activate your personalized schedule.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(event.scheduledDate);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: CheckboxListTile(
                              title: Text(
                                event.eventTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                                  color: event.isCompleted ? Colors.grey : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(event.eventCategory),
                                        backgroundColor: const Color(0xFFE8F5E9),
                                        labelStyle: const TextStyle(color: primaryGreen, fontSize: 10),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      const SizedBox(width: 8),
                                      if (event.priority == 'Weather-Adjusted')
                                        const Chip(
                                          label: Text('Weather-Adjusted'),
                                          backgroundColor: Colors.orangeAccent,
                                          labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Scheduled: $formattedDate', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              value: event.isCompleted,
                              activeColor: primaryGreen,
                              onChanged: (val) {
                                if (val != null) {
                                  service.toggleCalendarEventCompletion(event.id, val);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
