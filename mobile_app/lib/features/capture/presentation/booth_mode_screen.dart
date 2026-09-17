import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../application/capture_controller.dart';
import '../domain/capture_state.dart';
import '../../events/application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import 'widgets/animated_logo_attract_widget.dart';
import 'widgets/booth_shutter_button.dart';
import 'widgets/camera_grid_overlay.dart';

class BoothModeScreen extends ConsumerStatefulWidget {
  const BoothModeScreen({super.key});

  @override
  ConsumerState<BoothModeScreen> createState() => _BoothModeScreenState();
}

class _BoothModeScreenState extends ConsumerState<BoothModeScreen> {
  bool _showSettingsSheet = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14151B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Booth Mode?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Do you want to return to the studio dashboard?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A3FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text('Exit to Studio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final captureNotifier = ref.read(captureProvider.notifier);
    final camera = ref.watch(phoneCameraDeviceProvider);
    final isStandby = captureState.workflowState == CaptureWorkflowState.ready;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fullscreen Camera Viewfinder
          if (camera.controller != null && camera.controller!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(camera.controller!),
              ),
            )
          else
            Container(
              color: const Color(0xFF0A0B10),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_outlined, color: Colors.white30, size: 48),
                    SizedBox(height: 12),
                    Text('Camera Initializing...', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            ),

          // 2. Rule-of-Thirds Grid Overlay (as seen in media_1789558971248.png)
          const CameraGridOverlay(),

          // 3. Top Header Bar Overlay
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Left: Close Button (Circular dark badge)
                    GestureDetector(
                      onTap: _showExitDialog,
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

                    // Top Center: Camera Status Pill (e.g. GoPro Hero 11 / Camera Active)
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
                          const Text(
                            'GoPro Hero 11',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Right: Tune / Settings Button (Circular dark badge)
                    GestureDetector(
                      onTap: () {
                        setState(() => _showSettingsSheet = !_showSettingsSheet);
                      },
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

          // 4. Quick Tune Settings Sheet Overlay
          if (_showSettingsSheet)
            Positioned(
              top: 80,
              right: 16,
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF14151B).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Controls', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Torch', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Switch(
                          value: captureState.isTorchOn,
                          activeColor: const Color(0xFF00A3FF),
                          onChanged: (_) => captureNotifier.toggleTorch(),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    const Text('Countdown Timer', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [3, 5, 10].map((s) {
                        final isSel = captureState.totalCountdownSeconds == s;
                        return GestureDetector(
                          onTap: () => captureNotifier.setCountdownDuration(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF00A3FF) : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${s}s',
                              style: TextStyle(
                                color: isSel ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // 5. ANIMATED LOGO VIDEO / ATTRACT SEQUENCE (Before Recording)
          if (isStandby)
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, -0.15),
                child: const AnimatedLogoAttractWidget(size: 240),
              ),
            ),

          // 6. Standby Prompt & Tactile Shutter Button (as seen in media_1789558971248.png)
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
                          if (_showSettingsSheet) {
                            setState(() => _showSettingsSheet = false);
                          }
                          captureNotifier.startCaptureSession();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 7. Large Animated Countdown Overlay
          if (captureState.workflowState == CaptureWorkflowState.countdown)
            Container(
              color: Colors.black.withOpacity(0.65),
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
                        fontSize: 160,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 8. Recording State Indicator
          if (captureState.workflowState == CaptureWorkflowState.recording)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFE50914).withOpacity(0.5), blurRadius: 30, spreadRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'RECORDING: 00:${captureState.elapsedRecordingSeconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // 9. Rendering State Overlay
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
                        'PROCESSING 360 MASTER',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Speed ramp, color grading & frame burn-in',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
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

          // 10. Ready to Share Screen with Live QR Code
          if (captureState.workflowState == CaptureWorkflowState.readyToShare)
            Container(
              color: const Color(0xF2090A0E),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00A3FF).withOpacity(0.4),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: captureState.publicUrl ?? 'https://gallery.luster360.com/v/${captureState.shortCode}',
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SCAN TO DOWNLOAD',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan with your phone camera to download your 360 video instantly',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () => captureNotifier.resetToReady(),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 320),
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00A3FF), Color(0xFF0077EE)],
                            ),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00A3FF).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'READY FOR NEXT GUEST',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
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
