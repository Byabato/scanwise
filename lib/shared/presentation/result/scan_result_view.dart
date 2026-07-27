import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/result_fixture.dart';
import '../../fixtures/models/result_fixture_kind.dart';
import 'primary_result_action_button.dart';
import 'raw_payload_viewer.dart';
import 'result_action_dispatch.dart';
import 'result_field.dart';
import 'result_header.dart';
import 'secondary_action_row.dart';
import 'security_assessment_panel.dart';
import 'technical_details_section.dart';

/// Composes one [ResultFixture] into the full 10-point result hierarchy
/// from docs/design/design-system.md: type/title, interpreted fields,
/// security notice, primary action, secondary actions, technical details,
/// raw payload. Reused as the content of both `ScanResultSheet` (Scanner)
/// and the Library scan detail screen (Milestone 002B), so every result
/// kind is both reachable in-app and independently testable.
class ScanResultView extends StatelessWidget {
  const ScanResultView({
    required this.fixture,
    this.onActionPressed,
    super.key,
  });

  final ResultFixture fixture;

  /// Overrides the default tier-based action behavior in
  /// [handleResultAction]. Left null in Milestone 002 — a later milestone
  /// can supply production handlers here without changing this widget.
  final ResultActionCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ResultHeader(fixture: fixture),
        if (fixture.security != null) ...[
          const SizedBox(height: AppSpacing.standard),
          SecurityAssessmentPanel(assessment: fixture.security!),
        ],
        if (fixture.fields.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.standard),
          Column(
            children: [
              for (final field in fixture.fields) ResultField(field: field),
            ],
          ),
        ],
        if (fixture.kind == ResultFixtureKind.wifi) ...[
          const SizedBox(height: AppSpacing.tight),
          const _WifiPrivacyNotice(),
        ],
        const SizedBox(height: AppSpacing.section),
        PrimaryResultActionButton(
          action: fixture.primaryAction,
          onPressed: onActionPressed,
        ),
        if (fixture.secondaryActions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.compact),
          SecondaryActionRow(
            actions: fixture.secondaryActions,
            onPressed: onActionPressed,
          ),
        ],
        if (fixture.technicalDetails.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.tight),
          TechnicalDetailsSection(fields: fixture.technicalDetails),
        ],
        const SizedBox(height: AppSpacing.tight),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.tight),
        RawPayloadViewer(payload: fixture.rawPayload),
      ],
    );
  }
}

class _WifiPrivacyNotice extends StatelessWidget {
  const _WifiPrivacyNotice();

  @override
  Widget build(BuildContext context) {
    const message =
        'Sharing this result may expose the network password. Share it '
        'only with people you trust.';

    return Semantics(
      label: message,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.compact),
          decoration: BoxDecoration(
            color: AppColors.caution.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.caution,
              ),
              const SizedBox(width: AppSpacing.tight),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.supportingText.copyWith(
                    color: AppColors.caution,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
