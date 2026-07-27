import 'package:flutter/material.dart';

import '../../app/theme/design_tokens.dart';

/// Reusable empty-state layout: icon, title, supporting message and an
/// optional primary action. Used wherever a destination has no content yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.section),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.standard),
                  Text(
                    title,
                    style: AppTypography.sectionTitle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.tight),
                  Text(
                    message,
                    style: AppTypography.body.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.section),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
