import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/sms_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = SmsParser();

  group('SmsParser.canParse', () {
    test('accepts sms:', () {
      expect(parser.canParse(candidate('sms:+255754000111')), isTrue);
    });

    test('accepts smsto:', () {
      expect(parser.canParse(candidate('smsto:+255754000111')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('+255754000111')), isFalse);
    });
  });

  group('SmsParser.parse', () {
    test('parses smsto: with a colon-separated body', () {
      final result =
          parser.parse(
                candidate('smsto:+255754000111:REG 2026 to confirm attendance'),
              )
              as ScanParseSuccess;
      final payload = result.payload as SmsPayload;
      expect(payload.recipient, '+255754000111');
      expect(payload.body, 'REG 2026 to confirm attendance');
    });

    test('parses sms: with a query-style body', () {
      final result =
          parser.parse(candidate('sms:+255754000111?body=Hello%20there'))
              as ScanParseSuccess;
      final payload = result.payload as SmsPayload;
      expect(payload.recipient, '+255754000111');
      expect(payload.body, 'Hello there');
    });

    test('parses a recipient with no body', () {
      final result =
          parser.parse(candidate('sms:+255754000111')) as ScanParseSuccess;
      final payload = result.payload as SmsPayload;
      expect(payload.body, isNull);
    });

    test('fails safely with no recipient', () {
      final result = parser.parse(candidate('smsto::hello'));
      expect(result, isA<ScanParseFailed>());
    });
  });
}
