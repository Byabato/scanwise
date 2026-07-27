import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../../shared/fixtures/models/result_fixture.dart';
import '../../../../shared/presentation/result/scan_result_sheet.dart';
import '../widgets/scan_frame.dart';
import '../widgets/scanner_surface.dart';

/// Scanner "detected" state: the frame tints to indicate a successful scan
/// and the result sheet opens over the camera background, per
/// docs/design/interaction-spec.md ("scan acceptance", "result
/// presentation"). Reachable only via the debug component gallery in this
/// milestone — no live detection exists yet.
class ScannerDetectedState extends StatefulWidget {
  const ScannerDetectedState({required this.fixture, super.key});

  final ResultFixture fixture;

  @override
  State<ScannerDetectedState> createState() => _ScannerDetectedStateState();
}

class _ScannerDetectedStateState extends State<ScannerDetectedState> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSheet());
  }

  Future<void> _openSheet() async {
    if (!mounted) return;
    await ScanResultSheet.show(context, widget.fixture);
  }

  @override
  Widget build(BuildContext context) {
    return const ScannerSurface(
      centerContent: ScanFrame(color: AppColors.scannerFrameDetected),
    );
  }
}
