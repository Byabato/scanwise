import 'package:flutter/material.dart';

/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
///
/// Every result action is explicitly tiered so the UI can give each tier
/// genuinely different, honest behavior instead of one generic "coming
/// soon" no-op:
///
/// - [demonstrable]: real, local behavior with no new dependency (Copy, via
///   `Clipboard`). Requires [copyValue].
/// - [previewOnly]: opens real UI but the terminal effect is a preview
///   snackbar rather than a lasting change (Share, Save). Requires
///   [previewMessage].
/// - [disabled]: needs an integration excluded from this milestone (Open,
///   Call, Compose email...). Rendered with a real disabled button state.
///   Requires [semanticHint].
enum ResultActionTier { demonstrable, previewOnly, disabled }

class ResultActionFixture {
  const ResultActionFixture({
    required this.label,
    required this.icon,
    required this.tier,
    this.copyValue,
    this.previewMessage,
    this.semanticHint,
  }) : assert(
         tier != ResultActionTier.demonstrable || copyValue != null,
         'Demonstrable actions must provide copyValue.',
       ),
       assert(
         tier != ResultActionTier.previewOnly || previewMessage != null,
         'Preview-only actions must provide previewMessage.',
       ),
       assert(
         tier != ResultActionTier.disabled || semanticHint != null,
         'Disabled actions must provide semanticHint.',
       );

  final String label;
  final IconData icon;
  final ResultActionTier tier;

  /// The clipboard text used when [tier] is [ResultActionTier.demonstrable].
  final String? copyValue;

  /// The snackbar message shown when [tier] is [ResultActionTier.previewOnly].
  final String? previewMessage;

  /// Explains why the action is disabled when [tier] is
  /// [ResultActionTier.disabled].
  final String? semanticHint;
}
