import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import 'package:smart_crops/models/app_models.dart';

void main() {
  group('TaskDraft Domain Logic', () {
    test('validates empty title', () {
      final draft = TaskDraft(
        title: '   ',
        category: 'Nutrition',
        scheduledDate: DateTime(2026, 5, 10),
      );
      expect(draft.validate(), 'title_required');
    });

    test('followUpForScan sets correct priority and timing based on severity', () {
      final scan = ScanHistoryItem(
        id: '1',
        userId: 'u',
        imageUrl: 'url',
        diseaseDetected: 'Bacterial Blight',
        confidenceScore: 90,
        commonCrop: 'Tomato',
        recommendedActions: const [],
        scannedAt: DateTime(2026, 5, 10),
      );

      final draft = TaskDraft.followUpForScan(
        scan: scan,
        title: 'Recheck Tomato',
        cropId: 'crop-1',
        now: DateTime(2026, 5, 10),
      );

      expect(draft.priority, 'High');
      expect(draft.scheduledDate, DateTime(2026, 5, 13)); // 3 days for at-risk
      expect(draft.category, 'Pest Control');
    });
  });
}
