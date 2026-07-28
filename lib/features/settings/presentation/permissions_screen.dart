import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'widgets/settings_section.dart';

/// Permission management. Camera status is reported honestly: ScanWise has
/// no camera integration in this milestone, so it has never actually
/// requested the permission — this is a fact, not a preview placeholder.
/// "Open app settings" is a disabled affordance, matching the
/// Tooltip + Semantics(enabled: false) pattern used for other
/// not-yet-connected actions (see ScannerUnavailableState's retry button).
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          SettingsSection(
            title: 'App permissions',
            children: [
              const SettingsRow(
                icon: Icons.camera_alt_outlined,
                title: 'Camera',
                subtitle:
                    "Not yet requested — camera integration isn't "
                    'connected.',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          Tooltip(
            message:
                'Opening app settings will be available once camera '
                'integration is connected.',
            child: Semantics(
              button: true,
              enabled: false,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open app settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
