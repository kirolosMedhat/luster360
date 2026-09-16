import 'package:flutter_test/flutter_test.dart';
import 'package:luster_360/features/editor/domain/speed_ramp_config.dart';
import 'package:luster_360/features/rendering/application/rendering_service.dart';

void main() {
  group('RenderingService FFmpeg Builder Tests', () {
    test('Builds complete FFmpeg argument list with speed ramp and filter complex', () {
      final service = RenderingService();
      final request = RenderJobRequest(
        sourceFilePath: '/path/to/raw.mp4',
        outputFilePath: '/path/to/final.mp4',
        thumbnailFilePath: '/path/to/thumb.jpg',
        speedRamp: SpeedRampConfig.default360Preset,
        isReversed: false,
        boomerangCount: 1, // Boomerang enabled
        colorFilter: VideoColorFilter.cinematic,
      );

      final args = service.buildFFmpegCommand(request);

      expect(args.contains('-filter_complex'), true);
      final filterComplexIdx = args.indexOf('-filter_complex');
      final filterGraph = args[filterComplexIdx + 1];

      // Check setpts and atempo
      expect(filterGraph.contains('setpts'), true);
      expect(filterGraph.contains('atempo'), true);
      expect(filterGraph.contains('concat'), true);

      // Check reverse for boomerang
      expect(filterGraph.contains('reverse'), true);
      expect(filterGraph.contains('areverse'), true);

      // Check codec outputs
      expect(args.contains('libx264'), true);
      expect(args.contains('aac'), true);
      expect(args.contains('/path/to/final.mp4'), true);
    });

    test('Builds thumbnail extraction command', () {
      final service = RenderingService();
      final thumbArgs = service.buildThumbnailCommand('/path/to/video.mp4', '/path/to/thumb.jpg');

      expect(thumbArgs.contains('-ss'), true);
      expect(thumbArgs.contains('-vframes'), true);
      expect(thumbArgs.contains('/path/to/thumb.jpg'), true);
    });
  });
}
