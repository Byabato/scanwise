import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../fixtures/models/result_fixture.dart';
import 'scan_result_view.dart';

/// Modal bottom-sheet chrome around [ScanResultView], per
/// docs/design/interaction-spec.md: "use a modal bottom sheet or an
/// equivalent compact result surface" that "allows dismissal" and
/// "preserves camera context in the background". Used by the Scanner
/// "detected" state.
class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({required this.fixture, super.key});

  final ResultFixture fixture;

  static Future<void> show(BuildContext context, ResultFixture fixture) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (context) => ScanResultSheet(fixture: fixture),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.tight,
            AppSpacing.screen,
            AppSpacing.section,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.standard),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
              ),
              ScanResultView(fixture: fixture),
            ],
          ),
        ),
      ),
    );
  }
}
