import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/telemetry/device_telemetry_service.dart';

class DevicePresenceService {
  static final DevicePresenceService instance = DevicePresenceService._();
  DevicePresenceService._();

  Timer? _heartbeatTimer;
  final String _apiUrl = AppConstants.defaultMediaApiUrl;

  void startPresenceStream() {
    sendHeartbeat('READY');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      sendHeartbeat('READY');
    });
    AppLogger.info('Device presence stream started with 30s heartbeat interval');
  }

  void stopPresenceStream() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    sendDisconnect();
    AppLogger.info('Device presence stream stopped');
  }

  Future<void> sendHeartbeat(String operationalState) async {
    try {
      final telemetry = await DeviceTelemetryService.instance.collectTelemetry();
      final url = Uri.parse('$_apiUrl/devices/heartbeat');
      
      final payload = {
        'deviceId': telemetry.deviceIdentifier,
        'deviceName': telemetry.deviceName,
        'platform': telemetry.platform,
        'operationalState': operationalState,
        'batteryLevel': telemetry.batteryLevel,
        'isCharging': telemetry.isCharging,
        'storageFreeBytes': telemetry.storageFreeBytes,
        'storageTotalBytes': telemetry.storageTotalBytes,
        'networkType': 'WIFI',
        'appVersion': telemetry.appVersion,
      };

      await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignore network dropouts
      AppLogger.warn('Failed to dispatch device heartbeat: $e');
    }
  }

  Future<void> sendDisconnect() async {
    try {
      final telemetry = await DeviceTelemetryService.instance.collectTelemetry();
      final url = Uri.parse('$_apiUrl/devices/disconnect');
      await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deviceId': telemetry.deviceIdentifier,
            }),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }
}
