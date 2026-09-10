enum CameraType { phone, goPro, sony, canon }

enum ResolutionPreset { p1080, p2160, p720 }

enum CameraOrientation { portrait, landscape }

class CameraMode {
  final ResolutionPreset resolution;
  final int fps;
  final String label;

  const CameraMode({
    required this.resolution,
    required this.fps,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraMode &&
          runtimeType == other.runtimeType &&
          resolution == other.resolution &&
          fps == other.fps;

  @override
  int get hashCode => resolution.hashCode ^ fps.hashCode;
}

class DeviceCapability {
  final List<CameraMode> supportedModes;
  final bool hasTorch;
  final bool hasStabilization;
  final bool hasExposureLock;
  final bool hasWhiteBalanceLock;
  final int maxFps;

  const DeviceCapability({
    required this.supportedModes,
    this.hasTorch = false,
    this.hasStabilization = false,
    this.hasExposureLock = false,
    this.hasWhiteBalanceLock = false,
    this.maxFps = 30,
  });
}

class CaptureResult {
  final String filePath;
  final Duration duration;
  final int width;
  final int height;
  final int fps;
  final int fileSizeBytes;

  const CaptureResult({
    required this.filePath,
    required this.duration,
    required this.width,
    required this.height,
    required this.fps,
    required this.fileSizeBytes,
  });
}

abstract class CaptureDevice {
  CameraType get type;
  String get name;
  bool get isConnected;

  Future<void> connect();
  Future<void> disconnect();
  Future<DeviceCapability> getCapabilities();
  Future<void> setCameraMode(CameraMode mode);
  Future<void> setTorch(bool enabled);
  Future<void> startRecording();
  Future<CaptureResult> stopRecording();
  Future<void> dispose();
}
