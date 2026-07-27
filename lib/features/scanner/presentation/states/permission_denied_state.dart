import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';

/// Scanner "permission denied" state, per
/// docs/product/user-flows.md Flow 10: explains why access is needed and
/// offers to retry or import from the gallery instead. The screen remains
/// usable rather than showing a broken camera.
class PermissionDeniedState extends StatelessWidget {
  const PermissionDeniedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: EmptyState(
        icon: Icons.camera_alt_outlined,
        title: 'Camera access needed',
        message:
            'ScanWise needs camera access to scan QR codes and barcodes. '
            'You can also import an image from your gallery instead.',
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message:
                  'Requesting camera access will be available once '
                  'permission integration is connected.',
              child: Semantics(
                button: true,
                enabled: false,
                child: PrimaryButton(
                  label: 'Try again',
                  icon: Icons.camera_alt_outlined,
                  onPressed: null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.tight),
            Tooltip(
              message:
                  'Importing from your gallery will be available once '
                  'gallery integration is connected.',
              child: Semantics(
                button: true,
                enabled: false,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: null,
                    child: const Text('Import from gallery instead'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
