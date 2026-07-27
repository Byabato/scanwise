import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/design_tokens.dart';

/// Foundation Scan destination. Presents the scanner-style surface, frame
/// and controls that camera integration will later drive. No camera preview
/// or scanning logic exists yet — this screen is intentionally static.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scannerSurface,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.tight,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _PrivacyIndicator(),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _ScanFrame(),
                            const SizedBox(height: AppSpacing.major),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.major,
                              ),
                              child: Text(
                                'Position a QR code or barcode inside the '
                                'frame. ScanWise will explain it before you '
                                'open or save anything.',
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.scannerForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.section),
              child: _ScanControls(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyIndicator extends StatelessWidget {
  const _PrivacyIndicator();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scan contents are processed on this device',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.compact,
          vertical: AppSpacing.micro,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.scannerForeground,
            ),
            const SizedBox(width: AppSpacing.micro),
            Flexible(
              child: Text(
                'Processed on this device',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.compactLabel.copyWith(
                  color: AppColors.scannerForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four independently rotated corner brackets forming the scan frame.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  static const _size = 240.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
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
        child: const CustomPaint(
          size: Size(40, 40),
          painter: _ScanCornerPainter(),
        ),
      ),
    );
  }
}

class _ScanCornerPainter extends CustomPainter {
  const _ScanCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.scannerFrameIdle
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanControls extends StatelessWidget {
  const _ScanControls();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _ScannerActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Import from gallery',
            ),
            SizedBox(width: AppSpacing.section),
            _ScannerActionButton(icon: Icons.flash_on_outlined, label: 'Torch'),
          ],
        ),
        const SizedBox(height: AppSpacing.tight),
        Text(
          'Available after scanner integration',
          style: AppTypography.compactLabel.copyWith(
            color: AppColors.scannerForeground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// A visually present but non-functional scanner control. Camera, gallery
/// and torch integration are out of scope for this milestone.
class _ScannerActionButton extends StatelessWidget {
  const _ScannerActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label — available after scanner integration',
      child: Semantics(
        label: label,
        hint: 'Available after scanner integration',
        button: true,
        enabled: false,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Icon(
            icon,
            color: AppColors.scannerForeground.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
