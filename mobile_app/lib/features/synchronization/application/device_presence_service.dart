import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/logging/app_logger.dart';

class DevicePresenceService {
  static final DevicePresenceService instance = DevicePresenceService._();
  DevicePresenceService._();

  Timer? _heartbeatTimer;
  final String _deviceId = 'LUSTER-BOOTH-MOBILE-01';
  final String _apiUrl = AppConstants.defaultMediaApiUrl;

  void startPresenceStream() {
    sendHeartbeat('READY');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      sendHeartbeat('READY');
    });
    AppLogger.info('Device presence stream started for $_deviceId');
  }

  void stopPresenceStream() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    sendDisconnect();
    AppLogger.info('Device presence stream stopped for $_deviceId');
  }

  Future<void> sendHeartbeat(String state) async {
    try {
      final url = Uri.parse('$_apiUrl/devices/heartbeat');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': _deviceId,
          'operationalState': state,
          'batteryLevel': 94,
          'isCharging': true,
          'storageFreeBytes': 48000000000,
          'storageTotalBytes': 128000000000,
          'networkType': 'WIFI',
          'appVersion': AppConstants.appVersion,
        }),
      );
    } catch (e) {
      // Ignore network dropouts
    }
  }

  Future<void> sendDisconnect() async {
    try {
      final url = Uri.parse('$_apiUrl/devices/disconnect');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': _deviceId,
        }),
      );
    } catch (_) {}
  }
}
