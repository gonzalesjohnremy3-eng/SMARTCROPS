import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/models/app_models.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.category,
    required this.scheduledDate,
    this.cropId,
    this.priority = 'Normal',
  });

  final String title;
  final String category;
  final DateTime scheduledDate;
  final String? cropId;
  final String priority;

  factory TaskDraft.fromEvent(CropCalendarEvent event) {
    return TaskDraft(
      title: event.eventTitle,
      category: event.eventCategory,
      scheduledDate: event.scheduledDate,
      cropId: event.cropId,
      priority: event.priority,
    );
  }

  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'crop_id': cropId,
      'event_title': title,
      'event_category': category,
      'scheduled_date': scheduledDate.toIso8601String(),
      'is_completed': false,
      'priority': priority,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'crop_id': cropId,
      'event_title': title,
      'event_category': category,
      'scheduled_date': scheduledDate.toIso8601String(),
      'priority': priority,
    };
  }

  TaskDraft copyWith({
    String? title,
    String? category,
    DateTime? scheduledDate,
    String? cropId,
    String? priority,
  }) {
    return TaskDraft(
      title: title ?? this.title,
      category: category ?? this.category,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      cropId: cropId ?? this.cropId,
      priority: priority ?? this.priority,
    );
  }

  String? validate() {
    if (title.trim().isEmpty) return 'title_required';
    return null;
  }

  static TaskDraft followUpForScan({
    required ScanHistoryItem scan,
    required String title,
    String? cropId,
    required DateTime now,
  }) {
    final sev = diagnosisSeverity(scan.diseaseDetected);
    final daysToAdd = sev == DiagnosisSeverity.atRisk ? 3 : (sev == DiagnosisSeverity.watch ? 7 : 14);
    final priority = sev == DiagnosisSeverity.atRisk ? 'High' : 'Normal';
    final category = sev == DiagnosisSeverity.healthy ? 'General' : 'Pest Control';

    return TaskDraft(
      title: title,
      category: category,
      scheduledDate: now.add(Duration(days: daysToAdd)),
      cropId: cropId,
      priority: priority,
    );
  }
}
