import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/parsing/parser_registry.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_outcome.dart';
import 'package:scanwise/features/scanning/presentation/mapping/parsed_scan_presentation_mapper.dart';
import 'package:scanwise/shared/fixtures/models/result_action_fixture.dart';
import 'package:scanwise/shared/fixtures/models/result_fixture_kind.dart';

import '../../support/candidate.dart';

void main() {
  final registry = ParserRegistry();

  ScanParseOutcomeSuccess parse(String rawValue) =>
      registry.parse(candidate(rawValue)) as ScanParseOutcomeSuccess;

  test('maps a URL scan onto the trustedUrl fixture kind', () {
    final scan = parse('https://example.com').scan;
    final fixture = mapParsedScanToResultFixture(scan);
    expect(fixture.kind, ResultFixtureKind.trustedUrl);
    expect(fixture.title, 'example.com');
    expect(fixture.rawPayload, 'https://example.com');
    expect(fixture.security, isNotNull);
    expect(fixture.security!.findings, isEmpty);
  });

  test(
    'maps a Wi-Fi scan with a masked, demonstrable copy-password action',
    () {
      final scan = parse('WIFI:T:WPA;S:OfficeNet;P:secret123;;').scan;
      final fixture = mapParsedScanToResultFixture(scan);
      expect(fixture.kind, ResultFixtureKind.wifi);
      expect(fixture.primaryAction.tier, ResultActionTier.demonstrable);
      expect(fixture.primaryAction.copyValue, 'secret123');
      final passwordField = fixture.fields.firstWhere(
        (f) => f.label == 'Password',
      );
      expect(passwordField.masked, isTrue);
    },
  );

  test('maps disabled domain actions onto the disabled tier with a reason', () {
    final scan = parse('https://example.com').scan;
    final fixture = mapParsedScanToResultFixture(scan);
    expect(fixture.primaryAction.tier, ResultActionTier.disabled);
    expect(fixture.primaryAction.semanticHint, isNotNull);
  });

  test('maps enabled share/save domain actions onto the previewOnly tier', () {
    final scan = parse('https://example.com').scan;
    final fixture = mapParsedScanToResultFixture(scan);
    final share = fixture.secondaryActions.firstWhere(
      (a) => a.label == 'Share',
    );
    final save = fixture.secondaryActions.firstWhere((a) => a.label == 'Save');
    expect(share.tier, ResultActionTier.previewOnly);
    expect(save.tier, ResultActionTier.previewOnly);
  });

  test(
    'maps ISBN onto the product fixture kind with an ISBN-specific label',
    () {
      final scan = parse('ISBN 0-306-40615-2').scan;
      final fixture = mapParsedScanToResultFixture(scan);
      expect(fixture.kind, ResultFixtureKind.product);
      expect(fixture.typeLabel, 'Book (ISBN)');
    },
  );

  test('maps unknown content onto the unsupported fixture kind', () {
    final scan = parse('bad�data').scan;
    final fixture = mapParsedScanToResultFixture(scan);
    expect(fixture.kind, ResultFixtureKind.unsupported);
  });

  test('carries technical attributes through as technical detail rows', () {
    final scan = parse('https://example.com/a?x=1').scan;
    final fixture = mapParsedScanToResultFixture(scan);
    expect(fixture.technicalDetails.any((f) => f.label == 'Symbology'), isTrue);
  });

  test('exactly one primary action is produced for every mapped result', () {
    for (final value in [
      'https://example.com',
      'WIFI:T:WPA;S:Net;P:pw;;',
      'BEGIN:VCARD\nVERSION:3.0\nFN:Sarah\nEND:VCARD',
      'tel:+255222410500',
      'mailto:a@example.com',
      'geo:1,1',
      'Hello world',
    ]) {
      final scan = parse(value).scan;
      final fixture = mapParsedScanToResultFixture(scan);
      // A ResultFixture always has exactly one primaryAction by
      // construction; this asserts the mapper always finds one to use.
      expect(fixture.primaryAction, isNotNull, reason: value);
    }
  });
}
