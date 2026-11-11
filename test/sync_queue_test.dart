import 'package:flutter_test/flutter_test.dart';

class SyncAction {
  final String id;
  final String actionType;
  final Map<String, dynamic> payload;
  int retryCount;

  SyncAction({
    required this.id,
    required this.actionType,
    required this.payload,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action_type': actionType,
    'payload': payload,
    'retry_count': retryCount,
  };

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'],
      actionType: json['action_type'],
      payload: json['payload'],
      retryCount: json['retry_count'] ?? 0,
    );
  }
}

class MockSyncQueueManager {
  final List<SyncAction> _queue = [];

  List<SyncAction> get queue => List.unmodifiable(_queue);

  void enqueue(SyncAction action) {
    _queue.add(action);
  }

  Future<int> processQueue(Future<bool> Function(SyncAction action) syncHandler) async {
    int syncedCount = 0;
    final failedActions = <SyncAction>[];

    for (var action in _queue) {
      final success = await syncHandler(action);
      if (success) {
        syncedCount++;
      } else {
        action.retryCount++;
        if (action.retryCount < 3) {
          failedActions.add(action);
        }
      }
    }

    _queue.clear();
    _queue.addAll(failedActions);
    return syncedCount;
  }
}

void main() {
  group('Sync Queue Manager TDD - Seam: Offline Mutation Queue & Retry', () {
    test('enqueues actions correctly and processes in FIFO order', () async {
      final manager = MockSyncQueueManager();
      manager.enqueue(SyncAction(id: '1', actionType: 'COMPLETE_CALENDAR', payload: {'event_id': 'e1'}));
      manager.enqueue(SyncAction(id: '2', actionType: 'SAVE_CROP', payload: {'crop_id': 'c1'}));

      expect(manager.queue.length, 2);
      expect(manager.queue[0].id, '1');

      final processedCount = await manager.processQueue((action) async => true);
      expect(processedCount, 2);
      expect(manager.queue.isEmpty, true);
    });

    test('retries failed actions up to 3 times before discarding', () async {
      final manager = MockSyncQueueManager();
      manager.enqueue(SyncAction(id: '1', actionType: 'TEST', payload: {}));

      // Simulate failure on first attempt
      var processedCount = await manager.processQueue((action) async => false);
      expect(processedCount, 0);
      expect(manager.queue.length, 1);
      expect(manager.queue[0].retryCount, 1);

      // Simulate success on second attempt
      processedCount = await manager.processQueue((action) async => true);
      expect(processedCount, 1);
      expect(manager.queue.isEmpty, true);
    });
  });
}
