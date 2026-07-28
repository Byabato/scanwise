import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/email_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = EmailParser();

  group('EmailParser.canParse', () {
    test('accepts mailto:', () {
      expect(parser.canParse(candidate('mailto:a@example.com')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('a@example.com')), isFalse);
    });
  });

  group('EmailParser.parse', () {
    test('parses a bare address', () {
      final result =
          parser.parse(candidate('mailto:admissions@udsm.ac.tz'))
              as ScanParseSuccess;
      final payload = result.payload as EmailPayload;
      expect(payload.recipients, ['admissions@udsm.ac.tz']);
      expect(payload.subject, isNull);
      expect(payload.body, isNull);
    });

    test('parses subject and body', () {
      final result =
          parser.parse(
                candidate('mailto:a@example.com?subject=Hi%20there&body=Hello'),
              )
              as ScanParseSuccess;
      final payload = result.payload as EmailPayload;
      expect(payload.subject, 'Hi there');
      expect(payload.body, 'Hello');
    });

    test('parses multiple comma-separated recipients', () {
      final result =
          parser.parse(candidate('mailto:a@example.com,b@example.com'))
              as ScanParseSuccess;
      final payload = result.payload as EmailPayload;
      expect(payload.recipients, ['a@example.com', 'b@example.com']);
    });

    test('fails safely with no recipient', () {
      final result = parser.parse(candidate('mailto:'));
      expect(result, isA<ScanParseFailed>());
    });
  });
}
