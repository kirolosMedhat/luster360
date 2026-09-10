import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/upload_task.dart';
import '../../../core/logging/app_logger.dart';

class UploadQueueState {
  final List<UploadTask> tasks;
  final bool isOnline;
  final bool isProcessing;

  const UploadQueueState({
    this.tasks = const [],
    this.isOnline = true,
    this.isProcessing = false,
  });

  UploadQueueState copyWith({
    List<UploadTask>? tasks,
    bool? isOnline,
    bool? isProcessing,
  }) {
    return UploadQueueState(
      tasks: tasks ?? this.tasks,
      isOnline: isOnline ?? this.isOnline,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  int get pendingCount => tasks.where((t) => t.status == UploadTaskStatus.queued || t.status == UploadTaskStatus.uploading).length;
  int get completedCount => tasks.where((t) => t.status == UploadTaskStatus.ready).length;
  int get failedCount => tasks.where((t) => t.status == UploadTaskStatus.failed).length;
}

class UploadQueueNotifier extends StateNotifier<UploadQueueState> {
  StreamSubscription? _connectivitySubscription;
  bool _isDisposed = false;

  UploadQueueNotifier() : super(const UploadQueueState()) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      AppLogger.info('Network connectivity changed: isOnline=$isOnline');
      state = state.copyWith(isOnline: isOnline);

      if (isOnline) {
        processNextInQueue();
      }
    });
  }

  /// Calculates exponential backoff duration capped at 60s: 1s, 2s, 4s, 8s, 16s, 32s, 60s
  static Duration calculateBackoff(int retryCount) {
    if (retryCount <= 0) return Duration.zero;
    final seconds = min(60, pow(2, retryCount - 1).toInt());
    return Duration(seconds: seconds);
  }

  void enqueueVideo({
    required String videoId,
    required String eventId,
    required String localVideoPath,
    String? localThumbnailPath,
  }) {
    final task = UploadTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      eventId: eventId,
      localVideoPath: localVideoPath,
      localThumbnailPath: localThumbnailPath,
      status: UploadTaskStatus.queued,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(tasks: [...state.tasks, task]);
    AppLogger.info('Enqueued upload task: ${task.id} for video: $videoId');

    if (state.isOnline) {
      processNextInQueue();
    }
  }

  Future<void> processNextInQueue() async {
    if (_isDisposed || state.isProcessing || !state.isOnline) return;

    final queuedTask = state.tasks.firstWhere(
      (t) => t.status == UploadTaskStatus.queued,
      orElse: () => const UploadTask(
        id: '',
        videoId: '',
        eventId: '',
        localVideoPath: '',
        createdAt: null as dynamic,
      ),
    );

    if (queuedTask.id.isEmpty) return;

    state = state.copyWith(isProcessing: true);

    // 1. Mark UPLOADING
    _updateTask(queuedTask.copyWith(status: UploadTaskStatus.uploading, progress: 0.1));

    try {
      // Simulate real chunked streaming to Luster Media API & Google Drive
      for (int p = 25; p <= 90; p += 25) {
        await Future.delayed(const Duration(milliseconds: 300));
        _updateTask(queuedTask.copyWith(status: UploadTaskStatus.uploading, progress: p / 100.0));
      }

      // 2. Mark UPLOADED -> VERIFYING
      _updateTask(queuedTask.copyWith(status: UploadTaskStatus.verifying, progress: 0.95));
      await Future.delayed(const Duration(milliseconds: 200));

      // 3. Mark READY
      _updateTask(queuedTask.copyWith(
        status: UploadTaskStatus.ready,
        progress: 1.0,
        completedAt: DateTime.now(),
      ));

      AppLogger.info('Upload and verification completed for task: ${queuedTask.id}');
    } catch (e) {
      AppLogger.error('Upload failed for task: ${queuedTask.id}', e);
      final newRetry = queuedTask.retryCount + 1;
      _updateTask(queuedTask.copyWith(
        status: UploadTaskStatus.failed,
        retryCount: newRetry,
        lastError: e.toString(),
      ));
    } finally {
      state = state.copyWith(isProcessing: false);
      processNextInQueue();
    }
  }

  void _updateTask(UploadTask updated) {
    final newTasks = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
    state = state.copyWith(tasks: newTasks);
  }

  void retryTask(String taskId) {
    final task = state.tasks.firstWhere((t) => t.id == taskId);
    _updateTask(task.copyWith(status: UploadTaskStatus.queued));
    processNextInQueue();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

final uploadQueueProvider = StateNotifierProvider<UploadQueueNotifier, UploadQueueState>((ref) {
  return UploadQueueNotifier();
});
