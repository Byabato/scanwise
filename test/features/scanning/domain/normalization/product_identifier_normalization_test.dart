import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/normalization/isbn_normalization.dart';
import 'package:scanwise/features/scanning/domain/normalization/product_identifier_normalization.dart';

void main() {
  group('normalizeProductIdentifier', () {
    test('trims whitespace but preserves leading zeros', () {
      expect(
        normalizeProductIdentifier('  04006381333931  '),
        '04006381333931',
      );
    });
  });

  group('isValidGtinCheckDigit', () {
    test('validates a correct EAN-13', () {
      expect(isValidGtinCheckDigit('4006381333931'), isTrue);
    });

    test('rejects an incorrect EAN-13', () {
      expect(isValidGtinCheckDigit('4006381333930'), isFalse);
    });

    test('validates a correct UPC-A', () {
      expect(isValidGtinCheckDigit('036000291452'), isTrue);
    });

    test('rejects non-digit input', () {
      expect(isValidGtinCheckDigit('abcdefgh'), isFalse);
    });
  });

  group('ISBN-10/13 conversion and validation', () {
    test('converts ISBN-10 to ISBN-13 using the 978 Bookland prefix', () {
      expect(convertIsbn10ToIsbn13('030640615'), '9780306406157');
    });

    test('validates a correct ISBN-10 check digit', () {
      expect(isValidIsbn10CheckDigit('0306406152'), isTrue);
    });

    test('validates an ISBN-10 check digit of X', () {
      expect(isValidIsbn10CheckDigit('097522980X'), isTrue);
    });

    test('rejects an incorrect ISBN-10 check digit', () {
      expect(isValidIsbn10CheckDigit('0306406150'), isFalse);
    });
  });
}
