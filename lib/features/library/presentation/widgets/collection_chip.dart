import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';

/// A tappable chip showing a collection's name and live item count. Visual
/// language matches the existing type-badge/chip pattern in
/// `result_header.dart` (`secondaryContainer` for the emphasized state)
/// rather than inventing a new chip style.
class CollectionChip extends StatelessWidget {
  const CollectionChip({
    required this.label,
    required this.count,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = selected
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: '$label, $count scans',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.standard,
              vertical: AppSpacing.tight,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              '$label · $count',
              style: AppTypography.compactLabel.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
