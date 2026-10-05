import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/theme/design_tokens.dart';
import 'widgets/scan_frame.dart';
import 'widgets/scanner_surface.dart';
import '../../../shared/presentation/result/scan_result_sheet.dart';
import '../../scanning/domain/entities/scan_candidate.dart';
import '../../scanning/domain/enums/barcode_symbology.dart';
import '../../scanning/domain/enums/scan_source.dart';
import '../../scanning/domain/parsing/parser_registry.dart';
import '../../scanning/domain/parsing/scan_parse_outcome.dart';
import '../../scanning/presentation/mapping/parsed_scan_presentation_mapper.dart';

/// Default Scan destination. Presents the scanner-style surface, frame and
/// controls that camera integration will later drive. No camera preview or
/// scanning logic exists yet — this screen is intentionally static.
///
/// The other six scanner states (detected, gallery loading, unavailable, no
/// code found, permission denied, permission permanently denied) are
/// self-contained widgets under `presentation/states/`, reachable only from
/// the `kDebugMode`-gated component gallery — not from this screen.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final _controller = MobileScannerController();
  final _registry = ParserRegistry();
  DateTime? _lastAcceptedAt;
  String? _lastRawValue;
  bool _handlingResult = false;
  PermissionStatus _permission = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) setState(() => _permission = status);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permission.isGranted) {
      _controller.start();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handlingResult) return;
    final barcode = capture.barcodes.firstWhere(
      (item) => item.rawValue?.isNotEmpty == true,
      orElse: () => capture.barcodes.first,
    );
    final raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) return;
    final now = DateTime.now();
    if (_lastRawValue == raw &&
        _lastAcceptedAt != null &&
        now.difference(_lastAcceptedAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastRawValue = raw;
    _lastAcceptedAt = now;
    _handlingResult = true;
    await _controller.stop();
    HapticFeedback.selectionClick();
    final outcome = _registry.parse(
      ScanCandidate(
        rawValue: raw,
        symbology: _mapFormat(barcode.format),
        source: ScanSource.camera,
        capturedAt: now,
      ),
    );
    if (!mounted) return;
    switch (outcome) {
      case ScanParseOutcomeSuccess(:final scan):
        await ScanResultSheet.show(context, mapParsedScanToResultFixture(scan));
        if (mounted) {
          _handlingResult = false;
          await _controller.start();
        }
      case ScanParseOutcomeFailure():
        _handlingResult = false;
        _controller.start();
    }
  }

  BarcodeSymbology _mapFormat(BarcodeFormat format) => switch (format) {
    BarcodeFormat.qrCode => BarcodeSymbology.qrCode,
    BarcodeFormat.ean8 => BarcodeSymbology.ean8,
    BarcodeFormat.ean13 => BarcodeSymbology.ean13,
    BarcodeFormat.upcA => BarcodeSymbology.upcA,
    BarcodeFormat.upcE => BarcodeSymbology.upcE,
    BarcodeFormat.code128 => BarcodeSymbology.code128,
    BarcodeFormat.dataMatrix => BarcodeSymbology.dataMatrix,
    BarcodeFormat.pdf417 => BarcodeSymbology.pdf417,
    BarcodeFormat.aztec => BarcodeSymbology.aztec,
    _ => BarcodeSymbology.unknown,
  };

  @override
  Widget build(BuildContext context) {
    if (!_permission.isGranted) {
      final permanentlyDenied = _permission.isPermanentlyDenied;
      return ScannerSurface(
        centerContent: _PermissionState(
          permanentlyDenied: permanentlyDenied,
          onRetry: permanentlyDenied ? openAppSettings : _requestPermission,
        ),
        footer: const SizedBox.shrink(),
      );
    }
    return ScannerSurface(
      centerContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 280,
            child: MobileScanner(controller: _controller, onDetect: _onDetect),
          ),
          const ScanFrame(color: AppColors.scannerFrameIdle),
          const SizedBox(height: AppSpacing.major),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.major),
            child: Text(
              'Position a QR code or barcode inside the frame. ScanWise '
              'will explain it before you open or save anything.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.scannerForeground,
              ),
            ),
          ),
        ],
      ),
      footer: _ScanControls(controller: _controller),
    );
  }
}

class _PermissionState extends StatelessWidget {
  const _PermissionState({
    required this.permanentlyDenied,
    required this.onRetry,
  });
  final bool permanentlyDenied;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 48),
      const SizedBox(height: AppSpacing.standard),
      Text(
        permanentlyDenied ? 'Camera access is off' : 'Camera permission needed',
        style: AppTypography.sectionTitle.copyWith(color: Colors.white),
      ),
      const SizedBox(height: AppSpacing.tight),
      Text(
        permanentlyDenied
            ? 'Enable camera access in Android settings to scan codes.'
            : 'Allow camera access to scan a QR code or barcode.',
        textAlign: TextAlign.center,
        style: AppTypography.body.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: AppSpacing.tight),
      const Text(
        'Position a QR code or barcode inside the frame. ScanWise will explain it before you open or save anything.',
        textAlign: TextAlign.center,
        style: AppTypography.body,
      ),
      const SizedBox(height: AppSpacing.standard),
      FilledButton(
        onPressed: onRetry,
        child: Text(permanentlyDenied ? 'Open settings' : 'Allow camera'),
      ),
    ],
  );
}

class _ScanControls extends StatelessWidget {
  const _ScanControls({required this.controller});
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScannerActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Import from gallery',
            ),
            SizedBox(width: AppSpacing.section),
            IconButton(
              onPressed: controller.toggleTorch,
              icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
              tooltip: 'Torch',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.tight),
        Text(
          'Point the camera at a code',
          style: AppTypography.compactLabel.copyWith(
            color: AppColors.scannerForeground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// A visually present but non-functional scanner control. Camera, gallery
/// and torch integration are out of scope for this milestone.
class _ScannerActionButton extends StatelessWidget {
  const _ScannerActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label — available after scanner integration',
      child: Semantics(
        label: label,
        hint: 'Available after scanner integration',
        button: true,
        enabled: false,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Icon(
            icon,
            color: AppColors.scannerForeground.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
