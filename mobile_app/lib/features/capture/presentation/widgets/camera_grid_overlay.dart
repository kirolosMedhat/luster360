import 'package:flutter/material.dart';

class CameraGridOverlay extends StatelessWidget {
  const CameraGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1.0;

    final oneThirdWidth = size.width / 3;
    final twoThirdsWidth = (size.width * 2) / 3;
    final oneThirdHeight = size.height / 3;
    final twoThirdsHeight = (size.height * 2) / 3;

    // Vertical lines
    canvas.drawLine(Offset(oneThirdWidth, 0), Offset(oneThirdWidth, size.height), paint);
    canvas.drawLine(Offset(twoThirdsWidth, 0), Offset(twoThirdsWidth, size.height), paint);

    // Horizontal lines
    canvas.drawLine(Offset(0, oneThirdHeight), Offset(size.width, oneThirdHeight), paint);
    canvas.drawLine(Offset(0, twoThirdsHeight), Offset(size.width, twoThirdsHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
