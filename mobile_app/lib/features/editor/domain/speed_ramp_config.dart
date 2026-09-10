class SpeedSegment {
  final double startTime;
  final double endTime;
  final double speed; // e.g. 0.35, 0.5, 1.0, 1.5, 2.0

  const SpeedSegment({
    required this.startTime,
    required this.endTime,
    required this.speed,
  });

  double get duration => endTime - startTime;

  SpeedSegment copyWith({
    double? startTime,
    double? endTime,
    double? speed,
  }) {
    return SpeedSegment(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      speed: speed ?? this.speed,
    );
  }

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
        'speed': speed,
      };

  factory SpeedSegment.fromJson(Map<String, dynamic> json) => SpeedSegment(
        startTime: (json['start_time'] as num).toDouble(),
        endTime: (json['end_time'] as num).toDouble(),
        speed: (json['speed'] as num).toDouble(),
      );
}

class SpeedRampConfig {
  final List<SpeedSegment> segments;

  const SpeedRampConfig({required this.segments});

  static SpeedRampConfig get default360Preset => const SpeedRampConfig(
        segments: [
          SpeedSegment(startTime: 0.0, endTime: 2.5, speed: 1.0),
          SpeedSegment(startTime: 2.5, endTime: 7.5, speed: 0.4),
          SpeedSegment(startTime: 7.5, endTime: 10.0, speed: 1.0),
        ],
      );

  static SpeedRampConfig get ultraSlowPreset => const SpeedRampConfig(
        segments: [
          SpeedSegment(startTime: 0.0, endTime: 2.0, speed: 1.0),
          SpeedSegment(startTime: 2.0, endTime: 8.0, speed: 0.25),
          SpeedSegment(startTime: 8.0, endTime: 10.0, speed: 1.0),
        ],
      );

  static SpeedRampConfig get punchyFastPreset => const SpeedRampConfig(
        segments: [
          SpeedSegment(startTime: 0.0, endTime: 1.5, speed: 1.5),
          SpeedSegment(startTime: 1.5, endTime: 5.0, speed: 0.5),
          SpeedSegment(startTime: 5.0, endTime: 8.0, speed: 1.5),
        ],
      );

  /// Calculates the total rendered output duration after applying speed multipliers
  double calculateOutputDuration() {
    double total = 0.0;
    for (final seg in segments) {
      if (seg.speed > 0) {
        total += (seg.endTime - seg.startTime) / seg.speed;
      }
    }
    return total;
  }
}
