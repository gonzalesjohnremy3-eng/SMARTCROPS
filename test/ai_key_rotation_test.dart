import 'package:flutter_test/flutter_test.dart';

class AiKeyRecord {
  final String id;
  final String provider;
  final String apiKeyEncrypted;
  final int dailyQuotaLimit;
  final int currentUsageCount;
  final bool isActive;

  AiKeyRecord({
    required this.id,
    required this.provider,
    required this.apiKeyEncrypted,
    required this.dailyQuotaLimit,
    required this.currentUsageCount,
    required this.isActive,
  });

  factory AiKeyRecord.fromJson(Map<String, dynamic> json) {
    return AiKeyRecord(
      id: json['id'],
      provider: json['provider'],
      apiKeyEncrypted: json['api_key_encrypted'],
      dailyQuotaLimit: json['daily_quota_limit'] ?? 100,
      currentUsageCount: json['current_usage_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

// Key rotation algorithm matching Supabase Edge Function logic
AiKeyRecord? selectNextAvailableKey(List<AiKeyRecord> keys) {
  final activeKeys = keys.where((k) => k.isActive && k.currentUsageCount < k.dailyQuotaLimit).toList();
  if (activeKeys.isEmpty) return null;

  // Sort by lowest usage count ascending
  activeKeys.sort((a, b) => a.currentUsageCount.compareTo(b.currentUsageCount));
  return activeKeys.first;
}

void main() {
  group('Multi-API Key Rotation Engine Tests', () {
    test('selects active key with lowest usage count under quota limit', () {
      final keys = [
        AiKeyRecord(id: '1', provider: 'Gemini', apiKeyEncrypted: 'key1', dailyQuotaLimit: 250, currentUsageCount: 1, isActive: true),
        AiKeyRecord(id: '2', provider: 'Gemini', apiKeyEncrypted: 'key2', dailyQuotaLimit: 250, currentUsageCount: 0, isActive: true),
        AiKeyRecord(id: '3', provider: 'OpenAI', apiKeyEncrypted: 'key3', dailyQuotaLimit: 100, currentUsageCount: 0, isActive: true),
      ];

      final selected = selectNextAvailableKey(keys);
      expect(selected, isNotNull);
      // Should pick lowest usage count (0), among those with 0 usage, first one ('2' or '3')
      expect(selected!.currentUsageCount, 0);
      expect(selected.id, '2');
    });

    test('ignores inactive keys or keys at quota limit', () {
      final keys = [
        AiKeyRecord(id: '1', provider: 'Gemini', apiKeyEncrypted: 'key1', dailyQuotaLimit: 100, currentUsageCount: 100, isActive: true), // at quota
        AiKeyRecord(id: '2', provider: 'OpenAI', apiKeyEncrypted: 'key2', dailyQuotaLimit: 100, currentUsageCount: 5, isActive: false), // inactive
        AiKeyRecord(id: '3', provider: 'Gemini', apiKeyEncrypted: 'key3', dailyQuotaLimit: 250, currentUsageCount: 12, isActive: true), // valid
      ];

      final selected = selectNextAvailableKey(keys);
      expect(selected, isNotNull);
      expect(selected!.id, '3');
      expect(selected.currentUsageCount, 12);
    });

    test('returns null when all keys exhausted or inactive', () {
      final keys = [
        AiKeyRecord(id: '1', provider: 'Gemini', apiKeyEncrypted: 'key1', dailyQuotaLimit: 100, currentUsageCount: 100, isActive: true),
        AiKeyRecord(id: '2', provider: 'OpenAI', apiKeyEncrypted: 'key2', dailyQuotaLimit: 100, currentUsageCount: 50, isActive: false),
      ];

      final selected = selectNextAvailableKey(keys);
      expect(selected, isNull);
    });
  });
}
