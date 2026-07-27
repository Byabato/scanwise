import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Four independently rotated corner brackets forming the scan frame. The
/// color communicates idle vs. detected state (see `AppColors.scannerFrame*`
/// in design_tokens.dart) — callers choose the tint.
class ScanFrame extends StatelessWidget {
  const ScanFrame({required this.color, this.size = 240, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          _corner(Alignment.topLeft, 0),
          _corner(Alignment.topRight, 90),
          _corner(Alignment.bottomRight, 180),
          _corner(Alignment.bottomLeft, 270),
        ],
      ),
    );
  }

  Widget _corner(Alignment alignment, double degrees) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        child: CustomPaint(
          size: const Size(40, 40),
          painter: _ScanCornerPainter(color: color),
        ),
      ),
    );
  }
}

class _ScanCornerPainter extends CustomPainter {
  const _ScanCornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(0, 10)
      ..quadraticBezierTo(0, 0, 10, 0)
      ..lineTo(size.width * 0.55, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanCornerPainter oldDelegate) =>
      oldDelegate.color != color;
}
