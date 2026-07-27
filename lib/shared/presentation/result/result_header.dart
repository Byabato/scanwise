import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/result_fixture.dart';
import '../../fixtures/models/result_fixture_kind.dart';

/// Type badge, title and subtitle — points 1-2 of the result hierarchy in
/// docs/design/design-system.md. URL kinds get the "domain reveal"
/// treatment: an eyebrow label and a prominent extracted destination as the
/// title, so the real destination is always more prominent than the full
/// raw address (shown later, in technical details / raw payload).
class ResultHeader extends StatelessWidget {
  const ResultHeader({required this.fixture, super.key});

  final ResultFixture fixture;

  bool get _isUrlKind =>
      fixture.kind == ResultFixtureKind.trustedUrl ||
      fixture.kind == ResultFixtureKind.suspiciousUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      header: true,
      label: '${fixture.typeLabel}. ${fixture.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeBadge(label: fixture.typeLabel),
          const SizedBox(height: AppSpacing.tight),
          if (_isUrlKind && fixture.subtitle != null) ...[
            ExcludeSemantics(
              child: Text(
                fixture.subtitle!.toUpperCase(),
                style: AppTypography.compactLabel.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.micro),
          ],
          ExcludeSemantics(
            child: Text(
              fixture.title,
              style:
                  (_isUrlKind
                          ? AppTypography.screenTitle
                          : AppTypography.sectionTitle)
                      .copyWith(
                        color: _isUrlKind
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
            ),
          ),
          if (!_isUrlKind && fixture.subtitle != null) ...[
            const SizedBox(height: AppSpacing.micro),
            ExcludeSemantics(
              child: Text(
                fixture.subtitle!,
                style: AppTypography.supportingText.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

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
        label,
        style: AppTypography.compactLabel.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
