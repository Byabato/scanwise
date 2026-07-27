import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/result_action_fixture.dart';
import 'result_action_dispatch.dart';

/// Equal-weight row of secondary actions (Copy / Share / Save and similar),
/// kept subordinate to the one primary action per
/// docs/design/design-system.md's result hierarchy.
class SecondaryActionRow extends StatelessWidget {
  const SecondaryActionRow({required this.actions, this.onPressed, super.key});

  final List<ResultActionFixture> actions;
  final ResultActionCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.tight),
          Expanded(
            child: _SecondaryActionButton(
              action: actions[i],
              onPressed: onPressed,
            ),
          ),
        ],
      ],
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.action, this.onPressed});

  final ResultActionFixture action;
  final ResultActionCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = action.tier == ResultActionTier.disabled;
    final content = SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: isDisabled
            ? null
            : () => (onPressed ?? handleResultAction)(context, action),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.micro),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 20),
            const SizedBox(height: 4),
            Text(
              action.label,
              style: AppTypography.compactLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    if (!isDisabled) return content;

    return Tooltip(
      message: action.semanticHint ?? '',
      child: Semantics(
        button: true,
        enabled: false,
        hint: action.semanticHint,
        child: content,
      ),
    );
  }
}
