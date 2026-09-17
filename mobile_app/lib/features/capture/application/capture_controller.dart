import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/capture_state.dart';
import '../../camera/data/phone_camera_device.dart';
import '../../editor/domain/speed_ramp_config.dart';
import '../../rendering/application/rendering_service.dart';
import '../../synchronization/application/upload_queue_service.dart';
import '../../../core/logging/app_logger.dart';

class CaptureNotifier extends StateNotifier<CaptureState> {
  final PhoneCameraDevice cameraDevice;
  final RenderingService renderingService;
  final UploadQueueNotifier? uploadQueueNotifier;
  Timer? _countdownTimer;
  Timer? _recordingTimer;
  Timer? _autoReturnTimer;

  CaptureNotifier(
    this.cameraDevice, {
    RenderingService? renderingService,
    this.uploadQueueNotifier,
  })  : renderingService = renderingService ?? RenderingService(),
        super(const CaptureState()) {
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await cameraDevice.connect();
      state = state.copyWith(
        workflowState: CaptureWorkflowState.ready,
        isTorchOn: cameraDevice.isTorchOn,
      );
    } catch (e) {
      AppLogger.error('Error connecting camera', e);
      state = state.copyWith(
        workflowState: CaptureWorkflowState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setCountdownDuration(int seconds) {
    state = state.copyWith(
      totalCountdownSeconds: seconds,
      countdownRemaining: seconds,
    );
  }

  void setRecordingDuration(int seconds) {
    state = state.copyWith(recordingDurationSeconds: seconds);
  }

  Future<void> toggleTorch() async {
    final newState = !state.isTorchOn;
    await cameraDevice.setTorch(newState);
    state = state.copyWith(isTorchOn: newState);
  }

  /// Starts the Booth capture loop: COUNTDOWN -> RECORDING -> PROCESSING -> RENDERING -> READY_TO_SHARE
  Future<void> startCaptureSession() async {
    if (state.workflowState != CaptureWorkflowState.ready) return;

    _autoReturnTimer?.cancel();
    state = state.copyWith(
      workflowState: CaptureWorkflowState.countdown,
      countdownRemaining: state.totalCountdownSeconds,
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      HapticFeedback.mediumImpact();
      final remaining = state.countdownRemaining - 1;

      if (remaining <= 0) {
        timer.cancel();
        await _beginRecording();
      } else {
        state = state.copyWith(countdownRemaining: remaining);
      }
    });
  }

  Future<void> _beginRecording() async {
    try {
      HapticFeedback.heavyImpact();
      await cameraDevice.startRecording();

      state = state.copyWith(
        workflowState: CaptureWorkflowState.recording,
        elapsedRecordingSeconds: 0,
      );

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final elapsed = state.elapsedRecordingSeconds + 1;
        state = state.copyWith(elapsedRecordingSeconds: elapsed);

        if (elapsed >= state.recordingDurationSeconds) {
          timer.cancel();
          await _finishRecording();
        }
      });
    } catch (e) {
      AppLogger.error('Recording start failed', e);
      state = state.copyWith(
        workflowState: CaptureWorkflowState.error,
        errorMessage: 'Recording failed: $e',
      );
    }
  }

  Future<void> _finishRecording() async {
    try {
      state = state.copyWith(workflowState: CaptureWorkflowState.processing);
      final captureResult = await cameraDevice.stopRecording();
      AppLogger.info('Captured raw video: ${captureResult.filePath}');

      state = state.copyWith(
        lastCaptureResult: captureResult,
        workflowState: CaptureWorkflowState.rendering,
        renderProgress: 0.15,
      );

      final rawPath = captureResult.filePath;
      final outputCompositePath = rawPath.endsWith('.mp4')
          ? rawPath.replaceAll('.mp4', '_composite.mp4')
          : '${rawPath}_composite.mp4';
      final thumbPath = '${outputCompositePath}.thumb.jpg';

      state = state.copyWith(renderProgress: 0.35);

      final renderRequest = RenderJobRequest(
        sourceFilePath: rawPath,
        outputFilePath: outputCompositePath,
        thumbnailFilePath: thumbPath,
        speedRamp: SpeedRampConfig.default360Preset,
        colorFilter: VideoColorFilter.cinematic,
        enableAudioDucking: true,
      );

      state = state.copyWith(renderProgress: 0.65);
      final renderResult = await renderingService.executeRender(renderRequest);
      state = state.copyWith(renderProgress: 0.95);

      if (!renderResult.success) {
        throw Exception('Render failed: composite file not created on disk.');
      }

      final shortCode = _generateShortCode();
      final publicUrl = 'https://gallery.luster360.com/v/$shortCode';

      // Enqueue to upload queue ONLY after composite file exists on disk
      uploadQueueNotifier?.enqueueVideo(
        videoId: shortCode,
        eventId: 'active-event',
        localVideoPath: outputCompositePath,
        localThumbnailPath: thumbPath,
      );

      state = state.copyWith(
        workflowState: CaptureWorkflowState.readyToShare,
        renderedVideoPath: outputCompositePath,
        thumbnailPath: thumbPath,
        shortCode: shortCode,
        publicUrl: publicUrl,
        renderProgress: 1.0,
        uploadProgress: 1.0,
      );

      // Auto return to READY after 12 seconds
      _startAutoReturnCountdown(12);
    } catch (e) {
      AppLogger.error('Finish recording failed', e);
      state = state.copyWith(
        workflowState: CaptureWorkflowState.error,
        errorMessage: 'Capture finish error: $e',
      );
    }
  }

  void _startAutoReturnCountdown(int seconds) {
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(Duration(seconds: seconds), () {
      resetToReady();
    });
  }

  void resetToReady() {
    _autoReturnTimer?.cancel();
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    state = state.copyWith(
      workflowState: CaptureWorkflowState.ready,
      countdownRemaining: state.totalCountdownSeconds,
      elapsedRecordingSeconds: 0,
      renderProgress: 0.0,
      uploadProgress: 0.0,
    );
  }

  void setOperatorLock(bool locked) {
    state = state.copyWith(isOperatorLocked: locked);
  }

  bool verifyPin(String pin) {
    return pin == '1234';
  }

  String _generateShortCode() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final random = DateTime.now().microsecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random >> (i * 5)) % chars.length];
    }
    return code;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    super.dispose();
  }
}

final phoneCameraDeviceProvider = Provider<PhoneCameraDevice>((ref) {
  final device = PhoneCameraDevice();
  ref.onDispose(() => device.dispose());
  return device;
});

final captureProvider = StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final camera = ref.watch(phoneCameraDeviceProvider);
  final uploadQueue = ref.watch(uploadQueueProvider.notifier);
  return CaptureNotifier(
    camera,
    renderingService: RenderingService(),
    uploadQueueNotifier: uploadQueue,
  );
});
