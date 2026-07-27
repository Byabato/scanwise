import 'package:flutter/material.dart';

import '../../app/theme/design_tokens.dart';

/// A small, honest label marking a control that is visible but not yet
/// functional. Used instead of silently disabling controls without
/// explanation.
class ComingSoonTag extends StatelessWidget {
  const ComingSoonTag({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.tight,
        vertical: AppSpacing.micro,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        'Coming soon',
        style: AppTypography.compactLabel.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
