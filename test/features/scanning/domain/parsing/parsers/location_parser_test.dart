import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/location_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = LocationParser();

  group('LocationParser.canParse', () {
    test('accepts geo:', () {
      expect(parser.canParse(candidate('geo:-6.7735,39.2087')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('-6.7735,39.2087')), isFalse);
    });
  });

  group('LocationParser.parse', () {
    test('parses normal coordinates', () {
      final result =
          parser.parse(candidate('geo:37.786971,-122.399677'))
              as ScanParseSuccess;
      final payload = result.payload as LocationPayload;
      expect(payload.latitude, 37.786971);
      expect(payload.longitude, -122.399677);
    });

    test('parses negative coordinates', () {
      final result =
          parser.parse(candidate('geo:-6.7735,-39.2087')) as ScanParseSuccess;
      final payload = result.payload as LocationPayload;
      expect(payload.latitude, -6.7735);
      expect(payload.longitude, -39.2087);
    });

    test('accepts boundary latitude/longitude', () {
      final result = parser.parse(candidate('geo:90,180')) as ScanParseSuccess;
      final payload = result.payload as LocationPayload;
      expect(payload.latitude, 90);
      expect(payload.longitude, 180);
    });

    test('rejects an invalid latitude', () {
      final result = parser.parse(candidate('geo:91,39.2087'));
      expect(result, isA<ScanParseFailed>());
    });

    test('rejects an invalid longitude', () {
      final result = parser.parse(candidate('geo:-6.7735,181'));
      expect(result, isA<ScanParseFailed>());
    });

    test('parses a label/query', () {
      final result =
          parser.parse(candidate('geo:-6.7735,39.2087?q=Mlimani%20City%20Mall'))
              as ScanParseSuccess;
      final payload = result.payload as LocationPayload;
      expect(payload.query, 'Mlimani City Mall');
    });
  });
}
