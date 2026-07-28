import '../enums/barcode_symbology.dart';
import '../enums/scan_source.dart';

/// The unparsed input to the parsing pipeline: exactly what a decoder
/// produced, plus the context needed to interpret it correctly.
///
/// Deliberately has no dependency on `mobile_scanner` or any other capture
/// plugin — the scanner integration boundary (a later milestone) maps its
/// plugin-specific barcode object into this type.
class ScanCandidate {
  const ScanCandidate({
    required this.rawValue,
    required this.symbology,
    required this.source,
    required this.capturedAt,
  });

  /// The exact decoded text, unmodified. Treated as potentially sensitive
  /// everywhere it flows — see docs/engineering/privacy-and-security.md.
  final String rawValue;

  final BarcodeSymbology symbology;
  final ScanSource source;
  final DateTime capturedAt;
}
