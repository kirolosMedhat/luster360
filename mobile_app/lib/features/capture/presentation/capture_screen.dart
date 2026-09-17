import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../application/capture_controller.dart';
import '../domain/capture_state.dart';
import '../../events/application/event_controller.dart';
import 'widgets/animated_logo_attract_widget.dart';
import 'widgets/booth_shutter_button.dart';
import 'widgets/camera_grid_overlay.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final captureNotifier = ref.read(captureProvider.notifier);
    final eventState = ref.watch(eventProvider);
    final camera = ref.watch(phoneCameraDeviceProvider);
    final isStandby = captureState.workflowState == CaptureWorkflowState.ready;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Viewfinder
          if (camera.controller != null && camera.controller!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(camera.controller!),
              ),
            )
          else
            Container(
              color: const Color(0xFF090A0F),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_outlined, color: Colors.white24, size: 54),
                    SizedBox(height: 12),
                    Text('Connecting Camera...', style: TextStyle(color: Colors.white38)),
                  ],
                ),
              ),
            ),

          // 2. Rule of thirds grid
          const CameraGridOverlay(),

          // 3. Top Header Bar
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      ),
                    ),

                    // Active Camera indicator pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00E676),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            eventState.currentEvent?.name ?? 'GoPro Hero 11',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls / Tuning
                    GestureDetector(
                      onTap: () => setState(() => _showSettings = !_showSettings),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Standby Attract Mode Animated Logo
          if (isStandby)
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, -0.15),
                child: const AnimatedLogoAttractWidget(size: 240),
              ),
            ),

          // 5. Standby Shutter Button & Tap Prompt
          if (isStandby)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TAP TO START SEQUENCE',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37).withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      BoothShutterButton(
                        onTap: () {
                          if (_showSettings) setState(() => _showSettings = false);
                          captureNotifier.startCaptureSession();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. Countdown Overlay
          if (captureState.workflowState == CaptureWorkflowState.countdown)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GET READY',
                      style: TextStyle(
                        color: Color(0xFF00A3FF),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${captureState.countdownRemaining}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 140,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 7. Recording Indicator
          if (captureState.workflowState == CaptureWorkflowState.recording)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'RECORDING: 00:${captureState.elapsedRecordingSeconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // 8. Processing Overlay
          if (captureState.workflowState == CaptureWorkflowState.rendering ||
              captureState.workflowState == CaptureWorkflowState.processing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14151B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00A3FF).withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF00A3FF)),
                      const SizedBox(height: 20),
                      const Text(
                        'RENDERING 360 VIDEO',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: captureState.renderProgress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00A3FF)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 9. Ready To Share
          if (captureState.workflowState == CaptureWorkflowState.readyToShare)
            Container(
              color: Colors.black87,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14151B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00A3FF).withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 56),
                      const SizedBox(height: 12),
                      const Text('VIDEO READY!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A3FF),
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.qr_code_rounded),
                        label: const Text('View Share QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => context.push('/share'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => captureNotifier.resetToReady(),
                        child: const Text('Ready for Next Spin', style: TextStyle(color: Colors.white70)),
                      ),
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
