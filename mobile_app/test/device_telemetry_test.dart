import 'package:flutter_test/flutter_test.dart';
import 'package:luster_360/core/telemetry/device_telemetry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Device Telemetry & Hardware State Tests', () {
    test('DeviceTelemetry model creates and formats JSON properly', () {
      const telemetry = DeviceTelemetry(
        batteryLevel: 87,
        isCharging: true,
        storageFreeBytes: 42000000000,
        storageTotalBytes: 128000000000,
        deviceIdentifier: 'LUSTER-BOOTH-TEST-01',
        deviceName: 'Cairo Booth 01',
        platform: 'android',
        appVersion: '1.0.0+1',
      );

      final json = telemetry.toJson();
      expect(json['deviceId'], 'LUSTER-BOOTH-TEST-01');
      expect(json['deviceName'], 'Cairo Booth 01');
      expect(json['batteryLevel'], 87);
      expect(json['isCharging'], isTrue);
      expect(json['storageFreeBytes'], 42000000000);
      expect(json['platform'], 'android');
      expect(json['appVersion'], '1.0.0+1');
    });

    test('DeviceTelemetryService collects real or graceful hardware telemetry', () async {
      final telemetry = await DeviceTelemetryService.instance.collectTelemetry();
      expect(telemetry, isNotNull);
      expect(telemetry.batteryLevel, inInclusiveRange(0, 100));
      expect(telemetry.storageFreeBytes, isPositive);
      expect(telemetry.storageTotalBytes, isPositive);
      expect(telemetry.deviceIdentifier, isNotEmpty);
      expect(telemetry.platform, isNotEmpty);
    });
  });
}
