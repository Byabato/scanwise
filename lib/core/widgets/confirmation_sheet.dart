import 'package:flutter/material.dart';

import '../../app/theme/design_tokens.dart';

/// Reusable confirm/cancel bottom sheet for decisions worth a deliberate
/// stop — e.g. deleting a Library item. Demonstrates confirm/cancel
/// interaction only; callers decide what confirming actually does.
class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /// Shows the sheet and resolves to `true` if confirmed, `false` if
  /// cancelled or dismissed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (context) => ConfirmationSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.standard,
          AppSpacing.screen,
          AppSpacing.standard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.section),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              ),
            ),
            Text(
              title,
              style: AppTypography.sectionTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.tight),
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: isDestructive
                  ? FilledButton.styleFrom(
                      backgroundColor: AppColors.critical,
                      foregroundColor: Colors.white,
                    )
                  : null,
              child: Text(confirmLabel),
            ),
            const SizedBox(height: AppSpacing.tight),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
          ],
        ),
      ),
    );
  }
}
