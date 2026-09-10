import '../domain/capture_device.dart';
import '../../../core/errors/failures.dart';

class GoProCameraDevice implements CaptureDevice {
  @override
  CameraType get type => CameraType.goPro;

  @override
  String get name => 'GoPro HERO 11/12';

  @override
  bool get isConnected => false;

  @override
  Future<void> connect() async {
    throw const CameraFailure(
      'GoPro is NOT CONNECTED. Pair camera via Bluetooth/Wi-Fi in Booth Settings.',
      code: 'NOT_CONNECTED',
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DeviceCapability> getCapabilities() async {
    return const DeviceCapability(
      supportedModes: [
        CameraMode(resolution: ResolutionPreset.p1080, fps: 60, label: '1080p @ 60 FPS'),
        CameraMode(resolution: ResolutionPreset.p1080, fps: 120, label: '1080p @ 120 FPS'),
        CameraMode(resolution: ResolutionPreset.p2160, fps: 60, label: '4K @ 60 FPS'),
      ],
      hasStabilization: true,
      maxFps: 120,
    );
  }

  @override
  Future<void> setCameraMode(CameraMode mode) async {}

  @override
  Future<void> setTorch(bool enabled) async {}

  @override
  Future<void> startRecording() async {
    throw const CameraFailure('GoPro NOT CONNECTED', code: 'NOT_CONNECTED');
  }

  @override
  Future<CaptureResult> stopRecording() async {
    throw const CameraFailure('GoPro NOT CONNECTED', code: 'NOT_CONNECTED');
  }

  @override
  Future<void> dispose() async {}
}

class SonyCameraDevice implements CaptureDevice {
  @override
  CameraType get type => CameraType.sony;

  @override
  String get name => 'Sony Alpha Camera';

  @override
  bool get isConnected => false;

  @override
  Future<void> connect() async {
    throw const CameraFailure(
      'Sony Alpha camera is NOT CONNECTED. Connect via USB Tethering or Camera Control SDK.',
      code: 'NOT_CONNECTED',
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DeviceCapability> getCapabilities() async {
    return const DeviceCapability(
      supportedModes: [
        CameraMode(resolution: ResolutionPreset.p1080, fps: 60, label: '1080p @ 60 FPS'),
        CameraMode(resolution: ResolutionPreset.p2160, fps: 30, label: '4K @ 30 FPS'),
      ],
    );
  }

  @override
  Future<void> setCameraMode(CameraMode mode) async {}

  @override
  Future<void> setTorch(bool enabled) async {}

  @override
  Future<void> startRecording() async {
    throw const CameraFailure('Sony camera NOT CONNECTED', code: 'NOT_CONNECTED');
  }

  @override
  Future<CaptureResult> stopRecording() async {
    throw const CameraFailure('Sony camera NOT CONNECTED', code: 'NOT_CONNECTED');
  }

  @override
  Future<void> dispose() async {}
}

class CanonCameraDevice implements CaptureDevice {
  @override
  CameraType get type => CameraType.canon;

  @override
  String get name => 'Canon EOS Camera';

  @override
  bool get isConnected => false;

  @override
  Future<void> connect() async {
    throw const CameraFailure(
      'Canon EOS camera is NOT CONNECTED. Connect via Canon EDSDK / Wi-Fi.',
      code: 'NOT_CONNECTED',
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DeviceCapability> getCapabilities() async {
    return const DeviceCapability(
      supportedModes: [
        CameraMode(resolution: ResolutionPreset.p1080, fps: 60, label: '1080p @ 60 FPS'),
      ],
    );
  }

  @override
  Future<void> setCameraMode(CameraMode mode) async {}

  @override
  Future<void> setTorch(bool enabled) async {}

  @override
  Future<void> startRecording() async {
    throw const CameraFailure('Canon camera NOT CONNECTED', code: 'NOT_CONNECTED');
  }

  @override
  Future<CaptureResult> stopRecording() async {
    throw const CameraFailure('Canon camera NOT CONNECTED', code: 'NOT_CONNECTED');
  }

  @override
  Future<void> dispose() async {}
}
