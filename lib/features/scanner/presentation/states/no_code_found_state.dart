import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';

/// Scanner "no code found" state: shown after a gallery image is analyzed
/// and no QR code or barcode was detected in it.
class NoCodeFoundState extends StatelessWidget {
  const NoCodeFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: EmptyState(
        icon: Icons.search_off,
        title: 'No code found',
        message:
            "ScanWise couldn't find a QR code or barcode in that image. "
            'Try another image or line it up more closely.',
        action: Tooltip(
          message:
              'Importing another image will be available once gallery '
              'integration is connected.',
          child: Semantics(
            button: true,
            enabled: false,
            child: PrimaryButton(
              label: 'Try another image',
              icon: Icons.photo_library_outlined,
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }
}
