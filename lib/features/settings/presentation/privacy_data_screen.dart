import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import 'widgets/settings_section.dart';

/// Privacy and data preferences. Matches
/// docs/design/references/.../privacy_data/code.html's content (on-device
/// processing status, incognito, automatic save, clear history) but uses
/// the same grouped-list row style as the rest of Settings rather than
/// per-row cards.
class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _incognitoScanning = false;
  bool _automaticallySaveScans = true;

  Future<void> _clearScanHistory() async {
    final confirmed = await ConfirmationSheet.show(
      context,
      title: 'Clear scan history?',
      message:
          'This action cannot be undone. All saved scans will be '
          'permanently removed from this device.',
      confirmLabel: 'Clear history',
      isDestructive: true,
    );
    if (!mounted || !confirmed) return;
    AppSnackbar.show(
      context,
      "History cleared (preview) — Library persistence isn't connected yet",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and data')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          SettingsSection(
            title: 'Core privacy',
            children: [
              const SettingsStatusRow(
                icon: Icons.memory_outlined,
                title: 'Process scans on device',
                subtitle: 'Scan analysis never leaves your device.',
                statusLabel: 'Always on',
              ),
              SettingsToggleRow(
                icon: Icons.visibility_off_outlined,
                title: 'Incognito scanning',
                subtitle:
                    "Scans aren't added to your history while this "
                    'is on.',
                value: _incognitoScanning,
                onChanged: (value) =>
                    setState(() => _incognitoScanning = value),
              ),
              SettingsToggleRow(
                icon: Icons.save_outlined,
                title: 'Automatically save scans',
                subtitle: 'Store results in your Library.',
                value: _automaticallySaveScans,
                onChanged: (value) =>
                    setState(() => _automaticallySaveScans = value),
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
          const SizedBox(height: AppSpacing.section),
          SettingsSection(
            title: 'Data management',
            children: [
              SettingsRow(
                icon: Icons.delete_sweep_outlined,
                title: 'Clear scan history',
                subtitle: 'Permanently remove all local scan data',
                destructive: true,
                onTap: _clearScanHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
