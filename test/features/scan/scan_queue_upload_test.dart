import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/features/scan/domain/scan_queue.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemoryQueueStore implements ScanQueueStore {
  final List<QueuedScan> items = [];

  @override
  Future<List<QueuedScan>> load() async => List.of(items);

  @override
  Future<void> save(List<QueuedScan> value) async {
    items
      ..clear()
      ..addAll(value);
  }
}

class CountingUploader implements ScanUploader {
  int calls = 0;

  @override
  Future<String> upload(String localImagePath) async {
    calls++;
    return 'https://example.test/leaf.jpg';
  }
}

class StubAnalyzer implements ScanAnalyzer {
  @override
  Future<String> analyze({
    required String imageUrl,
    required String cropName,
  }) async => 'scan-1';
}

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

  test('enqueueScan uploads a captured image exactly once', () async {
    final store = MemoryQueueStore();
    final uploader = CountingUploader();
    final provider = ScanQueueProvider(
      store: store,
      service: SmartCropsService(),
      uploader: uploader,
      analyzer: StubAnalyzer(),
    );

    final queued = await provider.enqueueScan(
      localImagePath: '/tmp/leaf.jpg',
      cropName: 'Rice',
    );

    expect(queued, isTrue);
    expect(uploader.calls, 1);
    expect(store.items.single.status, QueuedScanStatus.completed);
  });
}
