import 'package:flutter_test/flutter_test.dart';
import 'package:luster_360/features/synchronization/application/upload_queue_service.dart';

void main() {
  group('UploadQueue Backoff Tests', () {
    test('Computes capped exponential backoff durations: 1s, 2s, 4s, 8s, 16s, 32s, 60s', () {
      expect(UploadQueueNotifier.calculateBackoff(0), Duration.zero);
      expect(UploadQueueNotifier.calculateBackoff(1), const Duration(seconds: 1));
      expect(UploadQueueNotifier.calculateBackoff(2), const Duration(seconds: 2));
      expect(UploadQueueNotifier.calculateBackoff(3), const Duration(seconds: 4));
      expect(UploadQueueNotifier.calculateBackoff(4), const Duration(seconds: 8));
      expect(UploadQueueNotifier.calculateBackoff(5), const Duration(seconds: 16));
      expect(UploadQueueNotifier.calculateBackoff(6), const Duration(seconds: 32));
      // Capped at 60 seconds
      expect(UploadQueueNotifier.calculateBackoff(7), const Duration(seconds: 60));
      expect(UploadQueueNotifier.calculateBackoff(10), const Duration(seconds: 60));
    });
  });
}
