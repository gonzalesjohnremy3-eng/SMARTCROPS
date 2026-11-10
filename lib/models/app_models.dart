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
}
