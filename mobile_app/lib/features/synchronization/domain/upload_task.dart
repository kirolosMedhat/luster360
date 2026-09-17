enum UploadTaskStatus {
  capturing,
  rendering,
  localOnly,
  queued,
  uploading,
  synced,
  uploaded,
  verifying,
  ready,
  failed,
  paused,
}

class UploadTask {
  final String id;
  final String videoId;
  final String eventId;
  final String localVideoPath;
  final String? localThumbnailPath;
  final UploadTaskStatus status;
  final double progress; // 0.0 to 1.0
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? completedAt;

  const UploadTask({
    required this.id,
    required this.videoId,
    required this.eventId,
    required this.localVideoPath,
    this.localThumbnailPath,
    this.status = UploadTaskStatus.queued,
    this.progress = 0.0,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    this.completedAt,
  });

  bool get isLocalOnly => status == UploadTaskStatus.localOnly;
  bool get isSynced => status == UploadTaskStatus.synced || status == UploadTaskStatus.ready;

  UploadTask copyWith({
    UploadTaskStatus? status,
    double? progress,
    int? retryCount,
    String? lastError,
    DateTime? completedAt,
  }) {
    return UploadTask(
      id: id,
      videoId: videoId,
      eventId: eventId,
      localVideoPath: localVideoPath,
      localThumbnailPath: localThumbnailPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
