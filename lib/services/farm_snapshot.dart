import '../models/app_models.dart';

class FarmSnapshot {
  FarmSnapshot({
    required this.availableCrops,
    required this.userCrops,
    required this.scanHistory,
    required this.notifications,
    required this.calendarEvents,
    required this.fetchedAt,
    this.profile,
  });

  final List<CropItem> availableCrops;
  final List<CropItem> userCrops;
  final List<ScanHistoryItem> scanHistory;
  final List<AppNotification> notifications;
  final List<CropCalendarEvent> calendarEvents;
  final DateTime fetchedAt;
  final UserProfile? profile;

  Map<String, dynamic> toJson() => {
        'availableCrops': availableCrops.map((c) => c.toJson()).toList(),
        'userCrops': userCrops.map((c) => c.toJson()).toList(),
        'scanHistory': scanHistory.map((s) => s.toJson()).toList(),
        'notifications': notifications.map((n) => n.toJson()).toList(),
        'calendarEvents': calendarEvents.map((e) => e.toJson()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
        if (profile != null) 'profile': profile!.toJson(),
      };

  factory FarmSnapshot.fromJson(Map<String, dynamic> json) {
    List<T> parse<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = json[key] as List? ?? const [];
      return raw
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return FarmSnapshot(
      availableCrops: parse('availableCrops', CropItem.fromJson),
      userCrops: parse('userCrops', CropItem.fromJson),
      scanHistory: parse('scanHistory', ScanHistoryItem.fromJson),
      notifications: parse('notifications', AppNotification.fromJson),
      calendarEvents: parse('calendarEvents', CropCalendarEvent.fromJson),
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'])
          : DateTime.now(),
      profile: json['profile'] != null
          ? UserProfile.fromJson(Map<String, dynamic>.from(json['profile'] as Map))
          : null,
    );
  }
}
