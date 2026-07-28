import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'widgets/settings_section.dart';

class _Format {
  const _Format(this.code, this.description);

  final String code;
  final String description;
}

/// The exact symbology list from docs/product/v1-scope.md's
/// "Supported symbologies" section, grouped by 2D vs. linear so the list
/// reads sensibly rather than as a flat dump. Descriptions are limited to
/// widely-known facts about each format — nothing claimed about ScanWise's
/// own behavior beyond what v1-scope.md already states.
const _twoDimensionalFormats = [
  _Format('QR Code', 'Square matrix code, the most common 2D format.'),
  _Format('Data Matrix', 'Compact matrix code often used on small items.'),
  _Format('PDF417', 'Stacked linear code used on IDs and shipping labels.'),
  _Format('Aztec', 'Matrix code with a distinctive square target center.'),
];

const _linearFormats = [
  _Format('EAN-8', 'Short retail barcode for small packaging.'),
  _Format('EAN-13', 'Standard 13-digit retail product barcode.'),
  _Format('UPC-A', '12-digit retail barcode common in North America.'),
  _Format('UPC-E', 'Compressed variant of UPC-A for small packaging.'),
  _Format('Code 128', 'High-density linear barcode used in logistics.'),
];

/// A static, non-interactive list of the barcode and QR symbologies
/// ScanWise recognizes.
class SupportedFormatsScreen extends StatelessWidget {
  const SupportedFormatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Supported formats')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.standard,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.tight,
              bottom: AppSpacing.standard,
            ),
            child: Text(
              'ScanWise recognizes the following code formats. Supported '
              'formats may be restricted where required for performance.',
              style: AppTypography.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SettingsSection(
            title: '2D codes',
            children: [
              for (final format in _twoDimensionalFormats)
                SettingsRow(
                  icon: Icons.qr_code_outlined,
                  title: format.code,
                  subtitle: format.description,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          SettingsSection(
            title: 'Linear barcodes',
            children: [
              for (final format in _linearFormats)
                SettingsRow(
                  icon: Icons.barcode_reader,
                  title: format.code,
                  subtitle: format.description,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
