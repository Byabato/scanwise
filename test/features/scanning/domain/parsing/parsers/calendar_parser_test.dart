import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/calendar_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = CalendarParser();

  group('CalendarParser.canParse', () {
    test('accepts a VEVENT block', () {
      expect(parser.canParse(candidate('BEGIN:VEVENT\nEND:VEVENT')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('Hello world')), isFalse);
    });
  });

  group('CalendarParser.parse', () {
    test('parses a UTC event', () {
      const ics =
          'BEGIN:VEVENT\nSUMMARY:Standup\nDTSTART:20260814T100000Z\n'
          'DTEND:20260814T103000Z\nEND:VEVENT';
      final result = parser.parse(candidate(ics)) as ScanParseSuccess;
      final payload = result.payload as CalendarEventPayload;
      expect(payload.title, 'Standup');
      expect(payload.start!.isUtc, isTrue);
      expect(payload.start!.hour, 10);
      expect(payload.end!.hour, 10);
      expect(payload.end!.minute, 30);
      expect(payload.isAllDay, isFalse);
    });

    test('parses a local-time (floating) event without assuming a zone', () {
      const ics =
          'BEGIN:VEVENT\nSUMMARY:Local meeting\nDTSTART:20260814T100000\n'
          'END:VEVENT';
      final result = parser.parse(candidate(ics)) as ScanParseSuccess;
      final payload = result.payload as CalendarEventPayload;
      expect(payload.start!.isUtc, isFalse);
      expect(payload.start!.timeZoneId, isNull);
      expect(payload.start!.hour, 10);
    });

    test('parses an all-day event', () {
      const ics =
          'BEGIN:VEVENT\nSUMMARY:Conference\nDTSTART;VALUE=DATE:20260814\n'
          'END:VEVENT';
      final result = parser.parse(candidate(ics)) as ScanParseSuccess;
      final payload = result.payload as CalendarEventPayload;
      expect(payload.isAllDay, isTrue);
      expect(payload.start!.hour, isNull);
    });

    test('handles a missing DTEND safely, with a warning', () {
      const ics =
          'BEGIN:VEVENT\nSUMMARY:Standup\nDTSTART:20260814T100000Z\n'
          'END:VEVENT';
      final result = parser.parse(candidate(ics)) as ScanParseSuccess;
      final payload = result.payload as CalendarEventPayload;
      expect(payload.end, isNull);
      expect(result.warnings, isNotEmpty);
    });

    test('fails safely on a malformed date', () {
      const ics =
          'BEGIN:VEVENT\nSUMMARY:Standup\nDTSTART:NOT-A-DATE\nEND:VEVENT';
      final result = parser.parse(candidate(ics));
      expect(result, isA<ScanParseFailed>());
    });

    test('fails safely with no DTSTART at all', () {
      const ics = 'BEGIN:VEVENT\nSUMMARY:Standup\nEND:VEVENT';
      final result = parser.parse(candidate(ics));
      expect(result, isA<ScanParseFailed>());
    });

    test('handles Unicode content', () {
      const ics =
          'BEGIN:VEVENT\nSUMMARY:Réunion café\nDTSTART:20260814T100000Z\n'
          'END:VEVENT';
      final result = parser.parse(candidate(ics)) as ScanParseSuccess;
      final payload = result.payload as CalendarEventPayload;
      expect(payload.title, 'Réunion café');
    });
  });
}
