import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/enums/isbn_format.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/isbn_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = IsbnParser();

  group('IsbnParser.canParse', () {
    test('accepts a 978-prefixed EAN-13', () {
      expect(
        parser.canParse(
          candidate('9780306406157', symbology: BarcodeSymbology.ean13),
        ),
        isTrue,
      );
    });

    test('declines an EAN-13 that is not ISBN-prefixed', () {
      expect(
        parser.canParse(
          candidate('4006381333931', symbology: BarcodeSymbology.ean13),
        ),
        isFalse,
      );
    });

    test('accepts a hyphen-grouped ISBN-10', () {
      expect(parser.canParse(candidate('0-306-40615-2')), isTrue);
    });

    test('accepts an ISBN-labeled value', () {
      expect(parser.canParse(candidate('ISBN 0306406152')), isTrue);
    });

    test('declines a bare unlabeled 10-digit number', () {
      expect(parser.canParse(candidate('0306406152')), isFalse);
    });

    test('declines non-digit input', () {
      expect(parser.canParse(candidate('ISBN abcdefghij')), isFalse);
    });
  });

  group('IsbnParser.parse', () {
    test('validates a correct ISBN-13 check digit', () {
      final result =
          parser.parse(
                candidate('9780306406157', symbology: BarcodeSymbology.ean13),
              )
              as ScanParseSuccess;
      final payload = result.payload as IsbnPayload;
      expect(payload.format, IsbnFormat.isbn13);
      expect(payload.isValidCheckDigit, isTrue);
      expect(result.warnings, isEmpty);
    });

    test(
      'flags an invalid ISBN-13 check digit with a warning, not a failure',
      () {
        final result =
            parser.parse(
                  candidate('9780306406150', symbology: BarcodeSymbology.ean13),
                )
                as ScanParseSuccess;
        final payload = result.payload as IsbnPayload;
        expect(payload.isValidCheckDigit, isFalse);
        expect(result.warnings, isNotEmpty);
      },
    );

    test('validates a correct ISBN-10 and converts it to ISBN-13', () {
      final result =
          parser.parse(candidate('0-306-40615-2')) as ScanParseSuccess;
      final payload = result.payload as IsbnPayload;
      expect(payload.format, IsbnFormat.isbn10);
      expect(payload.isValidCheckDigit, isTrue);
      expect(payload.normalized, '9780306406157');
    });

    test('handles an ISBN-10 with an X check digit', () {
      final result =
          parser.parse(candidate('ISBN 097522980X')) as ScanParseSuccess;
      final payload = result.payload as IsbnPayload;
      expect(payload.isValidCheckDigit, isTrue);
    });
  });
}
