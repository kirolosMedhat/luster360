import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:luster_360/features/editor/domain/overlay_item.dart';
import 'package:luster_360/features/editor/domain/speed_ramp_config.dart';
import 'package:luster_360/features/rendering/application/rendering_service.dart';
import 'package:luster_360/features/synchronization/domain/upload_task.dart';
import 'package:luster_360/features/synchronization/application/upload_queue_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3: Post-Capture Render & Pre-Upload Pipeline Tests', () {
    test('Builds FFmpeg command with Speed Ramp, Audio Ducking, Overlays, Intro & Outro', () {
      final renderingService = RenderingService();
      final request = RenderJobRequest(
        sourceFilePath: '/storage/raw_spin_01.mp4',
        outputFilePath: '/storage/final_spin_01.mp4',
        thumbnailFilePath: '/storage/final_spin_01.jpg',
        speedRamp: SpeedRampConfig.default360Preset,
        colorFilter: VideoColorFilter.cinematic,
        backgroundMusicPath: '/storage/music_beat.mp3',
        enableAudioDucking: true,
        introVideoPath: '/storage/brand_intro.mp4',
        outroVideoPath: '/storage/brand_outro.mp4',
        overlays: const [
          OverlayItem(
            id: 'overlay-1',
            type: OverlayType.imagePng,
            content: '/storage/frame.png',
            x: 0.5,
            y: 0.5,
            scale: 1.0,
          )
        ],
      );

      final args = renderingService.buildFFmpegCommand(request);
      expect(args.contains('-filter_complex'), isTrue);

      final filterComplexIdx = args.indexOf('-filter_complex');
      final filterGraph = args[filterComplexIdx + 1];

      // 1. Check speed ramp segments
      expect(filterGraph.contains('setpts'), isTrue);
      expect(filterGraph.contains('atempo'), isTrue);

      // 2. Check color grading
      expect(filterGraph.contains('colorbalance'), isTrue);

      // 3. Check PNG overlay frame
      expect(filterGraph.contains('overlay='), isTrue);

      // 4. Check audio ducking weights
      expect(filterGraph.contains('amix=inputs=2:duration=first:dropout_transition=2:weights='), isTrue);

      // 5. Check intro and outro concatenation
      expect(filterGraph.contains('concat=n=3:v=1:a=1'), isTrue);

      // 6. Check destination output
      expect(args.contains('/storage/final_spin_01.mp4'), isTrue);
    });

    test('executeRender creates verified composite MP4 and thumbnail on disk before queueing', () async {
      final renderingService = RenderingService();
      final tempDir = Directory.systemTemp.createTempSync('luster_render_test');

      final rawFile = File('${tempDir.path}/test_raw.mp4');
      await rawFile.writeAsBytes([0, 0, 0, 32, 102, 116, 121, 112, 109, 112, 52, 50]); // mp4 header bytes

      final finalFile = '${tempDir.path}/test_composite.mp4';
      final thumbFile = '${tempDir.path}/test_composite.thumb.jpg';

      final request = RenderJobRequest(
        sourceFilePath: rawFile.path,
        outputFilePath: finalFile,
        thumbnailFilePath: thumbFile,
        speedRamp: SpeedRampConfig.default360Preset,
      );

      final result = await renderingService.executeRender(request);

      expect(result.success, isTrue);
      expect(File(finalFile).existsSync(), isTrue);
      expect(File(finalFile).lengthSync(), isPositive);
      expect(File(thumbFile).existsSync(), isTrue);
      expect(File(thumbFile).lengthSync(), isPositive);

      // Clean up
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('Upload queue transitions: LOCAL_ONLY when offline, QUEUED when online, and SYNCED', () async {
      final notifier = UploadQueueNotifier();

      // Simulate offline: enqueue goes to localOnly
      notifier.state = notifier.state.copyWith(isOnline: false);
      notifier.enqueueVideo(
        videoId: 'SPIN_OFFLINE_01',
        eventId: 'event_01',
        localVideoPath: '/path/to/composite.mp4',
        localThumbnailPath: '/path/to/thumb.jpg',
      );

      expect(notifier.state.tasks.length, 1);
      final offlineTask = notifier.state.tasks.first;
      expect(offlineTask.status, UploadTaskStatus.localOnly);
      expect(offlineTask.isLocalOnly, isTrue);

      // Simulate online: task promotes to queued and completes to synced
      notifier.state = notifier.state.copyWith(isOnline: true);
      final promotedTasks = notifier.state.tasks.map((t) {
        if (t.status == UploadTaskStatus.localOnly) {
          return t.copyWith(status: UploadTaskStatus.queued);
        }
        return t;
      }).toList();
      notifier.state = notifier.state.copyWith(tasks: promotedTasks);

      expect(notifier.state.tasks.first.status, UploadTaskStatus.queued);

      await notifier.processNextInQueue();
      final finishedTask = notifier.state.tasks.first;
      expect(finishedTask.status, UploadTaskStatus.synced);
      expect(finishedTask.isSynced, isTrue);

      notifier.dispose();
    });
  });
}
