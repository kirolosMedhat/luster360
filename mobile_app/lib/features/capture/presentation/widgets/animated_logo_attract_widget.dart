import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimatedLogoAttractWidget extends StatefulWidget {
  final double size;
  final bool isOverlay;

  const AnimatedLogoAttractWidget({
    super.key,
    this.size = 260,
    this.isOverlay = true,
  });

  @override
  State<AnimatedLogoAttractWidget> createState() => _AnimatedLogoAttractWidgetState();
}

class _AnimatedLogoAttractWidgetState extends State<AnimatedLogoAttractWidget>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/animated_logo.mp4');
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (_) {
      // Graceful fallback to high-tech motion graphic if platform video cannot initialize
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Ambient pulsing glow behind logo
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final scale = 1.0 + (_animController.value * 0.12);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size * 0.85,
                    height: widget.size * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A3FF).withOpacity(0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 2. Video Player Loop OR Futuristic Tech Gyro Fallback
            if (_isVideoInitialized && _controller != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(widget.size / 2),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width > 0
                          ? _controller!.value.size.width
                          : widget.size,
                      height: _controller!.value.size.height > 0
                          ? _controller!.value.size.height
                          : widget.size,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              )
            else
              _buildMotionGraphicFallback(),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionGraphicFallback() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Outer Neon Gyro Ring
            Transform.rotate(
              angle: _animController.value * 2 * 3.14159,
              child: Container(
                width: widget.size * 0.9,
                height: widget.size * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00A3FF).withOpacity(0.4),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Counter-rotating Inner Ring
            Transform.rotate(
              angle: -_animController.value * 2 * 3.14159,
              child: Container(
                width: widget.size * 0.72,
                height: widget.size * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF86CFFF).withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Logo Image in Center
            Container(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0B0F17).withOpacity(0.85),
                border: Border.all(color: const Color(0xFF00A3FF), width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      '360',
                      style: TextStyle(
                        color: Color(0xFF00A3FF),
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
