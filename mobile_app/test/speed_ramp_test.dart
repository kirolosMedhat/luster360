import 'package:flutter_test/flutter_test.dart';
import 'package:luster_360/features/editor/domain/speed_ramp_config.dart';

void main() {
  group('SpeedRampConfig Tests', () {
    test('Calculates rendered output duration for default 360 preset', () {
      final config = SpeedRampConfig.default360Preset;
      // Segment 1: 0 - 2.5s @ 1.0x -> 2.5s
      // Segment 2: 2.5 - 7.5s (5s) @ 0.4x -> 5 / 0.4 = 12.5s
      // Segment 3: 7.5 - 10.0s (2.5s) @ 1.0x -> 2.5s
      // Total rendered duration = 2.5 + 12.5 + 2.5 = 17.5s
      final outputDuration = config.calculateOutputDuration();
      expect(outputDuration, closeTo(17.5, 0.001));
    });

    test('Serializes and deserializes speed segments to JSON', () {
      const seg = SpeedSegment(startTime: 1.0, endTime: 4.0, speed: 0.5);
      final json = seg.toJson();
      final fromJson = SpeedSegment.fromJson(json);

      expect(fromJson.startTime, 1.0);
      expect(fromJson.endTime, 4.0);
      expect(fromJson.speed, 0.5);
    });
  });
}
