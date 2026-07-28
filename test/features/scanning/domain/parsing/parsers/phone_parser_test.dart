import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/phone_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = PhoneParser();

  group('PhoneParser.canParse', () {
    test('accepts tel:', () {
      expect(parser.canParse(candidate('tel:+255222410500')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('+255222410500')), isFalse);
    });
  });

  group('PhoneParser.parse', () {
    test('preserves an international prefix', () {
      final result =
          parser.parse(candidate('tel:+255 22 241 0500')) as ScanParseSuccess;
      final payload = result.payload as PhonePayload;
      expect(payload.normalizedNumber, '+255222410500');
    });

    test('parses an extension', () {
      final result =
          parser.parse(candidate('tel:+14155550142;ext=123'))
              as ScanParseSuccess;
      final payload = result.payload as PhonePayload;
      expect(payload.normalizedNumber, '+14155550142');
      expect(payload.extension, '123');
    });

    test('strips formatting punctuation without a leading plus', () {
      final result =
          parser.parse(candidate('tel:(022) 241-0500')) as ScanParseSuccess;
      final payload = result.payload as PhonePayload;
      expect(payload.normalizedNumber, '0222410500');
    });

    test('fails safely with no digits', () {
      final result = parser.parse(candidate('tel:'));
      expect(result, isA<ScanParseFailed>());
    });
  });
}
