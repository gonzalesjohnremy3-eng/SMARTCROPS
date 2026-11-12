import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/scan/domain/scan_queue.dart';

class MemoryScanQueueStore implements ScanQueueStore {
  List<QueuedScan> items = [];

  @override
  Future<List<QueuedScan>> load() async => List.of(items);

  @override
  Future<void> save(List<QueuedScan> items) async {
    this.items = List.of(items);
  }
}

class FakeUploader implements ScanUploader {
  int calls = 0;

  @override
  Future<String> upload(String localImagePath) async {
    calls++;
    return 'https://storage.example/scan.jpg';
  }
}

class FailingUploader implements ScanUploader {
  FailingUploader({this.error = 'offline'});

  final String error;
  int calls = 0;

  @override
  Future<String> upload(String localImagePath) async {
    calls++;
    throw Exception(error);
  }
}

class FakeAnalyzer implements ScanAnalyzer {
  int calls = 0;

  @override
  Future<String> analyze({
    required String imageUrl,
    required String cropName,
  }) async {
    calls++;
    return 'result-1';
  }
}

void main() {
  test('enqueue persists a queued scan', () async {
    final store = MemoryScanQueueStore();
    final queue = ScanQueue(
      store: store,
      uploader: FakeUploader(),
      analyzer: FakeAnalyzer(),
      clock: () => DateTime(2026, 11, 12, 8),
      idGenerator: () => 'scan-1',
    );

    final item = await queue.enqueue(
      localImagePath: '/tmp/leaf.jpg',
      cropName: 'Pechay',
    );

    expect(item.id, 'scan-1');
    expect(item.status, QueuedScanStatus.queued);
    expect(item.cropName, 'Pechay');
    expect(store.items.single.id, 'scan-1');
  });

  test('processing uploads, analyzes, and completes a queued scan', () async {
    final store = MemoryScanQueueStore();
    final uploader = FakeUploader();
    final analyzer = FakeAnalyzer();
    final queue = ScanQueue(
      store: store,
      uploader: uploader,
      analyzer: analyzer,
      clock: () => DateTime(2026, 11, 12, 8),
      idGenerator: () => 'scan-1',
    );
    await queue.enqueue(
      localImagePath: '/tmp/leaf.jpg',
      cropName: 'Pechay',
    );

    await queue.processPending();

    expect(uploader.calls, 1);
    expect(analyzer.calls, 1);
    expect(store.items.single.status, QueuedScanStatus.completed);
    expect(store.items.single.resultId, 'result-1');
  });

  test('overlapping processing never uploads the same scan twice', () async {
    final store = MemoryScanQueueStore();
    final uploader = FakeUploader();
    final queue = ScanQueue(
      store: store,
      uploader: uploader,
      analyzer: FakeAnalyzer(),
      clock: () => DateTime(2026, 11, 12, 8),
      idGenerator: () => 'scan-1',
    );
    await queue.enqueue(
      localImagePath: '/tmp/leaf.jpg',
      cropName: 'Pechay',
    );

    await Future.wait([
      queue.processPending(),
      queue.processPending(),
    ]);

    expect(uploader.calls, 1);
    expect(store.items.single.status, QueuedScanStatus.completed);
  });

  test('a failed upload backs off and keeps the scan', () async {
    var now = DateTime(2026, 11, 12, 8);
    final store = MemoryScanQueueStore();
    final uploader = FailingUploader();
    final queue = ScanQueue(
      store: store,
      uploader: uploader,
      analyzer: FakeAnalyzer(),
      clock: () => now,
      idGenerator: () => 'scan-1',
    );
    await queue.enqueue(
      localImagePath: '/tmp/leaf.jpg',
      cropName: 'Pechay',
    );

    await queue.processPending();

    expect(store.items.single.status, QueuedScanStatus.failed);
    expect(store.items.single.attempts, 1);
    expect(store.items.single.nextAttemptAt, now.add(const Duration(seconds: 30)));
    expect(store.items.single.failureReason, contains('offline'));
    expect(store.items.single.localImagePath, '/tmp/leaf.jpg');
    expect(store.items.single.isPermanentFailure, isFalse);

    await queue.processPending();
    expect(uploader.calls, 1);

    now = now.add(const Duration(seconds: 30));
    await queue.processPending();
    expect(uploader.calls, 2);
    expect(store.items.single.attempts, 2);
    expect(store.items.single.nextAttemptAt, now.add(const Duration(minutes: 2)));

    now = now.add(const Duration(minutes: 2));
    await queue.processPending();
    expect(uploader.calls, 3);
    expect(store.items.single.attempts, 3);
    expect(store.items.single.isPermanentFailure, isTrue);
    expect(store.items.single.nextAttemptAt, isNull);
  });

  test('a permanent failure can be retried manually', () async {
    final store = MemoryScanQueueStore()
      ..items = [
        QueuedScan(
          id: 'scan-1',
          localImagePath: '/tmp/leaf.jpg',
          cropName: 'Pechay',
          createdAt: DateTime(2026, 11, 12, 8),
          status: QueuedScanStatus.failed,
          attempts: 3,
          failureReason: 'offline',
          isPermanentFailure: true,
        ),
      ];
    final uploader = FakeUploader();
    final queue = ScanQueue(
      store: store,
      uploader: uploader,
      analyzer: FakeAnalyzer(),
      clock: () => DateTime(2026, 11, 12, 9),
    );

    await queue.retry('scan-1');

    expect(store.items.single.status, QueuedScanStatus.queued);
    expect(store.items.single.attempts, 0);
    expect(store.items.single.isPermanentFailure, isFalse);
    expect(store.items.single.nextAttemptAt, isNull);

    await queue.processPending();
    expect(uploader.calls, 1);
    expect(store.items.single.status, QueuedScanStatus.completed);
  });

  test('deleting a queued scan removes it explicitly', () async {
    final store = MemoryScanQueueStore();
    final queue = ScanQueue(
      store: store,
      uploader: FakeUploader(),
      analyzer: FakeAnalyzer(),
      clock: () => DateTime(2026, 11, 12, 8),
      idGenerator: () => 'scan-1',
    );
    await queue.enqueue(
      localImagePath: '/tmp/leaf.jpg',
      cropName: 'Pechay',
    );

    await queue.delete('scan-1');

    expect(store.items, isEmpty);
  });
}
