import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/barcode_symbology.dart';
import '../../enums/isbn_format.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../../failures/scan_parse_warning.dart';
import '../../normalization/isbn_normalization.dart';
import '../../normalization/product_identifier_normalization.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Recognizes ISBN-10 and ISBN-13 values.
///
/// A 13-digit EAN-13 barcode only qualifies when it carries the `978`/`979`
/// Bookland prefix — "not every EAN-13 is an ISBN" per the milestone
/// contract, so an ordinary EAN-13 declines here and is picked up by
/// [ProductParser] instead. A bare 10-digit textual value is deliberately
/// *not* enough on its own (too ambiguous with phone numbers, IDs, etc.);
/// it must be hyphen-grouped (`0-306-40615-2`) or `ISBN`-labeled to be
/// recognized, so ordinary numeric text is never misclassified.
class IsbnParser implements ScanPayloadParser {
  const IsbnParser();

  @override
  bool canParse(ScanCandidate candidate) {
    final raw = candidate.rawValue.trim();

    if (candidate.symbology == BarcodeSymbology.ean13) {
      return RegExp(r'^(978|979)\d{10}$').hasMatch(raw);
    }

    if (raw.toUpperCase().startsWith('ISBN')) {
      final remainder = raw
          .substring('ISBN'.length)
          .replaceFirst(RegExp(r'^[:\s]+'), '');
      final strippedRemainder = remainder.replaceAll(RegExp(r'[\s-]'), '');
      return RegExp(r'^(\d{9}[\dXx]|\d{13})$').hasMatch(strippedRemainder);
    }

    final stripped = raw.replaceAll(RegExp(r'[\s-]'), '');
    final looksHyphenGrouped =
        raw.contains('-') && (stripped.length == 10 || stripped.length == 13);
    return looksHyphenGrouped &&
        RegExp(r'^(\d{9}[\dXx]|\d{13})$').hasMatch(stripped);
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final raw = candidate.rawValue.trim();
    var working = raw;
    if (working.toUpperCase().startsWith('ISBN')) {
      working = working
          .substring('ISBN'.length)
          .replaceFirst(RegExp(r'^[:\s]+'), '');
    }
    final stripped = working.replaceAll(RegExp(r'[\s-]'), '');

    if (stripped.length == 13 && RegExp(r'^\d{13}$').hasMatch(stripped)) {
      final isValid = isValidGtinCheckDigit(stripped);
      return ScanParseSuccess(
        kind: ScanKind.isbn,
        payload: IsbnPayload(
          rawValue: raw,
          format: IsbnFormat.isbn13,
          normalized: stripped,
          isValidCheckDigit: isValid,
        ),
        title: 'ISBN $stripped',
        normalizedValue: stripped,
        warnings: isValid ? const [] : const [_invalidCheckDigitWarning],
      );
    }

    if (stripped.length == 10 && RegExp(r'^\d{9}[\dXx]$').hasMatch(stripped)) {
      final upper = stripped.toUpperCase();
      final isValid = isValidIsbn10CheckDigit(upper);
      final isbn13 = convertIsbn10ToIsbn13(stripped.substring(0, 9));
      return ScanParseSuccess(
        kind: ScanKind.isbn,
        payload: IsbnPayload(
          rawValue: raw,
          format: IsbnFormat.isbn10,
          normalized: isbn13,
          isValidCheckDigit: isValid,
        ),
        title: 'ISBN $upper',
        normalizedValue: isbn13,
        warnings: isValid ? const [] : const [_invalidCheckDigitWarning],
      );
    }

    return const ScanParseFailed(
      UnsupportedStructuredPayloadFailure('unrecognized isbn shape'),
    );
  }
}

const _invalidCheckDigitWarning = ScanParseWarning(
  code: 'invalid-isbn-check-digit',
  message: "This ISBN's check digit did not match.",
);
