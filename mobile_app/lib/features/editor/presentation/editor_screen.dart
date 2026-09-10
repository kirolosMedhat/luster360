import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/editor_controller.dart';
import '../domain/speed_ramp_config.dart';
import '../../rendering/application/rendering_service.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_slider.dart';
import '../../../core/widgets/luster_toggle.dart';
import '../../../core/widgets/luster_tab_bar.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  int _selectedTab = 0; // 0: Speed, 1: Effects, 2: Overlays, 3: Audio

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('360 Video Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: LusterButton(
                label: 'Export MP4',
                height: 38,
                leadingIcon: Icons.movie_creation_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rendering final MP4 with FFmpeg hardware encoder...'),
                      backgroundColor: LusterColors.primaryBlue,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Video Preview Player Canvas
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LusterColors.pitchBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LusterColors.border),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Center(
                    child: Icon(Icons.slow_motion_video_rounded, size: 80, color: LusterColors.primaryBlue),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Estimated Output: ${editorState.speedRamp.calculateOutputDuration().toStringAsFixed(1)}s',
                        style: LusterTypography.monoTimer.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Editor Category Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LusterTabBar(
              tabs: const ['Speed Curve', 'Filters & Motion', 'Overlays', 'Music'],
              selectedIndex: _selectedTab,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Tab Content
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActiveTabContent(editorState, editorNotifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(EditorState state, EditorNotifier notifier) {
    switch (_selectedTab) {
      case 0:
        // Speed Ramp Tab
        return ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SPEED PRESETS', style: LusterTypography.bodySmall),
                Text('Real-time FFmpeg setpts/atempo', style: LusterTypography.bodySmall.copyWith(color: LusterColors.primaryBlue)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LusterCard(
                    padding: const EdgeInsets.all(12),
                    borderColor: state.speedRamp == SpeedRampConfig.default360Preset ? LusterColors.primaryBlue : LusterColors.border,
                    onTap: () => notifier.setSpeedRamp(SpeedRampConfig.default360Preset),
                    child: const Column(
                      children: [
                        Text('Signature 360', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        SizedBox(height: 2),
                        Text('1.0x -> 0.4x -> 1.0x', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LusterCard(
                    padding: const EdgeInsets.all(12),
                    borderColor: state.speedRamp == SpeedRampConfig.ultraSlowPreset ? LusterColors.primaryBlue : LusterColors.border,
                    onTap: () => notifier.setSpeedRamp(SpeedRampConfig.ultraSlowPreset),
                    child: const Column(
                      children: [
                        Text('Ultra Slow', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        SizedBox(height: 2),
                        Text('0.25x Center Matrix', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LusterCard(
                    padding: const EdgeInsets.all(12),
                    borderColor: state.speedRamp == SpeedRampConfig.punchyFastPreset ? LusterColors.primaryBlue : LusterColors.border,
                    onTap: () => notifier.setSpeedRamp(SpeedRampConfig.punchyFastPreset),
                    child: const Column(
                      children: [
                        Text('Punchy Fast', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        SizedBox(height: 2),
                        Text('1.5x -> 0.5x -> 1.5x', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('SEGMENTS BREAKDOWN', style: LusterTypography.bodySmall),
            const SizedBox(height: 8),
            ...state.speedRamp.segments.asMap().entries.map((entry) {
              final idx = entry.key;
              final seg = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: LusterColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LusterColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Segment ${idx + 1} (${seg.startTime.toStringAsFixed(1)}s - ${seg.endTime.toStringAsFixed(1)}s)'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: LusterColors.accentMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${seg.speed}x Speed', style: const TextStyle(color: LusterColors.primaryBlue, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

      case 1:
        // Motion & Filters Tab
        return ListView(
          children: [
            LusterToggle(
              title: 'Reverse Video',
              subtitle: 'Plays footage backwards via FFmpeg reverse filter',
              value: state.isReversed,
              onChanged: (_) => notifier.toggleReverse(),
            ),
            const SizedBox(height: 12),
            LusterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Boomerang Loop (Forward + Reverse)', style: LusterTypography.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [0, 1, 2].map((count) {
                      final isSelected = state.boomerangCount == count;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(count == 0 ? 'Off' : '$count Repetition${count > 1 ? 's' : ''}'),
                          selected: isSelected,
                          selectedColor: LusterColors.primaryBlue,
                          onSelected: (_) => notifier.setBoomerang(count),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('COLOR GRADING PRESETS', style: LusterTypography.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VideoColorFilter.values.map((f) {
                final isSelected = state.colorFilter == f;
                return ChoiceChip(
                  label: Text(f.name.toUpperCase()),
                  selected: isSelected,
                  selectedColor: LusterColors.primaryBlue,
                  onSelected: (_) => notifier.setColorFilter(f),
                );
              }).toList(),
            ),
          ],
        );

      case 2:
        // Overlays Tab
        return ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BRANDING & EVENT OVERLAYS', style: LusterTypography.bodySmall),
                TextButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                  label: const Text('Add Layer'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            LusterCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: LusterColors.header,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.layers_rounded, color: LusterColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Luster Signature Watermark', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('PNG • Bottom Center • 100% Opacity', style: TextStyle(color: LusterColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.visibility_rounded, color: LusterColors.primaryBlue, size: 20),
                ],
              ),
            ),
          ],
        );

      case 3:
        // Audio Tab
        return ListView(
          children: [
            LusterSlider(
              label: 'Music Volume Level',
              value: state.musicVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              valueFormatter: (v) => '${(v * 100).toInt()}%',
              onChanged: (v) => notifier.setMusicVolume(v),
            ),
            const SizedBox(height: 12),
            LusterCard(
              child: Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: LusterColors.primaryBlue, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Luster Cinematic Beat (Licensed)', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('00:15 • 192kbps AAC • 0.5s Fade In', style: TextStyle(color: LusterColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: LusterColors.primaryBlue),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
