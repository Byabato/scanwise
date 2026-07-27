import 'package:flutter/material.dart';

import '../../fixtures/models/result_action_fixture.dart';
import 'result_action_dispatch.dart';

/// The one dominant primary action for a result. Disabled-tier actions
/// (docs/design/design-system.md: "buttons should communicate their
/// consequence") render with a real disabled button state and a semantic
/// hint explaining why, rather than a tappable no-op.
class PrimaryResultActionButton extends StatelessWidget {
  const PrimaryResultActionButton({
    required this.action,
    this.onPressed,
    super.key,
  });

  final ResultActionFixture action;
  final ResultActionCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = action.tier == ResultActionTier.disabled;
    final button = SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isDisabled
            ? null
            : () => (onPressed ?? handleResultAction)(context, action),
        icon: Icon(action.icon),
        label: Text(action.label),
      ),
    );

    if (!isDisabled) return button;

    return Tooltip(
      message: action.semanticHint ?? '',
      child: Semantics(
        button: true,
        enabled: false,
        hint: action.semanticHint,
        child: button,
      ),
    );
  }
}
