import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

class DeviceTelemetry {
  final int batteryLevel;
  final bool isCharging;
  final int storageFreeBytes;
  final int storageTotalBytes;
  final String deviceIdentifier;
  final String deviceName;
  final String platform;
  final String appVersion;

  const DeviceTelemetry({
    required this.batteryLevel,
    required this.isCharging,
    required this.storageFreeBytes,
    required this.storageTotalBytes,
    required this.deviceIdentifier,
    required this.deviceName,
    required this.platform,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceIdentifier,
        'deviceName': deviceName,
        'platform': platform,
        'batteryLevel': batteryLevel,
        'isCharging': isCharging,
        'storageFreeBytes': storageFreeBytes,
        'storageTotalBytes': storageTotalBytes,
        'appVersion': appVersion,
      };
}

class DeviceTelemetryService {
  static final DeviceTelemetryService instance = DeviceTelemetryService._();
  DeviceTelemetryService._();

  final Battery _battery = Battery();

  Future<DeviceTelemetry> collectTelemetry() async {
    int batteryLevel = 100;
    bool isCharging = false;

    try {
      batteryLevel = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      isCharging = (state == BatteryState.charging || state == BatteryState.full);
    } catch (e) {
      // In tests or desktop environments without battery API
      AppLogger.info('Battery API unavailable or running on test harness: $e');
    }

    int freeStorage = 45 * 1024 * 1024 * 1024; // 45 GB fallback
    int totalStorage = 128 * 1024 * 1024 * 1024; // 128 GB fallback

    try {
      final docDir = await getApplicationDocumentsDirectory();
      if (Platform.isAndroid || Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('df', ['-k', docDir.path]);
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().trim().split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              final availKb = int.tryParse(parts[3]);
              final totalKb = int.tryParse(parts[1]);
              if (availKb != null) freeStorage = availKb * 1024;
              if (totalKb != null) totalStorage = totalKb * 1024;
            }
          }
        }
      } else if (Platform.isWindows) {
        final driveLetter = docDir.path.length >= 2 ? docDir.path.substring(0, 2) : 'C:';
        final result = await Process.run('wmic', [
          'logicaldisk',
          'where',
          'DeviceID="$driveLetter"',
          'get',
          'FreeSpace,Size'
        ]);
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().trim().split('\n');
          if (lines.length >= 2) {
            final numbers = lines[1].trim().split(RegExp(r'\s+'));
            if (numbers.length >= 2) {
              final free = int.tryParse(numbers[0]);
              final total = int.tryParse(numbers[1]);
              if (free != null) freeStorage = free;
              if (total != null) totalStorage = total;
            }
          }
        }
      }
    } catch (_) {}

    String deviceId = 'LUSTER-BOOTH-01';
    try {
      final prefs = await SharedPreferences.getInstance();
      deviceId = prefs.getString('device_identifier') ?? 'LUSTER-BOOTH-01';
    } catch (_) {}

    return DeviceTelemetry(
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      storageFreeBytes: freeStorage,
      storageTotalBytes: totalStorage,
      deviceIdentifier: deviceId,
      deviceName: 'Luster 360 Main Unit',
      platform: Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'desktop'),
      appVersion: AppConstants.appVersion,
    );
  }
}
