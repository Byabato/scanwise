import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_snackbar.dart';
import '../../fixtures/models/result_action_fixture.dart';

typedef ResultActionCallback =
    void Function(BuildContext context, ResultActionFixture action);

/// Default tier-based behavior for a [ResultActionFixture] tap:
/// [ResultActionTier.demonstrable] actions really copy to the clipboard,
/// [ResultActionTier.previewOnly] actions show their preview message, and
/// [ResultActionTier.disabled] actions never reach here (their button has
/// no `onPressed`). A later milestone can pass a different callback into
/// `ScanResultView` to swap in production handlers without touching
/// fixture data or this default.
void handleResultAction(BuildContext context, ResultActionFixture action) {
  switch (action.tier) {
    case ResultActionTier.demonstrable:
      Clipboard.setData(ClipboardData(text: action.copyValue ?? ''));
      AppSnackbar.show(context, 'Copied to clipboard');
    case ResultActionTier.previewOnly:
      AppSnackbar.show(context, action.previewMessage!);
    case ResultActionTier.disabled:
      break;
  }
}
