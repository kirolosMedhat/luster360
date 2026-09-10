import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../application/capture_controller.dart';
import '../domain/capture_state.dart';
import '../../events/application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_dialog.dart';
import '../../../core/widgets/luster_text_field.dart';

class BoothModeScreen extends ConsumerStatefulWidget {
  const BoothModeScreen({super.key});

  @override
  ConsumerState<BoothModeScreen> createState() => _BoothModeScreenState();
}

class _BoothModeScreenState extends ConsumerState<BoothModeScreen> {
  @override
  void initState() {
    super.initState();
    // Enable immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore normal system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showExitPinDialog() {
    final pinController = TextEditingController();
    LusterDialog.show(
      context: context,
      title: 'Exit Booth Mode',
      confirmLabel: 'Exit',
      cancelLabel: 'Stay in Booth',
      onConfirm: () {
        if (pinController.text == '1234') {
          Navigator.of(context).pop();
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid Operator PIN. Default is 1234.'),
              backgroundColor: LusterColors.danger,
            ),
          );
        }
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter 4-digit Operator PIN to unlock controls:'),
          const SizedBox(height: 16),
          LusterTextField(
            label: 'Operator PIN',
            hint: '••••',
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final captureNotifier = ref.read(captureProvider.notifier);
    final eventState = ref.watch(eventProvider);
    final camera = ref.watch(phoneCameraDeviceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fullscreen Viewfinder
          if (camera.controller != null && camera.controller!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(camera.controller!),
              ),
            )
          else
            Container(color: Colors.black),

          // 2. Minimalist Booth Mode Header (Exit PIN button on top right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _showExitPinDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 16),
                        SizedBox(width: 6),
                        Text('EXIT BOOTH', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Large Event Title on Top Left
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LUSTER 360',
                      style: LusterTypography.bodySmall.copyWith(
                        color: LusterColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      eventState.currentEvent?.name ?? 'Ahmed & Mariam Wedding',
                      style: LusterTypography.titleLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Large Countdown Display
          if (captureState.workflowState == CaptureWorkflowState.countdown)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '${captureState.countdownRemaining}',
                  style: LusterTypography.heroCountdown.copyWith(fontSize: 160),
                ),
              ),
            ),

          // 5. Recording Overlay
          if (captureState.workflowState == CaptureWorkflowState.recording)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: LusterColors.stateRecording.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '00:${captureState.elapsedRecordingSeconds.toString().padLeft(2, '0')}',
                  style: LusterTypography.displayLarge.copyWith(fontSize: 48, color: Colors.white),
                ),
              ),
            ),

          // 6. Huge Tactile Record Button (Ready State)
          if (captureState.workflowState == CaptureWorkflowState.ready)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: GestureDetector(
                    onTap: () => captureNotifier.startCaptureSession(),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: LusterColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: LusterColors.stateRecording,
                          ),
                          child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 7. Video Ready Display & Auto-return Timer
          if (captureState.workflowState == CaptureWorkflowState.readyToShare)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: LusterColors.success, size: 80),
                    const SizedBox(height: 16),
                    Text('GREAT 360 SPIN!', style: LusterTypography.displayLarge),
                    const SizedBox(height: 8),
                    Text('Your video is saved & ready', style: LusterTypography.bodyLarge),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LusterColors.primaryBlue,
                        foregroundColor: LusterColors.darkNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => captureNotifier.resetToReady(),
                      child: const Text('READY FOR NEXT GUEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
