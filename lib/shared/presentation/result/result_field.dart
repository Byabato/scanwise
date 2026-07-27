import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/result_field_fixture.dart';

const _maskedValue = '••••••••••••';

/// One interpreted field (label + value). Masked fields (Wi-Fi passwords)
/// render as dots by default with a local reveal toggle — demonstrable,
/// device-local behavior, not a production security control.
class ResultField extends StatefulWidget {
  const ResultField({required this.field, super.key});

  final ResultFieldFixture field;

  @override
  State<ResultField> createState() => _ResultFieldState();
}

class _ResultFieldState extends State<ResultField> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final field = widget.field;
    final obscured = field.masked && !_revealed;
    final displayValue = obscured ? _maskedValue : field.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.icon != null) ...[
            Icon(field.icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.tight),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: AppTypography.compactLabel.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  displayValue,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.onSurface,
                    fontFamily: field.monospace ? 'monospace' : null,
                  ),
                  semanticsLabel: field.masked && obscured
                      ? '${field.label} hidden'
                      : null,
                ),
              ],
            ),
          ),
          if (field.masked)
            IconButton(
              onPressed: () => setState(() => _revealed = !_revealed),
              icon: Icon(
                _revealed
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: _revealed
                  ? 'Hide ${field.label.toLowerCase()}'
                  : 'Reveal ${field.label.toLowerCase()}',
            ),
        ],
      ),
    );
  }
}
