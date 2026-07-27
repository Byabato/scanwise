import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';

/// Scanner "unavailable" state: shown if the camera failed to initialize.
class ScannerUnavailableState extends StatelessWidget {
  const ScannerUnavailableState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: EmptyState(
        icon: Icons.videocam_off_outlined,
        title: 'Scanner unavailable',
        message:
            "ScanWise couldn't start the camera. This can happen if "
            "another app is using it or the device doesn't support "
            'scanning.',
        action: Tooltip(
          message:
              'Retrying the camera will be available once scanner '
              'integration is connected.',
          child: Semantics(
            button: true,
            enabled: false,
            child: PrimaryButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }
}
