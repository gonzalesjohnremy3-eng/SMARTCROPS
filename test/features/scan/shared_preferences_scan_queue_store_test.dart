import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/features/scan/data/shared_preferences_scan_queue_store.dart';
import 'package:smart_crops/features/scan/domain/scan_queue.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('the store round-trips queued scans through SharedPreferences', () async {
    final store = SharedPreferencesScanQueueStore();
    final original = [
      QueuedScan(
        id: 'scan-1',
        localImagePath: '/tmp/leaf.jpg',
        cropName: 'Pechay',
        createdAt: DateTime(2026, 11, 12, 8, 30),
        status: QueuedScanStatus.failed,
        attempts: 2,
        nextAttemptAt: DateTime(2026, 11, 12, 8, 32, 30),
        failureReason: 'offline',
        isPermanentFailure: false,
      ),
      QueuedScan(
        id: 'scan-2',
        localImagePath: '/tmp/tomato.jpg',
        cropName: 'Tomato',
        createdAt: DateTime(2026, 11, 12, 9),
        status: QueuedScanStatus.queued,
        attempts: 0,
      ),
    ];

    await store.save(original);

    expect(await store.load(), hasLength(2));

    final reloaded = await store.load();
    expect(reloaded.first.id, 'scan-1');
    expect(reloaded.first.cropName, 'Pechay');
    expect(reloaded.first.status, QueuedScanStatus.failed);
    expect(reloaded.first.attempts, 2);
    expect(reloaded.first.nextAttemptAt, DateTime(2026, 11, 12, 8, 32, 30));
    expect(reloaded.first.failureReason, 'offline');
    expect(reloaded.first.isPermanentFailure, isFalse);
    expect(reloaded.last.id, 'scan-2');
    expect(reloaded.last.status, QueuedScanStatus.queued);
  });

  test('the store exposes an empty queue when nothing is persisted', () async {
    final store = SharedPreferencesScanQueueStore();
    expect(await store.load(), isEmpty);
  });
}
