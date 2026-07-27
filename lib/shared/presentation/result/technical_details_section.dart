import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/result_field_fixture.dart';
import 'result_field.dart';

/// Progressive-disclosure technical fields (symbology, scan source...).
/// Collapsed by default: technical detail should not dominate the result,
/// per docs/design/design-system.md.
class TechnicalDetailsSection extends StatefulWidget {
  const TechnicalDetailsSection({required this.fields, super.key});

  final List<ResultFieldFixture> fields;

  @override
  State<TechnicalDetailsSection> createState() =>
      _TechnicalDetailsSectionState();
}

class _TechnicalDetailsSectionState extends State<TechnicalDetailsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.fields.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: 'Technical details',
          expanded: _expanded,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
              child: Row(
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        'Technical details',
                        style: AppTypography.cardTitle.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.micro),
            child: Column(
              children: [
                for (final field in widget.fields) ResultField(field: field),
              ],
            ),
          ),
      ],
    );
  }
}
