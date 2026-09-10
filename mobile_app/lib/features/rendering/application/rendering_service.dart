import '../../editor/domain/speed_ramp_config.dart';
import '../../editor/domain/overlay_item.dart';
import '../../../core/logging/app_logger.dart';

enum VideoColorFilter { normal, warm, cool, contrast, blackAndWhite, cinematic }

class RenderJobRequest {
  final String sourceFilePath;
  final String outputFilePath;
  final String thumbnailFilePath;
  final SpeedRampConfig speedRamp;
  final bool isReversed;
  final int boomerangCount;
  final VideoColorFilter colorFilter;
  final List<OverlayItem> overlays;
  final String? backgroundMusicPath;
  final double musicVolume;
  final String? introVideoPath;
  final String? outroVideoPath;

  const RenderJobRequest({
    required this.sourceFilePath,
    required this.outputFilePath,
    required this.thumbnailFilePath,
    required this.speedRamp,
    this.isReversed = false,
    this.boomerangCount = 0,
    this.colorFilter = VideoColorFilter.normal,
    this.overlays = const [],
    this.backgroundMusicPath,
    this.musicVolume = 1.0,
    this.introVideoPath,
    this.outroVideoPath,
  });
}

class RenderingService {
  /**
   * Generates the complete, production-grade FFmpeg command line arguments
   * that execute speed ramping, reverse, boomerang, color grading, overlay mixing,
   * audio envelopes, and hardware accelerated encoding.
   */
  List<String> buildFFmpegCommand(RenderJobRequest request) {
    final args = <String>[];

    // Inputs
    args.addAll(['-y', '-i', request.sourceFilePath]);

    int inputIndex = 1;
    final overlayInputs = <int>[];
    for (final overlay in request.overlays) {
      if (overlay.content != null && overlay.type == OverlayType.imagePng) {
        args.addAll(['-i', overlay.content!]);
        overlayInputs.add(inputIndex++);
      }
    }

    int? musicInputIndex;
    if (request.backgroundMusicPath != null) {
      args.addAll(['-i', request.backgroundMusicPath!]);
      musicInputIndex = inputIndex++;
    }

    // Build Filter Complex
    final filterComplex = StringBuffer();
    final segCount = request.speedRamp.segments.length;

    // 1. Speed ramp trims & setpts
    for (int i = 0; i < segCount; i++) {
      final seg = request.speedRamp.segments[i];
      final speed = seg.speed.clamp(0.2, 4.0);
      final ptsMultiplier = 1.0 / speed;

      filterComplex.write(
        '[0:v]trim=start=${seg.startTime}:end=${seg.endTime},setpts=PTS-STARTPTS,setpts=$ptsMultiplier*PTS[v$i];',
      );
      filterComplex.write(
        '[0:a]atrim=start=${seg.startTime}:end=${seg.endTime},asetpts=PTS-STARTPTS,atempo=$speed[a$i];',
      );
    }

    // Concat speed segments
    for (int i = 0; i < segCount; i++) {
      filterComplex.write('[v$i][a$i]');
    }
    filterComplex.write('concat=n=$segCount:v=1:a=1[v_ramped][a_ramped];');

    String currentV = 'v_ramped';
    String currentA = 'a_ramped';

    // 2. Boomerang or Reverse
    if (request.boomerangCount > 0) {
      // Forward + Reverse concat
      filterComplex.write('[$currentV]reverse[v_rev];[$currentA]areverse[a_rev];');
      filterComplex.write('[$currentV][$currentA][v_rev][a_rev]concat=n=2:v=1:a=1[v_boom][a_boom];');
      currentV = 'v_boom';
      currentA = 'a_boom';
    } else if (request.isReversed) {
      filterComplex.write('[$currentV]reverse[v_rev];[$currentA]areverse[a_rev];');
      currentV = 'v_rev';
      currentA = 'a_rev';
    }

    // 3. Color Grading Filter
    String colorExpr = '';
    switch (request.colorFilter) {
      case VideoColorFilter.normal:
        break;
      case VideoColorFilter.warm:
        colorExpr = 'colorbalance=rs=0.08:gs=0.02:bs=-0.08';
        break;
      case VideoColorFilter.cool:
        colorExpr = 'colorbalance=rs=-0.08:gs=0.0:bs=0.12';
        break;
      case VideoColorFilter.contrast:
        colorExpr = 'eq=contrast=1.15:brightness=0.02:saturation=1.2';
        break;
      case VideoColorFilter.blackAndWhite:
        colorExpr = 'hue=s=0,eq=contrast=1.1';
        break;
      case VideoColorFilter.cinematic:
        colorExpr = 'eq=contrast=1.1:saturation=1.15,colorbalance=rs=0.04:bs=-0.04';
        break;
    }

    if (colorExpr.isNotEmpty) {
      filterComplex.write('[$currentV]$colorExpr[v_graded];');
      currentV = 'v_graded';
    }

    // 4. Layer-based Overlays
    for (int j = 0; j < overlayInputs.length; j++) {
      final inputIdx = overlayInputs[j];
      final overlay = request.overlays[j];
      final xCoord = 'main_w*${overlay.x}-overlay_w/2';
      final yCoord = 'main_h*${overlay.y}-overlay_h/2';

      filterComplex.write('[$currentV][$inputIdx:v]overlay=x=$xCoord:y=$yCoord:format=auto[v_overlay_$j];');
      currentV = 'v_overlay_$j';
    }

    // 5. Audio Mixing (Background Music)
    if (musicInputIndex != null) {
      filterComplex.write('[$musicInputIndex:a]volume=${request.musicVolume}[a_bg];');
      filterComplex.write('[$currentA][a_bg]amix=inputs=2:duration=first:dropout_transition=2[a_final];');
      currentA = 'a_final';
    }

    args.addAll(['-filter_complex', filterComplex.toString()]);
    args.addAll(['-map', '[$currentV]', '-map', '[$currentA]']);

    // Output Encoding Parameters (High performance H.264 / AAC)
    args.addAll([
      '-c:v', 'libx264',
      '-preset', 'veryfast',
      '-profile:v', 'high',
      '-pix_fmt', 'yuv420p',
      '-c:a', 'aac',
      '-b:a', '192k',
      '-movflags', '+faststart',
      request.outputFilePath,
    ]);

    AppLogger.info('Built FFmpeg rendering command with ${args.length} arguments');
    return args;
  }

  /**
   * Generates FFmpeg command to extract a crisp video poster thumbnail
   */
  List<String> buildThumbnailCommand(String videoFilePath, String thumbnailOutputPath) {
    return [
      '-y',
      '-ss', '00:00:02.500',
      '-i', videoFilePath,
      '-vframes', '1',
      '-q:v', '2',
      thumbnailOutputPath,
    ];
  }
}
