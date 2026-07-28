import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/barcode_symbology.dart';
import '../../enums/scan_kind.dart';
import '../../normalization/product_identifier_normalization.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Recognizes product-oriented barcodes (EAN-8, EAN-13, UPC-A, UPC-E).
///
/// Requires both a product [BarcodeSymbology] *and* an all-digit shape of
/// the expected length — a QR code containing the same digits is
/// ordinary text, not a product, since [BarcodeSymbology.qrCode] is not
/// in [productSymbologies]. Always declines when [IsbnParser] would
/// already have claimed the value (see registry ordering in
/// `parser_registry.dart`), so this only ever sees non-Bookland codes.
class ProductParser implements ScanPayloadParser {
  const ProductParser();

  static const _expectedLength = {
    BarcodeSymbology.ean8: 8,
    BarcodeSymbology.ean13: 13,
    BarcodeSymbology.upcA: 12,
  };

  @override
  bool canParse(ScanCandidate candidate) {
    if (candidate.symbology == BarcodeSymbology.upcE) {
      final digits = candidate.rawValue.trim();
      return RegExp(r'^\d{6,8}$').hasMatch(digits);
    }
    final expectedLength = _expectedLength[candidate.symbology];
    if (expectedLength == null) return false;
    final digits = candidate.rawValue.trim();
    return digits.length == expectedLength && RegExp(r'^\d+$').hasMatch(digits);
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final digits = normalizeProductIdentifier(candidate.rawValue);

    // UPC-E's check digit requires expansion to UPC-A, which this
    // milestone does not implement — see docs/engineering/parsing-strategy.md.
    final isCheckDigitValid = candidate.symbology == BarcodeSymbology.upcE
        ? null
        : isValidGtinCheckDigit(digits);

    return ScanParseSuccess(
      kind: ScanKind.product,
      payload: ProductPayload(
        identifier: digits,
        symbology: candidate.symbology,
        digits: digits,
        isCheckDigitValid: isCheckDigitValid,
      ),
      title: 'Product barcode',
      subtitle: "Product details aren't available offline.",
      normalizedValue: digits,
    );
  }
}
