import 'dart:math' as math;
import 'package:flutter/material.dart';

class BoothShutterButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const BoothShutterButton({
    super.key,
    required this.onTap,
    this.size = 88,
  });

  @override
  State<BoothShutterButton> createState() => _BoothShutterButtonState();
}

class _BoothShutterButtonState extends State<BoothShutterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer solid ring
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Inner dashed rotating ring
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _animController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size * 0.88, widget.size * 0.88),
                    painter: DashedCirclePainter(),
                  ),
                );
              },
            ),

            // Center solid white button
            Container(
              width: widget.size * 0.68,
              height: widget.size * 0.68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dashCount = 24;
    const dashLength = (2 * math.pi) / dashCount;
    const dashSpace = dashLength * 0.35;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashLength;
      final sweepAngle = dashLength - dashSpace;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
