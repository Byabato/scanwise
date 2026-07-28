import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/plain_text_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = PlainTextParser();

  group('PlainTextParser.canParse', () {
    test('accepts ordinary text', () {
      expect(parser.canParse(candidate('Hello world')), isTrue);
    });

    test('accepts Unicode text', () {
      expect(parser.canParse(candidate('こんにちは')), isTrue);
    });

    test('declines the Unicode replacement character', () {
      expect(parser.canParse(candidate('bad�data')), isFalse);
    });

    test('declines binary control characters', () {
      expect(parser.canParse(candidate('bad\x01data')), isFalse);
    });
  });

  group('PlainTextParser.parse', () {
    test('preserves the text verbatim and never lowercases it', () {
      final result =
          parser.parse(candidate('Booth 14B — badge pickup'))
              as ScanParseSuccess;
      final payload = result.payload as PlainTextPayload;
      expect(payload.text, 'Booth 14B — badge pickup');
      expect(result.normalizedValue, 'Booth 14B — badge pickup');
    });
  });
}
