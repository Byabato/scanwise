import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/product_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = ProductParser();

  group('ProductParser.canParse', () {
    test('accepts an EAN-13 barcode', () {
      expect(
        parser.canParse(
          candidate('4006381333931', symbology: BarcodeSymbology.ean13),
        ),
        isTrue,
      );
    });

    test('declines a QR code with the same digits (not a product)', () {
      expect(
        parser.canParse(
          candidate('4006381333931', symbology: BarcodeSymbology.qrCode),
        ),
        isFalse,
      );
    });

    test('declines non-digit input', () {
      expect(
        parser.canParse(candidate('ABC1234', symbology: BarcodeSymbology.ean8)),
        isFalse,
      );
    });
  });

  group('ProductParser.parse', () {
    test('validates a correct EAN-13 check digit', () {
      final result =
          parser.parse(
                candidate('4006381333931', symbology: BarcodeSymbology.ean13),
              )
              as ScanParseSuccess;
      final payload = result.payload as ProductPayload;
      expect(payload.isCheckDigitValid, isTrue);
    });

    test('flags an incorrect EAN-13 check digit', () {
      final result =
          parser.parse(
                candidate('4006381333930', symbology: BarcodeSymbology.ean13),
              )
              as ScanParseSuccess;
      final payload = result.payload as ProductPayload;
      expect(payload.isCheckDigitValid, isFalse);
    });

    test('validates a UPC-A check digit', () {
      final result =
          parser.parse(
                candidate('036000291452', symbology: BarcodeSymbology.upcA),
              )
              as ScanParseSuccess;
      final payload = result.payload as ProductPayload;
      expect(payload.isCheckDigitValid, isTrue);
    });

    test('does not verify UPC-E (documented limitation)', () {
      final result =
          parser.parse(candidate('01234565', symbology: BarcodeSymbology.upcE))
              as ScanParseSuccess;
      final payload = result.payload as ProductPayload;
      expect(payload.isCheckDigitValid, isNull);
    });

    test('never invents a product name', () {
      final result =
          parser.parse(
                candidate('4006381333931', symbology: BarcodeSymbology.ean13),
              )
              as ScanParseSuccess;
      expect(result.title, 'Product barcode');
    });
  });
}
