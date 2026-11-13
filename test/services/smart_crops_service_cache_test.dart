import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/service_data_cache_store.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _FakeLoader implements FarmDataLoader {
  _FakeLoader({this.snapshot, this.error});

  final FarmSnapshot? snapshot;
  final Object? error;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async {
    if (error != null) throw error!;
    return snapshot?.availableCrops ?? const [];
  }

  @override
  Future<FarmSnapshot?> fetchFarmData() async {
    if (error != null) throw error!;
    return snapshot;
  }
}

CropItem _crop(String name) =>
    CropItem(id: name, cropName: name, optimalConditions: const {});

ScanHistoryItem _scan(String crop) => ScanHistoryItem(
      id: 'scan-$crop',
      userId: 'user-1',
      imageUrl: 'https://example.com/$crop.jpg',
      diseaseDetected: 'Healthy',
      confidenceScore: 96,
      commonCrop: crop,
      recommendedActions: const ['Keep monitoring'],
      scannedAt: DateTime(2026, 1, 1),
    );

AppNotification _notice(String title) => AppNotification(
      id: 'n-$title',
      userId: 'user-1',
      title: title,
      message: 'message',
      isRead: false,
      createdAt: DateTime(2026, 1, 1),
    );

CropCalendarEvent _event(String title) => CropCalendarEvent(
      id: 'e-$title',
      userId: 'user-1',
      eventTitle: title,
      eventCategory: 'Water Management',
      scheduledDate: DateTime(2026, 1, 2),
      isCompleted: false,
      priority: 'Normal',
    );

FarmSnapshot _snapshot({
  required List<CropItem> userCrops,
  required DateTime fetchedAt,
}) =>
    FarmSnapshot(
      availableCrops: [_crop('Tomato'), _crop('Pechay')],
      userCrops: userCrops,
      scanHistory: [_scan('Tomato')],
      notifications: [_notice('Weather alert')],
      calendarEvents: [_event('Water the field')],
      fetchedAt: fetchedAt,
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Already initialized.
    }
  });

  group('SmartCropsService cached surfaces', () {
    test('exposes the cached snapshot when the refresh fails', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ServiceDataCacheStore();
      final cachedAt = DateTime(2026, 1, 1, 8, 30);
      await store.save(_snapshot(
        userCrops: [_crop('Pechay')],
        fetchedAt: cachedAt,
      ));

      final service = SmartCropsService(
        supabase: Supabase.instance.client,
        cacheStore: store,
        loader: _FakeLoader(error: Exception('offline')),
      );

      await service.initializeUserData();

      expect(
        service.userSelectedCrops.map((c) => c.cropName),
        ['Pechay'],
        reason: 'the last cached selection should survive a failed refresh',
      );
      expect(service.calendarEvents.map((e) => e.eventTitle), ['Water the field']);
      expect(service.notifications.map((n) => n.title), ['Weather alert']);
      expect(service.scanHistory.map((s) => s.commonCrop), ['Tomato']);
      expect(service.errorMessage, isNull,
          reason: 'cached content means the user is not shown an error screen');
      expect(service.lastUpdated, cachedAt);
    });

    test('a successful refresh overwrites the cache', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ServiceDataCacheStore();
      await store.save(_snapshot(
        userCrops: [_crop('Pechay')],
        fetchedAt: DateTime(2026, 1, 1, 8, 30),
      ));
      final freshAt = DateTime(2026, 1, 2, 9, 0);
      final fresh = _snapshot(
        userCrops: [_crop('Tomato')],
        fetchedAt: freshAt,
      );

      final service = SmartCropsService(
        supabase: Supabase.instance.client,
        cacheStore: store,
        loader: _FakeLoader(snapshot: fresh),
      );

      await service.initializeUserData();

      expect(service.userSelectedCrops.map((c) => c.cropName), ['Tomato']);
      expect(service.lastUpdated, freshAt);

      final reloaded = await store.load();
      expect(reloaded, isNotNull);
      expect(reloaded!.userCrops.map((c) => c.cropName), ['Tomato'],
          reason: 'the cache should be rewritten after a successful refresh');
    });

    test('shows an error only when there is no cache to fall back on', () async {
      SharedPreferences.setMockInitialValues({});

      final service = SmartCropsService(
        supabase: Supabase.instance.client,
        cacheStore: ServiceDataCacheStore(),
        loader: _FakeLoader(error: Exception('offline')),
      );

      await service.initializeUserData();

      expect(service.errorMessage, isNotNull);
      expect(service.userSelectedCrops, isEmpty);
    });
  });
}
