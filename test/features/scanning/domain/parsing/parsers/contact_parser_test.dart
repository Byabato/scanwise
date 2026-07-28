import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/contact_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = ContactParser();

  group('ContactParser.canParse', () {
    test('accepts BEGIN:VCARD', () {
      expect(parser.canParse(candidate('BEGIN:VCARD\nEND:VCARD')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('Hello world')), isFalse);
    });
  });

  group('ContactParser.parse', () {
    test('parses a vCard 3.0', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Jenkins;Sarah;;;\nORG:TechConf\n'
          'TEL:+14155550142\nEMAIL:sarah.jenkins@techconf.example\n'
          'URL:https://techconf.example\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.vCardVersion, '3.0');
      expect(payload.givenName, 'Sarah');
      expect(payload.familyName, 'Jenkins');
      expect(payload.fullName, 'Sarah Jenkins');
      expect(payload.organization, 'TechConf');
      expect(payload.phones, ['+14155550142']);
      expect(payload.emails, ['sarah.jenkins@techconf.example']);
      expect(payload.websites, ['https://techconf.example']);
    });

    test('parses a vCard 4.0', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:4.0\nFN:Alex Rivera\nEMAIL:alex@example.com\n'
          'END:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.vCardVersion, '4.0');
      expect(payload.fullName, 'Alex Rivera');
    });

    test('collects multiple phones', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nFN:Jamie Lee\nTEL:+15550001111\n'
          'TEL;TYPE=CELL:+15550002222\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.phones, ['+15550001111', '+15550002222']);
    });

    test('collects multiple emails', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nFN:Jamie Lee\nEMAIL:a@example.com\n'
          'EMAIL:b@example.com\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.emails, ['a@example.com', 'b@example.com']);
    });

    test('degrades a partial contact (name only) safely, with a warning', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:Jamie Lee\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.fullName, 'Jamie Lee');
      expect(payload.phones, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('a structurally complete but empty vCard succeeds with a warning', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first.code, 'incomplete-vcard');
    });

    test('skips a malformed line safely instead of throwing', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nFN:Jamie Lee\nNOT_A_VALID_LINE\n'
          'TEL:+15550001111\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.fullName, 'Jamie Lee');
      expect(payload.phones, ['+15550001111']);
    });

    test('unfolds a folded line', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nNOTE:This is a long note that\n '
          'continues on the next line\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(
        payload.note,
        'This is a long note thatcontinues on the next line',
      );
    });

    test('handles a Unicode name', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:José García\nEND:VCARD';
      final result = parser.parse(candidate(vcard)) as ScanParseSuccess;
      final payload = result.payload as ContactPayload;
      expect(payload.fullName, 'José García');
    });

    test('fails safely when END:VCARD is missing (incomplete)', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:Jamie Lee';
      final result = parser.parse(candidate(vcard));
      expect(result, isA<ScanParseFailed>());
    });
  });
}
