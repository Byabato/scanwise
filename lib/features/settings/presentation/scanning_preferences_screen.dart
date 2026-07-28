import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'widgets/settings_section.dart';

/// Scanning preferences from docs/product/v1-scope.md's Settings list:
/// haptic feedback and confirmation before external actions. "Default
/// camera" is shown as an honestly-disabled selector since there is no
/// camera integration to back a real choice yet.
class ScanningPreferencesScreen extends StatefulWidget {
  const ScanningPreferencesScreen({super.key});

  @override
  State<ScanningPreferencesScreen> createState() =>
      _ScanningPreferencesScreenState();
}

class _ScanningPreferencesScreenState extends State<ScanningPreferencesScreen> {
  bool _hapticFeedback = true;
  bool _confirmBeforeExternalActions = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Scanning preferences')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          SettingsSection(
            title: 'Scanning',
            children: [
              SettingsToggleRow(
                icon: Icons.vibration,
                title: 'Haptic feedback',
                subtitle: 'Vibrate when a code is detected.',
                value: _hapticFeedback,
                onChanged: (value) => setState(() => _hapticFeedback = value),
              ),
              SettingsToggleRow(
                icon: Icons.verified_user_outlined,
                title: 'Confirm before external actions',
                subtitle: 'Ask before opening links or other risky actions.',
                value: _confirmBeforeExternalActions,
                onChanged: (value) =>
                    setState(() => _confirmBeforeExternalActions = value),
              ),
              const SettingsDisabledRow(
                icon: Icons.camera_alt_outlined,
                title: 'Default camera',
                subtitle: 'Back camera',
                disabledReason:
                    'Camera selection will be available once camera '
                    'integration is connected.',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.tight),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.tight),
            child: Text(
              'Resets when you restart the app.',
              style: AppTypography.supportingText.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
