import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/url_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = UrlParser();

  group('UrlParser.canParse', () {
    test('accepts https', () {
      expect(parser.canParse(candidate('https://example.com')), isTrue);
    });

    test('accepts http', () {
      expect(parser.canParse(candidate('http://example.com')), isTrue);
    });

    test('declines an unsupported scheme', () {
      expect(parser.canParse(candidate('ftp://example.com')), isFalse);
    });

    test('declines text that merely resembles a URL', () {
      expect(parser.canParse(candidate('example.com')), isFalse);
      expect(parser.canParse(candidate('Visit example.com today')), isFalse);
    });
  });

  group('UrlParser.parse', () {
    test('parses HTTPS with host', () {
      final result =
          parser.parse(candidate('https://example.com')) as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.scheme, 'https');
      expect(payload.host, 'example.com');
      expect(payload.port, isNull);
      expect(payload.hasUserInfo, isFalse);
    });

    test('parses HTTP', () {
      final result =
          parser.parse(candidate('http://example.com')) as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.scheme, 'http');
    });

    test('exposes an explicit non-default port', () {
      final result =
          parser.parse(candidate('https://example.com:8443/path'))
              as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.port, 8443);
    });

    test('drops an explicit default port', () {
      final result =
          parser.parse(candidate('https://example.com:443/path'))
              as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.port, isNull);
    });

    test('exposes query', () {
      final result =
          parser.parse(candidate('https://example.com/a?x=1&y=2'))
              as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.query, 'x=1&y=2');
    });

    test('exposes fragment', () {
      final result =
          parser.parse(candidate('https://example.com/a#section'))
              as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.fragment, 'section');
    });

    test('flags embedded credentials', () {
      final result =
          parser.parse(candidate('https://user:pass@example.com'))
              as ScanParseSuccess;
      final payload = result.payload as UrlPayload;
      expect(payload.hasUserInfo, isTrue);
    });

    test('fails safely on malformed percent-encoding', () {
      final result = parser.parse(candidate('https://example.com/%zz'));
      expect(result, isA<ScanParseFailed>());
    });

    test('normalizedValue lowercases scheme and host, keeps path case', () {
      final result =
          parser.parse(candidate('HTTPS://Example.COM/Account'))
              as ScanParseSuccess;
      expect(result.normalizedValue, 'https://example.com/Account');
    });
  });
}
