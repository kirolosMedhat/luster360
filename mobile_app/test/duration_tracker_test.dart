import 'package:flutter_test/flutter_test.dart';
import '../lib/core/utils/duration_formatter.dart';

void main() {
  group('DurationFormatter Tests', () {
    test('Formats seconds into HHh MMm correctly', () {
      expect(DurationFormatter.formatSeconds(0), '00m 00s');
      expect(DurationFormatter.formatSeconds(125), '02m 05s');
      // 4 hours, 42 minutes, 0 seconds = 16920 seconds
      expect(DurationFormatter.formatSeconds(4 * 3600 + 42 * 60), '04h 42m');
    });

    test('Calculates server-independent duration in UTC', () {
      final now = DateTime.now().toUtc();
      final started = now.subtract(const Duration(hours: 4, minutes: 42));

      final result = DurationFormatter.calculateEventDuration(startedAt: started);
      expect(result.durationSeconds, 4 * 3600 + 42 * 60);
      expect(result.formatted, '04h 42m');
    });

    test('Calculates ended event duration accurately', () {
      final started = DateTime.utc(2026, 9, 10, 18, 0, 0);
      final ended = DateTime.utc(2026, 9, 10, 22, 42, 0);

      final result = DurationFormatter.calculateEventDuration(startedAt: started, endedAt: ended);
      expect(result.durationSeconds, 4 * 3600 + 42 * 60);
      expect(result.formatted, '04h 42m');
    });

    test('Formats video timestamp mm:ss', () {
      expect(DurationFormatter.formatVideoTime(0.0), '00:00');
      expect(DurationFormatter.formatVideoTime(15.4), '00:15');
      expect(DurationFormatter.formatVideoTime(65.0), '01:05');
    });
  });
}
