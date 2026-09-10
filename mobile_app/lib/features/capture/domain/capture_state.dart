import '../../camera/domain/capture_device.dart';

enum CaptureWorkflowState {
  ready,
  countdown,
  recording,
  processing,
  rendering,
  uploading,
  readyToShare,
  error,
}

class CaptureState {
  final CaptureWorkflowState workflowState;
  final int countdownRemaining;
  final int totalCountdownSeconds;
  final int recordingDurationSeconds;
  final int elapsedRecordingSeconds;
  final double renderProgress; // 0.0 to 1.0
  final double uploadProgress; // 0.0 to 1.0
  final CaptureResult? lastCaptureResult;
  final String? renderedVideoPath;
  final String? thumbnailPath;
  final String? shortCode;
  final String? publicUrl;
  final String? errorMessage;
  final bool isTorchOn;
  final bool isOperatorLocked;

  const CaptureState({
    this.workflowState = CaptureWorkflowState.ready,
    this.countdownRemaining = 5,
    this.totalCountdownSeconds = 5,
    this.recordingDurationSeconds = 10,
    this.elapsedRecordingSeconds = 0,
    this.renderProgress = 0.0,
    this.uploadProgress = 0.0,
    this.lastCaptureResult,
    this.renderedVideoPath,
    this.thumbnailPath,
    this.shortCode,
    this.publicUrl,
    this.errorMessage,
    this.isTorchOn = false,
    this.isOperatorLocked = false,
  });

  CaptureState copyWith({
    CaptureWorkflowState? workflowState,
    int? countdownRemaining,
    int? totalCountdownSeconds,
    int? recordingDurationSeconds,
    int? elapsedRecordingSeconds,
    double? renderProgress,
    double? uploadProgress,
    CaptureResult? lastCaptureResult,
    String? renderedVideoPath,
    String? thumbnailPath,
    String? shortCode,
    String? publicUrl,
    String? errorMessage,
    bool? isTorchOn,
    bool? isOperatorLocked,
  }) {
    return CaptureState(
      workflowState: workflowState ?? this.workflowState,
      countdownRemaining: countdownRemaining ?? this.countdownRemaining,
      totalCountdownSeconds: totalCountdownSeconds ?? this.totalCountdownSeconds,
      recordingDurationSeconds: recordingDurationSeconds ?? this.recordingDurationSeconds,
      elapsedRecordingSeconds: elapsedRecordingSeconds ?? this.elapsedRecordingSeconds,
      renderProgress: renderProgress ?? this.renderProgress,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      lastCaptureResult: lastCaptureResult ?? this.lastCaptureResult,
      renderedVideoPath: renderedVideoPath ?? this.renderedVideoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      shortCode: shortCode ?? this.shortCode,
      publicUrl: publicUrl ?? this.publicUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isOperatorLocked: isOperatorLocked ?? this.isOperatorLocked,
    );
  }
}
