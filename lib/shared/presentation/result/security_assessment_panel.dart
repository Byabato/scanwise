import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/security_assessment_fixture.dart';

/// Structural-risk banner + findings list. Severity is always communicated
/// through icon, text and color together — never color alone — per
/// docs/design/design-system.md's warning design rules. Language stays
/// within docs/product/non-goals.md: structural signals only, never a
/// safety/reputation certainty claim.
class SecurityAssessmentPanel extends StatelessWidget {
  const SecurityAssessmentPanel({required this.assessment, super.key});

  final SecurityAssessmentFixture assessment;

  static Color _tint(ResultRiskLevel severity) => switch (severity) {
    ResultRiskLevel.critical => AppColors.critical,
    ResultRiskLevel.caution => AppColors.caution,
    ResultRiskLevel.none => AppColors.positive,
  };

  static IconData _icon(ResultRiskLevel severity) => switch (severity) {
    ResultRiskLevel.critical => Icons.gpp_bad_outlined,
    ResultRiskLevel.caution => Icons.warning_amber_rounded,
    ResultRiskLevel.none => Icons.verified_outlined,
  };

  static String _severityLabel(ResultRiskLevel severity) => switch (severity) {
    ResultRiskLevel.critical => 'Critical',
    ResultRiskLevel.caution => 'Caution',
    ResultRiskLevel.none => 'No warning',
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tint = _tint(assessment.severity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              '${_severityLabel(assessment.severity)}: '
              '${assessment.headline}. ${assessment.explanation}',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.standard),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                border: Border.all(color: tint.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_icon(assessment.severity), color: tint),
                  const SizedBox(width: AppSpacing.compact),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.headline,
                          style: AppTypography.cardTitle.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.micro),
                        Text(
                          assessment.explanation,
                          style: AppTypography.supportingText.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (assessment.findings.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.standard),
          for (final finding in assessment.findings)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.compact),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.tight),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          finding.title,
                          style: AppTypography.body.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          finding.explanation,
                          style: AppTypography.supportingText.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
