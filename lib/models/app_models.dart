class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? farmName;
  final String? location;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.farmName,
    this.location,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? 'Farmer',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      farmName: json['farm_name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone_number': phoneNumber,
    'farm_name': farmName,
    'location': location,
  };
}

class CropItem {
  final String id;
  final String cropName;
  final Map<String, dynamic> optimalConditions;

  CropItem({
    required this.id,
    required this.cropName,
    required this.optimalConditions,
  });

  factory CropItem.fromJson(Map<String, dynamic> json) {
    return CropItem(
      id: json['id'] ?? '',
      cropName: json['crop_name'] ?? '',
      optimalConditions: json['optimal_conditions'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop_name': cropName,
        'optimal_conditions': optimalConditions,
      };
}

class ScanHistoryItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String diseaseDetected;
  final double confidenceScore;
  final String commonCrop;
  final List<dynamic> recommendedActions;
  final DateTime scannedAt;

  ScanHistoryItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diseaseDetected,
    required this.confidenceScore,
    required this.commonCrop,
    required this.recommendedActions,
    required this.scannedAt,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      diseaseDetected: json['disease_detected'] ?? 'Unknown',
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      commonCrop: json['common_crop'] ?? 'Pechay',
      recommendedActions: json['recommended_actions'] ?? [],
      scannedAt: json['scanned_at'] != null ? DateTime.parse(json['scanned_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'image_url': imageUrl,
        'disease_detected': diseaseDetected,
        'confidence_score': confidenceScore,
        'common_crop': commonCrop,
        'recommended_actions': recommendedActions,
        'scanned_at': scannedAt.toIso8601String(),
      };
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? scanId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.scanId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      scanId: json['scan_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'message': message,
        'scan_id': scanId,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };
}

class WeatherCondition {
  final String locationName;
  final double temperature;
  final String condition;
  final int humidity;
  final String iconCode;
  final double precipitationMm;

  WeatherCondition({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.iconCode,
    this.precipitationMm = 0,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      locationName: json['locationName'] ?? 'Farm Location',
      temperature: (json['temperature'] ?? 28.0).toDouble(),
      condition: json['condition'] ?? 'Sunny',
      humidity: json['humidity'] ?? 70,
      iconCode: json['iconCode'] ?? '01d',
      precipitationMm: (json['precipitationMm'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'locationName': locationName,
    'temperature': temperature,
    'condition': condition,
    'humidity': humidity,
    'iconCode': iconCode,
    'precipitationMm': precipitationMm,
  };
}

class CropCalendarEvent {
  final String id;
  final String userId;
  final String? cropId;
  final String eventTitle;
  final String eventCategory;
  final DateTime scheduledDate;
  final bool isCompleted;
  final String priority;

  CropCalendarEvent({
    required this.id,
    required this.userId,
    this.cropId,
    required this.eventTitle,
    required this.eventCategory,
    required this.scheduledDate,
    required this.isCompleted,
    required this.priority,
  });

  factory CropCalendarEvent.fromJson(Map<String, dynamic> json) {
    return CropCalendarEvent(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      cropId: json['crop_id'],
      eventTitle: json['event_title'] ?? '',
      eventCategory: json['event_category'] ?? 'General',
      scheduledDate: json['scheduled_date'] != null ? DateTime.parse(json['scheduled_date']) : DateTime.now(),
      isCompleted: json['is_completed'] ?? false,
      priority: json['priority'] ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'crop_id': cropId,
    'event_title': eventTitle,
    'event_category': eventCategory,
    'scheduled_date': scheduledDate.toIso8601String(),
    'is_completed': isCompleted,
    'priority': priority,
  };
}
