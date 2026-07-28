import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/enums/scan_kind.dart';
import 'package:scanwise/features/scanning/domain/failures/scan_parse_failure.dart';
import 'package:scanwise/features/scanning/domain/parsing/parser_registry.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsing_limits.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_outcome.dart';

import '../../support/candidate.dart';

void main() {
  final registry = ParserRegistry();

  group('precedence', () {
    test('a 978-prefixed EAN-13 resolves as ISBN, not a generic product', () {
      final outcome = registry.parse(
        candidate('9780306406157', symbology: BarcodeSymbology.ean13),
      );
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.isbn);
    });

    test('a non-Bookland EAN-13 resolves as a generic product', () {
      final outcome = registry.parse(
        candidate('4006381333931', symbology: BarcodeSymbology.ean13),
      );
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.product);
    });

    test('an https URL resolves as url, not plain text', () {
      final outcome = registry.parse(candidate('https://example.com'));
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.url);
    });

    test('ordinary text resolves as plain text', () {
      final outcome = registry.parse(candidate('Hello world'));
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.plainText);
    });
  });

  group('structural gates', () {
    test('rejects empty content', () {
      final outcome = registry.parse(candidate(''));
      expect(outcome, isA<ScanParseOutcomeFailure>());
      expect(
        (outcome as ScanParseOutcomeFailure).failure,
        isA<EmptyContentFailure>(),
      );
    });

    test('rejects oversized content', () {
      final outcome = registry.parse(
        candidate('a' * (kMaxScanContentLength + 1)),
      );
      expect(outcome, isA<ScanParseOutcomeFailure>());
      expect(
        (outcome as ScanParseOutcomeFailure).failure,
        isA<OversizedContentFailure>(),
      );
    });

    test('accepts content exactly at the size boundary', () {
      final outcome = registry.parse(candidate('a' * kMaxScanContentLength));
      expect(outcome, isA<ScanParseOutcomeSuccess>());
    });
  });

  group('fallback policy', () {
    test('a malformed WIFI: payload degrades to plain text with a warning', () {
      final outcome = registry.parse(candidate('WIFI:T:WPA;S:;P:pw;;'));
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.plainText);
      expect(scan.warnings, isNotEmpty);
      expect(scan.warnings.first.code, 'malformed-wifi');
    });

    test('an incomplete vCard degrades to plain text with a warning', () {
      final outcome = registry.parse(candidate('BEGIN:VCARD\nFN:Jamie'));
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.plainText);
      expect(scan.warnings.first.code, 'incomplete-vcard');
    });

    test('an invalid geo: falls back to plain text with a warning', () {
      final outcome = registry.parse(candidate('geo:200,200'));
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.kind, ScanKind.plainText);
      expect(scan.warnings.first.code, 'invalid-coordinates');
    });

    test('never returns a failure for non-empty, non-oversized content', () {
      for (final value in [
        'WIFI:garbage',
        'BEGIN:VEVENT\nEND:VEVENT',
        'mailto:',
        'tel:',
        '###',
      ]) {
        final outcome = registry.parse(candidate(value));
        expect(outcome, isA<ScanParseOutcomeSuccess>(), reason: value);
      }
    });
  });

  group('assembled ParsedScan', () {
    test('carries identity, attributes and actions', () {
      final outcome = registry.parse(candidate('https://example.com'));
      final scan = (outcome as ScanParseOutcomeSuccess).scan;
      expect(scan.identity.kind, ScanKind.url);
      expect(scan.attributes, isNotEmpty);
      expect(scan.actions, isNotEmpty);
      expect(scan.actions.where((a) => a.isPrimary).length, 1);
      expect(scan.payload, isA<UrlPayload>());
    });
  });
}
