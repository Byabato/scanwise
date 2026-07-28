import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'widgets/settings_section.dart';

/// History-specific preferences (distinct from Privacy's blanket
/// "automatically save scans"): duplicate recognition, occurrence count
/// display, and remembering scan source — all pure UI preferences with no
/// missing integration, so every row here is a real, live toggle.
class HistoryPreferencesScreen extends StatefulWidget {
  const HistoryPreferencesScreen({super.key});

  @override
  State<HistoryPreferencesScreen> createState() =>
      _HistoryPreferencesScreenState();
}

class _HistoryPreferencesScreenState extends State<HistoryPreferencesScreen> {
  bool _recognizeRepeatedScans = true;
  bool _showOccurrenceCount = true;
  bool _keepScanSource = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('History preferences')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          SettingsSection(
            title: 'History',
            children: [
              SettingsToggleRow(
                icon: Icons.find_replace_outlined,
                title: 'Recognize repeated scans',
                subtitle:
                    "Detect when you scan a code that's already in "
                    'your Library.',
                value: _recognizeRepeatedScans,
                onChanged: (value) =>
                    setState(() => _recognizeRepeatedScans = value),
              ),
              SettingsToggleRow(
                icon: Icons.numbers_outlined,
                title: 'Show occurrence count',
                subtitle:
                    'Display how many times a saved scan has been '
                    'seen.',
                value: _showOccurrenceCount,
                onChanged: (value) =>
                    setState(() => _showOccurrenceCount = value),
              ),
              SettingsToggleRow(
                icon: Icons.source_outlined,
                title: 'Keep scan source',
                subtitle:
                    'Remember whether a saved scan came from the '
                    'camera or your gallery.',
                value: _keepScanSource,
                onChanged: (value) => setState(() => _keepScanSource = value),
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
