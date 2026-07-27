import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../widgets/scanner_surface.dart';

/// Scanner "gallery loading" state: shown briefly while a picked gallery
/// image is analyzed. Deterministic fixture state — not driven by a
/// simulated delay or fake async work.
class GalleryLoadingState extends StatelessWidget {
  const GalleryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerSurface(
      centerContent: Semantics(
        liveRegion: true,
        label: 'Analyzing selected image',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.scannerForeground),
            const SizedBox(height: AppSpacing.standard),
            Text(
              'Analyzing selected image…',
              style: AppTypography.body.copyWith(
                color: AppColors.scannerForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
