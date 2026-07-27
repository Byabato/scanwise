import 'package:flutter/material.dart';

import '../../app/theme/design_tokens.dart';

/// Centralized snackbar presentation so feedback (copy confirmations,
/// preview-only action notices) looks consistent everywhere it's shown.
abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }
}
