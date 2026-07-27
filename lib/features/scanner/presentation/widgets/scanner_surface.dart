import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import 'privacy_indicator.dart';

/// Shared dark camera-pipeline chrome (privacy indicator + centered content
/// + optional footer) used by every Scanner state that still represents
/// "in the camera/gallery pipeline": default, detected, gallery loading.
/// States that leave that pipeline (unavailable, no code found, permission
/// denied/permanently denied) use a normal light `Scaffold` instead — they
/// are informational screens, not a camera view.
class ScannerSurface extends StatelessWidget {
  const ScannerSurface({
    required this.centerContent,
    this.footer,
    this.showPrivacyIndicator = true,
    super.key,
  });

  final Widget centerContent;
  final Widget? footer;
  final bool showPrivacyIndicator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scannerSurface,
      body: SafeArea(
        child: Column(
          children: [
            if (showPrivacyIndicator)
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.tight,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PrivacyIndicator(),
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
                      child: Center(child: centerContent),
                    ),
                  );
                },
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.section),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
