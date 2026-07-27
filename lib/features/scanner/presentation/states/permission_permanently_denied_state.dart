import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';

/// Scanner "permission permanently denied" state: Android no longer shows
/// its own permission prompt at this point, so the only path forward is the
/// system app settings screen.
class PermissionPermanentlyDeniedState extends StatelessWidget {
  const PermissionPermanentlyDeniedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: EmptyState(
        icon: Icons.no_photography_outlined,
        title: 'Camera access is turned off',
        message:
            "Camera access was permanently denied. Turn it on in your "
            "device's app settings to use the scanner.",
        action: Tooltip(
          message:
              'Opening app settings will be available once permission '
              'integration is connected.',
          child: Semantics(
            button: true,
            enabled: false,
            child: PrimaryButton(
              label: 'Open app settings',
              icon: Icons.settings_outlined,
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }
}
