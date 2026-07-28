import 'package:scanwise/features/scanning/domain/entities/scan_candidate.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/enums/scan_source.dart';

/// Builds a [ScanCandidate] with sensible defaults so parser tests only
/// need to specify what's relevant to the case under test.
ScanCandidate candidate(
  String rawValue, {
  BarcodeSymbology symbology = BarcodeSymbology.qrCode,
  ScanSource source = ScanSource.camera,
  DateTime? capturedAt,
}) {
  return ScanCandidate(
    rawValue: rawValue,
    symbology: symbology,
    source: source,
    capturedAt: capturedAt ?? DateTime.utc(2026, 1, 1),
  );
}
