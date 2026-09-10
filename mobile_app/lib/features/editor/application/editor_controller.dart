import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/speed_ramp_config.dart';
import '../domain/overlay_item.dart';
import '../../rendering/application/rendering_service.dart';

class EditorState {
  final String? videoPath;
  final SpeedRampConfig speedRamp;
  final bool isReversed;
  final int boomerangCount;
  final VideoColorFilter colorFilter;
  final List<OverlayItem> overlays;
  final double musicVolume;
  final bool isPlaying;
  final double currentPosition;
  final double totalDuration;

  const EditorState({
    this.videoPath,
    required this.speedRamp,
    this.isReversed = false,
    this.boomerangCount = 0,
    this.colorFilter = VideoColorFilter.normal,
    this.overlays = const [],
    this.musicVolume = 1.0,
    this.isPlaying = false,
    this.currentPosition = 0.0,
    this.totalDuration = 10.0,
  });

  EditorState copyWith({
    String? videoPath,
    SpeedRampConfig? speedRamp,
    bool? isReversed,
    int? boomerangCount,
    VideoColorFilter? colorFilter,
    List<OverlayItem>? overlays,
    double? musicVolume,
    bool? isPlaying,
    double? currentPosition,
    double? totalDuration,
  }) {
    return EditorState(
      videoPath: videoPath ?? this.videoPath,
      speedRamp: speedRamp ?? this.speedRamp,
      isReversed: isReversed ?? this.isReversed,
      boomerangCount: boomerangCount ?? this.boomerangCount,
      colorFilter: colorFilter ?? this.colorFilter,
      overlays: overlays ?? this.overlays,
      musicVolume: musicVolume ?? this.musicVolume,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier()
      : super(EditorState(
          speedRamp: SpeedRampConfig.default360Preset,
        ));

  void setSpeedRamp(SpeedRampConfig config) {
    state = state.copyWith(speedRamp: config);
  }

  void toggleReverse() {
    state = state.copyWith(isReversed: !state.isReversed);
  }

  void setBoomerang(int count) {
    state = state.copyWith(boomerangCount: count);
  }

  void setColorFilter(VideoColorFilter filter) {
    state = state.copyWith(colorFilter: filter);
  }

  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume);
  }

  void addOverlay(OverlayItem item) {
    state = state.copyWith(overlays: [...state.overlays, item]);
  }

  void removeOverlay(String id) {
    state = state.copyWith(
      overlays: state.overlays.where((o) => o.id != id).toList(),
    );
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});
