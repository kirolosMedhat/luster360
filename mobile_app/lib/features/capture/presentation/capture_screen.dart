import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../application/capture_controller.dart';
import '../domain/capture_state.dart';
import '../../events/application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_icon_button.dart';
import '../../../core/widgets/luster_status_badge.dart';
import '../../../core/widgets/luster_progress_indicator.dart';

class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureState = ref.watch(captureProvider);
    final captureNotifier = ref.read(captureProvider.notifier);
    final eventState = ref.watch(eventProvider);
    final camera = ref.watch(phoneCameraDeviceProvider);

    return Scaffold(
      backgroundColor: LusterColors.pitchBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Viewfinder Preview
          if (camera.controller != null && camera.controller!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(camera.controller!),
              ),
            )
          else
            Container(
              color: LusterColors.background,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_outlined, color: LusterColors.textMuted, size: 64),
                    SizedBox(height: 16),
                    Text('Connecting Camera...', style: TextStyle(color: LusterColors.textMuted)),
                  ],
                ),
              ),
            ),

          // 2. Top Header Overlay
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Active event name & duration
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: LusterColors.overlayBackdrop,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: LusterColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_checked, color: LusterColors.primaryBlue, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            eventState.currentEvent?.name ?? 'Ahmed & Mariam Wedding',
                            style: LusterTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: LusterColors.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            eventState.formattedDuration,
                            style: LusterTypography.monoTimer.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    // Controls: Torch, Booth Mode Fullscreen
                    Row(
                      children: [
                        LusterIconButton(
                          icon: captureState.isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: captureState.isTorchOn ? LusterColors.warning : LusterColors.text,
                          size: 42,
                          onPressed: () => captureNotifier.toggleTorch(),
                        ),
                        const SizedBox(width: 8),
                        LusterIconButton(
                          icon: Icons.fullscreen_rounded,
                          color: LusterColors.primaryBlue,
                          size: 42,
                          tooltip: 'Fullscreen Booth Mode',
                          onPressed: () => context.push('/booth-mode'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Countdown Display Overlay
          if (captureState.workflowState == CaptureWorkflowState.countdown)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('GET READY', style: LusterTypography.displayMedium.copyWith(letterSpacing: 4.0)),
                    const SizedBox(height: 12),
                    Text('${captureState.countdownRemaining}', style: LusterTypography.heroCountdown),
                  ],
                ),
              ),
            ),

          // 4. Recording Status Overlay
          if (captureState.workflowState == CaptureWorkflowState.recording)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: LusterColors.stateRecording,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RECORDING: 00:${captureState.elapsedRecordingSeconds.toString().padLeft(2, '0')}',
                          style: LusterTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 5. Rendering / Processing Progress Overlay
          if (captureState.workflowState == CaptureWorkflowState.rendering ||
              captureState.workflowState == CaptureWorkflowState.processing)
            Container(
              color: LusterColors.overlayBackdrop,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: LusterColors.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LusterColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LusterStatusBadge(
                          status: LusterBoothStatus.rendering,
                          customLabel: 'RENDERING 360 VIDEO',
                        ),
                        const SizedBox(height: 20),
                        LusterProgressIndicator(
                          progress: captureState.renderProgress,
                          label: 'Applying Speed Curve & Overlays',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 6. Ready To Share Overlay
          if (captureState.workflowState == CaptureWorkflowState.readyToShare)
            Container(
              color: LusterColors.overlayBackdrop,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: LusterColors.panel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: LusterColors.primaryBlue.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: LusterColors.success, size: 56),
                      const SizedBox(height: 12),
                      Text('VIDEO READY!', style: LusterTypography.displayMedium.copyWith(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text('Saved locally & queued for upload', style: LusterTypography.bodyMedium),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: LusterButton(
                              label: 'Edit Video',
                              variant: LusterButtonVariant.secondary,
                              leadingIcon: Icons.edit_rounded,
                              onPressed: () => context.push('/editor'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LusterButton(
                              label: 'View QR Code',
                              leadingIcon: Icons.qr_code_rounded,
                              onPressed: () => context.push('/share'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LusterButton(
                        label: 'Ready for Next Spin',
                        variant: LusterButtonVariant.subtle,
                        onPressed: () => captureNotifier.resetToReady(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 7. Bottom Tactile Booth Controls (When Ready)
          if (captureState.workflowState == CaptureWorkflowState.ready)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Countdown Selector Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [3, 5, 10].map((sec) {
                          final isSelected = captureState.totalCountdownSeconds == sec;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ChoiceChip(
                              label: Text('${sec}s Timer'),
                              selected: isSelected,
                              selectedColor: LusterColors.primaryBlue,
                              backgroundColor: LusterColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected ? LusterColors.darkNavy : LusterColors.text,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (_) => captureNotifier.setCountdownDuration(sec),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Large Circular Record Button
                      GestureDetector(
                        onTap: () => captureNotifier.startCaptureSession(),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: LusterColors.pureWhite, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: LusterColors.stateRecording,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('TAP TO START 360 RECORDING', style: LusterTypography.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
