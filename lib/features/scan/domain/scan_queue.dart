const scanQueueMaxAttempts = 3;

enum QueuedScanStatus { queued, uploading, analyzing, completed, failed }

class QueuedScan {
  const QueuedScan({
    required this.id,
    required this.localImagePath,
    required this.cropName,
    required this.createdAt,
    required this.status,
    this.attempts = 0,
    this.nextAttemptAt,
    this.resultId,
    this.failureReason,
    this.isPermanentFailure = false,
  });

  final String id;
  final String localImagePath;
  final String cropName;
  final DateTime createdAt;
  final QueuedScanStatus status;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? resultId;
  final String? failureReason;
  final bool isPermanentFailure;

  static const Object _unset = Object();

  Map<String, Object?> toJson() => {
    'id': id,
    'localImagePath': localImagePath,
    'cropName': cropName,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'attempts': attempts,
    'nextAttemptAt': nextAttemptAt?.toIso8601String(),
    'resultId': resultId,
    'failureReason': failureReason,
    'isPermanentFailure': isPermanentFailure,
  };

  factory QueuedScan.fromJson(Map<String, Object?> json) {
    return QueuedScan(
      id: json['id'] as String,
      localImagePath: json['localImagePath'] as String,
      cropName: json['cropName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: QueuedScanStatus.values.byName(json['status'] as String),
      attempts: json['attempts'] as int? ?? 0,
      nextAttemptAt: json['nextAttemptAt'] == null
          ? null
          : DateTime.parse(json['nextAttemptAt'] as String),
      resultId: json['resultId'] as String?,
      failureReason: json['failureReason'] as String?,
      isPermanentFailure: json['isPermanentFailure'] as bool? ?? false,
    );
  }

  QueuedScan copyWith({
    String? id,
    String? localImagePath,
    String? cropName,
    DateTime? createdAt,
    QueuedScanStatus? status,
    int? attempts,
    Object? nextAttemptAt = _unset,
    Object? resultId = _unset,
    Object? failureReason = _unset,
    bool? isPermanentFailure,
  }) {
    return QueuedScan(
      id: id ?? this.id,
      localImagePath: localImagePath ?? this.localImagePath,
      cropName: cropName ?? this.cropName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: identical(nextAttemptAt, _unset)
          ? this.nextAttemptAt
          : nextAttemptAt as DateTime?,
      resultId: identical(resultId, _unset)
          ? this.resultId
          : resultId as String?,
      failureReason: identical(failureReason, _unset)
          ? this.failureReason
          : failureReason as String?,
      isPermanentFailure: isPermanentFailure ?? this.isPermanentFailure,
    );
  }
}

abstract class ScanQueueStore {
  Future<List<QueuedScan>> load();

  Future<void> save(List<QueuedScan> items);
}

abstract class ScanUploader {
  Future<String> upload(String localImagePath);
}

abstract class ScanAnalyzer {
  Future<String> analyze({
    required String imageUrl,
    required String cropName,
  });
}

typedef Clock = DateTime Function();
typedef IdGenerator = String Function();

class ScanQueue {
  ScanQueue({
    required this.store,
    required this.uploader,
    required this.analyzer,
    Clock? clock,
    IdGenerator? idGenerator,
  }) : clock = clock ?? DateTime.now,
       idGenerator =
           idGenerator ??
           (() => DateTime.now().microsecondsSinceEpoch.toString());

  final ScanQueueStore store;
  final ScanUploader uploader;
  final ScanAnalyzer analyzer;
  final Clock clock;
  final IdGenerator idGenerator;
  bool _isProcessing = false;

  Future<QueuedScan> enqueue({
    required String localImagePath,
    required String cropName,
  }) async {
    final items = await store.load();
    final item = QueuedScan(
      id: idGenerator(),
      localImagePath: localImagePath,
      cropName: cropName,
      createdAt: clock(),
      status: QueuedScanStatus.queued,
    );
    items.add(item);
    await store.save(items);
    return item;
  }

  Future<void> processPending() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final items = await store.load();
      final now = clock();

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        if (!_isReady(item, now)) continue;

        items[index] = item.copyWith(status: QueuedScanStatus.uploading);
        await store.save(items);

        try {
          final imageUrl = await uploader.upload(item.localImagePath);
          items[index] = items[index].copyWith(
            status: QueuedScanStatus.analyzing,
          );
          await store.save(items);

          final resultId = await analyzer.analyze(
            imageUrl: imageUrl,
            cropName: item.cropName,
          );
          items[index] = items[index].copyWith(
            status: QueuedScanStatus.completed,
            resultId: resultId,
            isPermanentFailure: false,
          );
          await store.save(items);
        } catch (error) {
          final attempts = item.attempts + 1;
          final isPermanent = attempts >= scanQueueMaxAttempts;
          items[index] = items[index].copyWith(
            status: QueuedScanStatus.failed,
            attempts: attempts,
            nextAttemptAt: isPermanent
                ? null
                : now.add(_backoffFor(attempts)),
            failureReason: error.toString(),
            isPermanentFailure: isPermanent,
          );
          await store.save(items);
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> retry(String id) async {
    final items = await store.load();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    items[index] = items[index].copyWith(
      status: QueuedScanStatus.queued,
      attempts: 0,
      nextAttemptAt: null,
      failureReason: null,
      isPermanentFailure: false,
    );
    await store.save(items);
  }

  Future<void> delete(String id) async {
    final items = await store.load();
    items.removeWhere((item) => item.id == id);
    await store.save(items);
  }

  bool _isReady(QueuedScan item, DateTime now) {
    if (item.status == QueuedScanStatus.completed) return false;
    if (item.isPermanentFailure) return false;
    if (item.status == QueuedScanStatus.uploading ||
        item.status == QueuedScanStatus.analyzing) {
      return false;
    }
    final nextAttemptAt = item.nextAttemptAt;
    return nextAttemptAt == null || !nextAttemptAt.isAfter(now);
  }

  Duration _backoffFor(int attempts) {
    if (attempts <= 1) return const Duration(seconds: 30);
    if (attempts == 2) return const Duration(minutes: 2);
    return const Duration(minutes: 10);
  }
}
