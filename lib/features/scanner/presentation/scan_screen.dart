import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'widgets/scan_frame.dart';
import 'widgets/scanner_surface.dart';

/// Default Scan destination. Presents the scanner-style surface, frame and
/// controls that camera integration will later drive. No camera preview or
/// scanning logic exists yet — this screen is intentionally static.
///
/// The other six scanner states (detected, gallery loading, unavailable, no
/// code found, permission denied, permission permanently denied) are
/// self-contained widgets under `presentation/states/`, reachable only from
/// the `kDebugMode`-gated component gallery — not from this screen.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerSurface(
      centerContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScanFrame(color: AppColors.scannerFrameIdle),
          const SizedBox(height: AppSpacing.major),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.major),
            child: Text(
              'Position a QR code or barcode inside the frame. ScanWise '
              'will explain it before you open or save anything.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.scannerForeground,
              ),
            ),
          ),
        ],
      ),
      footer: const _ScanControls(),
    );
  }
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
